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
    if InfMap then
        self.chunkOffset = InfMap.TextToChunk(self.chunkKey)
        InfMap.prop_update_chunk(self, self.chunkOffset)
    end

    if CLIENT then
        self.parent = self:GetParentSpline()
        self.chunkKey = self:GetChunkKey()
    end

    -- self:SetModel(self.parent:GetModel())
    -- self:PhysicsInit(SOLID_VPHYSICS)

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

    if SERVER then
        self.InitCollision(self, self.chunkPhysics)
    else
        self.clientProp = ents.CreateClientProp( self.parent.Model )
        self.clientProp:SetModel(self.parent.Model)
        self.clientProp.parent = self
        if InfMap then
            InfMap.prop_update_chunk(self.clientProp, self.chunkOffset)
        end
        self.clientProp:SetPos(self.parent.OrigMatrix:GetTranslation())
        self.clientProp:SetAngles(self.parent.OrigMatrix:GetAngles())
        self.clientProp:Spawn()
        self.InitCollision(self.clientProp, self.chunkPhysics)
        self.clientProp:SetRenderBounds( Vector(-50000, -50000, -50000), Vector(50000, 50000, 50000) )
    end
end

function ENT.InitCollision(ent, multiconvex)
    if SERVER then
        ent:PhysicsInitMultiConvex( multiconvex )
    end
    ent:SetSolid(SOLID_VPHYSICS)
    ent:SetMoveType(MOVETYPE_NONE)
    if SERVER then
        ent:EnableCustomCollisions(true)
    end
    ent:DrawShadow(false)
    -- ent:SetRenderMode(RENDERMODE_NONE)
    -- ent:SetNoDraw(true)
    ent:AddSolidFlags(FSOLID_FORCE_WORLD_ALIGNED)
    ent:AddFlags(FL_STATICPROP)

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion( false )
        phys:SetMass(50000)
        phys:AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
        phys:AddGameFlag(FVPHYSICS_NO_SELF_COLLISIONS)
        if CLIENT then
            phys:SetAngles(ent.parent.parent.OrigMatrix:GetAngles())
        end
    end
end
