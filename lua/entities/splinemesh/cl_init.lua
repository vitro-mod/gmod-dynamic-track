include("shared.lua")

local useShaders = CreateClientConVar("splinemesh_use_shaders", "0", true, false,
    "Deform track meshes with a vertex shader", 0, 1)

local vertexShader = "splinemesh_deform_vs20"
local pixelShader = "splinemesh_ps20b"

local function getShaderMaterial(material)
    local texture = material:GetTexture("$basetexture")
    if not texture or texture:IsError() then return end

    return CreateMaterial("splinemesh_deform_" .. util.CRC(material:GetName()), "screenspace_general", {
        ["$pixshader"] = pixelShader,
        ["$vertexshader"] = vertexShader,
        ["$basetexture"] = texture:GetName(),
        ["$model"] = 1,
        ["$cull"] = 1,
        ["$depthtest"] = 1,
        ["$softwareskin"] = 1,
        ["$vertexnormal"] = 1,
    })
end

function ENT:OnRemove()
    for _, mesh in pairs(self.IMeshes or {}) do
        mesh:Destroy()
    end
    self.IMeshes = nil

    if IsValid(self.DummyModel) then
        self.DummyModel:Remove()
    end
    self.DummyModel = nil
end

function ENT:CreateMesh()
    self:OnRemove()
    self.ShadersRequested = useShaders:GetBool()
    self.IMeshes = {}
    self.IMaterials = {}
    self.ShaderMeshes = {}

    local shadersAvailable = self.ShadersRequested
        and file.Exists("shaders/fxc/" .. vertexShader .. ".vcs", "GAME")
        and file.Exists("shaders/fxc/" .. pixelShader .. ".vcs", "GAME")

    if shadersAvailable then
        self.DummyModel = ClientsideModel("models/shadertest/vertexlit.mdl")
        shadersAvailable = IsValid(self.DummyModel)
        if shadersAvailable then
            self.DummyModel:SetNoDraw(true)
        end
    end

    for k, source in pairs(self.Meshes) do
        local material = Material(source.material)
        local shaderMaterial = shadersAvailable and getShaderMaterial(material)
        if shaderMaterial and not shaderMaterial:IsError() then
            self.ShaderMeshes[k] = true
            material = shaderMaterial
        end

        local triangles = source.triangles
        if self.FORWARD_AXIS == "X" or not self.ShaderMeshes[k] then
            triangles = table.CopyAV(triangles)
            local geometry = {verticies = triangles}
            if self.FORWARD_AXIS == "X" then
                SplineMesh.RotateXY(geometry)
            end
            if not self.ShaderMeshes[k] then
                self:DeformMesh(geometry)
            end
        end

        local mesh = Mesh(material)
        mesh:BuildFromTriangles(triangles)
        self.IMeshes[k] = mesh
        self.IMaterials[k] = material
    end
end

function ENT:Draw()
    if not self.bezierSpline then return end
    if not self.IMeshes or self.ShadersRequested ~= useShaders:GetBool() then
        self:CreateMesh()
    end

    local baseMatrix = self.RenderMatrix
    if SplineMesh.RenderOffset then
        baseMatrix = SplineMesh.RenderOffset * baseMatrix
    end

    -- Draw the CPU meshes before overriding the ambient cube.
    for k, mesh in pairs(self.IMeshes) do
        if not self.ShaderMeshes[k] then
            render.SetMaterial(self.IMaterials[k])
            for _, segment in ipairs(self.matricies) do
                cam.PushModelMatrix(baseMatrix * segment)
                mesh:Draw()
                cam.PopModelMatrix()
            end
        end
    end

    if not next(self.ShaderMeshes) then return end

    local spline = self.bezierSpline
    local roll = math.rad(self.ROLL)
    render.SuppressEngineLighting(true)
    render.SetModelLighting(BOX_FRONT, spline.startPos:Unpack())
    render.SetModelLighting(BOX_BACK, spline.startTangent:Unpack())
    render.SetModelLighting(BOX_RIGHT, spline.endTangent:Unpack())
    render.SetModelLighting(BOX_LEFT, spline.endPos:Unpack())
    render.SetModelLighting(BOX_TOP, -self.Mins.y, math.cos(roll), math.sin(roll))
    render.SetModelLighting(BOX_BOTTOM, self.SegmentLength, 0, 0)

    -- A model draw uploads the ambient cube to the vertex shader.
    render.OverrideColorWriteEnable(true, false)
    render.OverrideDepthEnable(true, false)
    self.DummyModel:DrawModel()
    render.OverrideColorWriteEnable(false, false)

    render.OverrideDepthEnable(true, true)
    for k in pairs(self.ShaderMeshes) do
        render.SetMaterial(self.IMaterials[k])
        for _, segment in ipairs(self.matricies) do
            cam.PushModelMatrix(baseMatrix * segment)
            self.IMeshes[k]:Draw()
            cam.PopModelMatrix()
        end
    end
    render.OverrideDepthEnable(false, false)
    render.SuppressEngineLighting(false)
end
