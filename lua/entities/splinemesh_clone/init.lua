include('shared.lua')

function ENT:Initialize()
    
    if !InfMap then return end
    self.chunkOffset = InfMap.TextToChunk(self.chunkKey)
    InfMap.prop_update_chunk(self, self.chunkOffset)
    self:PhysicsInit(SOLID_VPHYSICS)

    self.chunkPhysics = {}

    local i = 1
    for convex in pairs(self.parent.InfMapOffsets[self.chunkKey]) do
        self.chunkPhysics[i] = {}
        for k2,vertex in pairs(self.parent.physics[convex]) do
            self.chunkPhysics[i][k2] = Vector(vertex)
            self.chunkPhysics[i][k2]:Sub(self.CHUNK_OFFSET * 2 * InfMap.chunk_size)
        end
        i = i + 1
    end

    self:PhysicsInitMultiConvex( self.chunkPhysics )
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