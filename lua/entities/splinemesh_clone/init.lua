include('shared.lua')

function ENT:Initialize()
    
    if !InfMap then return end
    InfMap.prop_update_chunk(self, InfMap.TextToChunk(self.chunkKey))
    self:PhysicsInit(SOLID_VPHYSICS)

    self.chunkPhysics = {}
    local i = 1
    for k,convex in pairs(self.parent.InfMapOffsets[self.chunkKey]) do
        self.chunkPhysics[i] = {}
        for k2,vertex in pairs(self.parent.physics[convex]) do
            -- print(vertex)
            self.chunkPhysics[i][k2] = Vector(vertex:Unpack())
            -- self.chunkPhysics[i][k2], co = InfMap.localize_vector(self.chunkPhysics[i][k2])
            self.chunkPhysics[i][k2]:Sub(self.CHUNK_OFFSET * 2 * InfMap.chunk_size)
        end
        i = i + 1
    end

    -- PrintTable(self.parent.InfMapOffsets[self.chunkKey])
    -- PrintTable(self.chunkPhysics)
    -- self.chunkPhysics = SplineMesh.WeldConvexesPos(self.chunkPhysics)
    -- PrintTable(self.chunkPhysics)
    -- for k,v in pairs(self.chunkPhysics) do print(k) end

    self:PhysicsInitMultiConvex( self.chunkPhysics )
    -- self:PhysicsFromMesh( self.chunkPhysics )
    
    self:GetPhysicsObject():EnableMotion( false )
    self:GetPhysicsObject():SetMass(500000)
    self:GetPhysicsObject():AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
    self:GetPhysicsObject():AddGameFlag(FVPHYSICS_NO_SELF_COLLISIONS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:EnableCustomCollisions(true)
    self:DrawShadow(false)
    self:SetNoDraw(true)
    self:AddSolidFlags(FSOLID_FORCE_WORLD_ALIGNED)
    self:AddFlags(FL_STATICPROP)
end