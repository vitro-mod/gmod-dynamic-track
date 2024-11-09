ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Physics SplineMesh Collision Clone"
ENT.Author			= "vitro_mod"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:SetupDataTables()
    self:NetworkVar('Entity', 'ParentSpline')
    self:NetworkVar('String', 'ChunkKey')
end

function ENT:Initialize()
    if CLIENT then
        self.parent = self:GetParentSpline()
        self.chunkKey = self:GetChunkKey()
    end

    if InfMap then
        self.chunkOffset = InfMap.TextToChunk(self.chunkKey)
        InfMap.prop_update_chunk(self, self.chunkOffset)
    end

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

    self:InitCollision(self.chunkPhysics)
end

function ENT:InitCollision(convexes)
    self:PhysicsInitMultiConvex(convexes)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:EnableCustomCollisions(true)
    self:DrawShadow(false)
    self:SetRenderMode(RENDERMODE_NONE)
    -- self:SetNoDraw(true)
    self:AddSolidFlags(FSOLID_FORCE_WORLD_ALIGNED)
    self:AddFlags(FL_STATICPROP)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion( false )
        phys:SetMass(50000)
        phys:AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
        phys:AddGameFlag(FVPHYSICS_NO_SELF_COLLISIONS)
    end
end
