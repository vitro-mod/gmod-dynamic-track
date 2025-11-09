include("shared.lua")

function ENT:GenerateCollisionMeshes()
    self.collisionIMeshes = {}
    for c,convex in pairs(self.chunkPhysics) do
        local convexMesh = {}

        for v,vertex in pairs(convex) do
            convexMesh[v] = {pos = vertex}
        end

        if self.collisionIMeshes[c] then self.collisionIMeshes[c]:Destroy() end

        self.collisionIMeshes[c] = Mesh()
        self.collisionIMeshes[c]:BuildFromTriangles(convexMesh)
    end

    self.wireframe = Material( "editor/wireframe" )
    local color = self.wireframe:GetVector('$color')
    -- color:SetUnpacked(1,1,0)
    color:Random(0.5,1)
    self.wireframe:SetVector('$color', color)
end

function ENT:Draw()
    if ( not self.collisionIMeshes ) then return self:GenerateCollisionMeshes() end

    if InfMap.ChunkToText(LocalPlayer().CHUNK_OFFSET) ~= self.chunkKey then return end

    -- -- The material to render our mesh with
    -- render.SetMaterial( self.wireframe )

    -- for k2,imesh in pairs(self.collisionIMeshes) do            
    --     -- Draw our mesh
    --     imesh:Draw()
    -- end
end
