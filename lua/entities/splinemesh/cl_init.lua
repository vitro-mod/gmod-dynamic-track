include("shared.lua")

function ENT:CreateMesh()
    self.DummyModel = ClientsideModel("models/shadertest/vertexlit.mdl")
    -- Destroy any previous meshes
    if self.IMeshes then
        for k,v in pairs(self.IMeshes) do
            if not v then return end
            v:Destroy()
        end
    end

    self.IMeshes = {}
    self.IMaterials = {}

    for k,currentMesh in pairs(self.Meshes) do
        local IMaterial = SplineMesh.Cache.Get("IMATERIAL:" .. currentMesh.material)
        if not IMaterial then
            IMaterial = Material(currentMesh.material)
            local baseTexture = IMaterial:GetTexture("$basetexture"):GetName()
            local material = self:CreateShaderMaterial(baseTexture)
            IMaterial = material
            SplineMesh.Cache.Set("IMATERIAL:" .. currentMesh.material, IMaterial)
        end
        self.IMaterials[k] = IMaterial
        local IMesh = SplineMesh.Cache.Get("IMESH:" .. self.Model .. ":" .. k)
        if not IMesh then
            IMesh = Mesh()
            IMesh:BuildFromTriangles(currentMesh.triangles)
            SplineMesh.Cache.Set("IMESH:" .. self.Model .. ":" .. k, IMesh)
        end
        self.IMeshes[k] = IMesh
    end
end

-- A special hook to override the normal mesh for rendering
-- function ENT:GetRenderMesh()
--     -- If the mesh doesn't exist, create it!
--     if ( !self.IMesh ) then return self:CreateMesh() end

--     return { Mesh = self.IMesh, Material = self.myMaterial }
-- end

-- local lightPos1 = Vector(90, 140, 150)
-- local lightPos2 = Vector(90, 440, 150)
-- local lightPos3 = Vector(-90, 175, 160)

function ENT:DrawModelOrMesh(drawCollision)
    -- local matrix = Matrix()
    -- local light1 = Vector()
    -- local light2 = Vector()
    -- local light3 = Vector()
    -- render.SuppressEngineLighting(true)
    -- render.ResetModelLighting(0, 0, 0)
    -- render.SuppressEngineLighting(false)

    render.OverrideDepthEnable(true, true)
    render.SuppressEngineLighting(true)
    render.SetModelLighting(0, self.bezierSpline.startPos:Unpack())
    render.SetModelLighting(1, self.bezierSpline.startTangent:Unpack())
    render.SetModelLighting(2, self.bezierSpline.endTangent:Unpack())
    render.SetModelLighting(3, self.bezierSpline.endPos:Unpack())
    render.SetModelLighting(4, 0, -self.Mins.y, 0)
    render.SetModelLighting(5, self.SegmentLength, 0, 0)
    self.DummyModel:DrawModel()
    for k,imesh in pairs(self.IMeshes) do
        render.SetMaterial(self.IMaterials[k])
        for k2,v in pairs(self.matricies) do
            cam.PushModelMatrix( SplineMesh.RenderOffset * self.RenderMatrix * v )
            self.IMeshes[k]:Draw()
            cam.PopModelMatrix()
        end
    end
    render.OverrideDepthEnable(false, false)
    render.SuppressEngineLighting(false)

    -- for k,v in pairs(self.matricies) do
        -- matrix = SplineMesh.RenderOffset * self.RenderMatrix * v

        -- light1:SetUnpacked(lightPos1:Unpack())
        -- light1:Rotate(matrix:GetAngles())
        -- light2:SetUnpacked(lightPos2:Unpack())
        -- light2:Rotate(matrix:GetAngles())
        -- light3:SetUnpacked(lightPos3:Unpack())
        -- light3:Rotate(matrix:GetAngles())
        -- render.SetLocalModelLights({
        --     { type = MATERIAL_LIGHT_POINT, pos = matrix:GetTranslation() + lightPos1, fiftyPercentDistance = 100, zeroPercentDistance = 200, color = Vector(1, 0.5, 0.25) * 2 },
        --     { type = MATERIAL_LIGHT_POINT, pos = matrix:GetTranslation() + lightPos2, fiftyPercentDistance = 100, zeroPercentDistance = 200, color = Vector(1, 0.5, 0.25) * 2 },
        --     { type = MATERIAL_LIGHT_POINT, pos = matrix:GetTranslation() + lightPos3, fiftyPercentDistance = 100, zeroPercentDistance = 200, color = Vector(1, 1, 1)      * 2 },
        -- })
        -- cam.PushModelMatrix( matrix )
        -- cam.PushModelMatrix( SplineMesh.RenderOffset * self.RenderMatrix * v )
        -- for k2,imesh in pairs(self.IMeshes) do
            -- render.SetMaterial(self.IMaterials[k2])
            -- self.IMeshes[k2]:Draw()
        -- end
        -- self:Debug(2)
        -- cam.PopModelMatrix()
    -- end

    

    -- render.SuppressEngineLighting(true)
    -- render.ResetModelLighting(0,0,0)
    -- render.SuppressEngineLighting(false)

    -- render.SetLocalModelLights({
    --     { type = MATERIAL_LIGHT_POINT, pos = matrix:GetTranslation() + Vector(100,100,200), fiftyPercentDistance = 100, zeroPercentDistance = 200, color = Vector(1, 0, 1) }
    -- })

    -- for k2,imesh in pairs(self.IMeshes) do
    --     render.SetMaterial(self.IMaterials[k2])
    --     for k,v in pairs(self.matricies) do
    --         matrix = SplineMesh.RenderOffset * self.RenderMatrix * v
    --         cam.PushModelMatrix(matrix)
    --         self.IMeshes[k2]:Draw()
    --         cam.PopModelMatrix()
    --     end
    -- end
end

function ENT:Draw()

    if ( not self.IMeshes ) then return self:CreateMesh() end

    -- Draw the mesh normally
    self:DrawModelOrMesh(true)
    
    -- Draw the additive flashlight layers
    render.RenderFlashlights( function() self:DrawModelOrMesh(false) end )
end

function ENT:Debug(segm)
    for i=1,segm do
        local linePoint1 = self.bezierSpline:Sample((i - 1) / segm)
        local linePoint2 = self.bezierSpline:Sample(i / segm)
        render.DrawLine(linePoint1, linePoint2, Color(255, 255, 0))

        local derivative = self.bezierSpline:Derivative():Sample((i - 1) / segm)
        derivative:Normalize()
        derivative:Mul(40)
        local normalPoint2 = linePoint1 + Vector(derivative.y, -derivative.x, derivative.z)
        render.DrawLine(linePoint1, normalPoint2, Color(255, 255, 0))
    end
    render.DrawLine(self.bezierSpline.startPos, self.bezierSpline.startTangent, Color(255, 0, 0))
    render.DrawLine(self.bezierSpline.endPos, self.bezierSpline.endTangent, Color(0, 255, 0))
end

function ENT:CreateShaderMaterial(baseTexture)
    print("Creating material for texture: " .. baseTexture)

    local mat = CreateMaterial("splinemesh_" .. SysTime(), "screenspace_general", {
        ["$pixshader"] = "example10_ps20b",
        ["$vertexshader"] = "splinemesh_vs20",
        ["$basetexture"] = baseTexture,
        ["$model"] = 1,
        ["$cull"] = 1,
        ["$depthtest"] = 1,
        ["$softwareskin"] = 1,
        ["$vertexnormal"] = 1,
    })

    return mat
end