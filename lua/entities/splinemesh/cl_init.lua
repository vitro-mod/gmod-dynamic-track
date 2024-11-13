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

function ENT:SetupCollisionMeshes()
    self.wireframe = Material( "editor/wireframe" )
    local color = self.wireframe:GetVector('$color')
    color:SetUnpacked(1,1,0)
    self.wireframe:SetVector('$color', color)

    self.collisionMeshes = {}
    self.colors = {}
    self.defaultColor = Vector()
    self.defaultColor:Random(0,1)

    self.collisionMatrix = Matrix(self.matricies[1])
    local tr = self.collisionMatrix:GetTranslation()
    tr.z = 0
    local an = self.collisionMatrix:GetAngles()
    an.z = 0
    self.collisionMatrix:SetTranslation(tr)
    self.collisionMatrix:SetAngles(an)
end

-- A special hook to override the normal mesh for rendering
-- function ENT:GetRenderMesh()
-- 	-- If the mesh doesn't exist, create it!
-- 	if ( !self.IMesh ) then return self:CreateMesh() end

-- 	return { Mesh = self.IMesh, Material = self.myMaterial }
-- end

function ENT:DrawModelOrMesh(drawCollision)
    for k,v in pairs(self.matricies) do
        cam.PushModelMatrix( SplineMesh.RenderOffset * self.RenderMatrix * v )

        -- render.SuppressEngineLighting(true)
        -- render.ResetModelLighting(0,0,0)
        -- render.SuppressEngineLighting(false)

        for k2,imesh in pairs(self.IMeshes) do            
            -- The material to render our mesh with
            render.SetMaterial( self.IMaterials[k2] )
            -- Draw our mesh
            self.IMeshes[k2]:Draw()
        end

        if k == 1 and (false or SplineMesh.DrawCollision) and drawCollision then
            self:DrawCollision(self.collisionMatrix)
        end

        -- self:Debug(1)

        -- Undo the cam.PushModelMatrix call above
        cam.PopModelMatrix()
    end
end

function ENT:DrawCollision(matrix)
    cam.PushModelMatrix( SplineMesh.RenderOffset * matrix )

    render.SetMaterial(self.wireframe)

    for chunk,meshes in pairs(self.InfMapOffsets) do
        if InfMap.ChunkToText(LocalPlayer().CHUNK_OFFSET) ~= chunk then continue end
        self.wireframe:SetVector('$color', self.colors[chunk] or self.defaultColor)
        for meshnum,_ in pairs(self.InfMapOffsets[chunk]) do
        -- print(meshnum)
            self.collisionMeshes[meshnum]:Draw()
        end
    end

    cam.PopModelMatrix()
end

function ENT:Draw()

	if ( not self.IMeshes ) then return self:CreateMesh() end

	-- Draw the mesh normally
	self:DrawModelOrMesh(true)

	-- Draw the additive flashlight layers
	render.RenderFlashlights( function() self:DrawModelOrMesh(false) end )
end

function ENT:Debug(segm)
    render.DrawLine(self.bezierSpline.startPos, self.bezierSpline.startTangent, Color(255, 0, 0))
    render.DrawLine(self.bezierSpline.endPos, self.bezierSpline.endTangent, Color(0, 255, 0))
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
end

SplineMesh = SplineMesh || {}
SplineMesh.DrawCollision = false

cvars.AddChangeCallback( "vcollide_wireframe", function()
    SplineMesh.DrawCollision = GetConVar("vcollide_wireframe"):GetBool()
    print('DrawCollision: ', SplineMesh.DrawCollision)
end)

SplineMesh.DrawCollision = GetConVar("vcollide_wireframe"):GetBool()
