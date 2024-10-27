include("shared.lua")

function ENT:CreateMesh()
	self.MESH = self:DeformMesh(self.MESH)

	-- Set the material to draw the mesh with from the model data
	self.myMaterial = Material( self.MESH.material )

	-- Destroy any previous meshes
	if ( self.Mesh ) then self.Mesh:Destroy() end
	self.Mesh = Mesh()
	self.Mesh:BuildFromTriangles( self.MESH.triangles )
end

-- A special hook to override the normal mesh for rendering
-- function ENT:GetRenderMesh()
-- 	-- If the mesh doesn't exist, create it!
-- 	if ( !self.Mesh ) then return self:CreateMesh() end

-- 	return { Mesh = self.Mesh, Material = self.myMaterial }
-- end

function ENT:DrawModelOrMesh()
    for k,v in pairs(self.matricies) do

        cam.PushModelMatrix( SplineMesh.RenderOffset * self.RenderMatrix * v )
        -- The material to render our mesh with
        render.SetMaterial( self.myMaterial )
        
        -- Draw our mesh
        -- render.SuppressEngineLighting(true)
        -- render.ResetModelLighting(0,0,0)
        -- render.SuppressEngineLighting(false)
        self.Mesh:Draw()
        if true or SplineMesh.DrawCollision then
            if k == 1 then
                cam.PushModelMatrix( SplineMesh.RenderOffset * v )
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
        end
        -- self:Debug(2)
        -- Undo the cam.PushModelMatrix call above
        cam.PopModelMatrix()
    end
end

function ENT:Draw()


	if ( !self.Mesh ) then return self:CreateMesh() end


	-- Draw the mesh normally
	self:DrawModelOrMesh()

	-- Draw the additive flashlight layers
	render.RenderFlashlights( function() self:DrawModelOrMesh() end )

end

function ENT:Debug(segm)
    if not self.CURVE then return end
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

net.Receive("splinemesh_collision", function(len, ply)
    SplineMesh.DrawCollision = net.ReadBool()
end)

-- local function drawCollision()
--     SplineMesh.drawCollision = GetConVar("vcollide_wireframe"):GetBool()
-- end

-- hook.Remove( "PostDrawOpaqueRenderables", "IMeshTest" )
-- cvars.AddChangeCallback( "vcollide_wireframe", drawCollision)
-- SplineMesh.drawCollision = GetConVar("vcollide_wireframe"):GetBool()