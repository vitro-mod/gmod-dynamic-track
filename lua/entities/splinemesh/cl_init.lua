include("shared.lua")

function ENT:CreateMesh()
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
        self.IMaterials[k] = Material(currentMesh.material)
        self.IMeshes[k] = Mesh()
        self.IMeshes[k]:BuildFromTriangles(currentMesh.triangles)
    end
end

-- A special hook to override the normal mesh for rendering
-- function ENT:GetRenderMesh()
--     -- If the mesh doesn't exist, create it!
--     if ( !self.IMesh ) then return self:CreateMesh() end

--     return { Mesh = self.IMesh, Material = self.myMaterial }
-- end

local lightPos1 = Vector(90, 140, 150)
local lightPos2 = Vector(90, 440, 150)
local lightPos3 = Vector(-90, 175, 160)

function ENT:DrawModelOrMesh(drawCollision)
    local matrix = Matrix()
    local light1 = Vector()
    local light2 = Vector()
    local light3 = Vector()
    render.SuppressEngineLighting(true)
    render.ResetModelLighting(0, 0, 0)
    render.SuppressEngineLighting(false)
    for k,v in pairs(self.matricies) do
        matrix = SplineMesh.RenderOffset * self.RenderMatrix * v

        light1:SetUnpacked(lightPos1:Unpack())
        light1:Rotate(matrix:GetAngles())
        light2:SetUnpacked(lightPos2:Unpack())
        light2:Rotate(matrix:GetAngles())
        light3:SetUnpacked(lightPos3:Unpack())
        light3:Rotate(matrix:GetAngles())
        render.SetLocalModelLights({
            { type = MATERIAL_LIGHT_POINT, pos = matrix:GetTranslation() + lightPos1, fiftyPercentDistance = 100, zeroPercentDistance = 200, color = Vector(1, 0.5, 0.25) * 2 },
            { type = MATERIAL_LIGHT_POINT, pos = matrix:GetTranslation() + lightPos2, fiftyPercentDistance = 100, zeroPercentDistance = 200, color = Vector(1, 0.5, 0.25) * 2 },
            { type = MATERIAL_LIGHT_POINT, pos = matrix:GetTranslation() + lightPos3, fiftyPercentDistance = 100, zeroPercentDistance = 200, color = Vector(1, 1, 1)      * 2 },
        })
        cam.PushModelMatrix( matrix )
        for k2,imesh in pairs(self.IMeshes) do
            render.SetMaterial(self.IMaterials[k2])
            self.IMeshes[k2]:Draw()
        end
        -- self:Debug(2)
        cam.PopModelMatrix()
    end

    

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
