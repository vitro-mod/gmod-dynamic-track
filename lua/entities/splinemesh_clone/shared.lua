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

    self:GenerateCollision()
    self:InitCollision(self.chunkPhysics)
end

function ENT:GenerateCollision()
    self.chunkPhysics = {}

    local i = 0
    local convexesCount = #self.parent.convexes

    for matrixNum in pairs(self.parent.ChunkCollisionMatricies[self.chunkKey]) do

        local matrix = self.parent.matricies[matrixNum]

        for k,convex in pairs(self.parent.convexes) do
            local currentConvexIndex = i * convexesCount + k
            self.chunkPhysics[currentConvexIndex] = {}
            for v,vertex in pairs(convex) do
                self.chunkPhysics[currentConvexIndex][v] = Vector(vertex.pos)
                self.chunkPhysics[currentConvexIndex][v]:Rotate(matrix:GetAngles())
                self.chunkPhysics[currentConvexIndex][v]:Add(matrix:GetTranslation())
                self.chunkPhysics[currentConvexIndex][v]:Rotate(self.parent.OrigMatrix:GetAngles())
                self.chunkPhysics[currentConvexIndex][v]:Add(self.parent.OrigMatrix:GetTranslation())
                self.chunkPhysics[currentConvexIndex][v]:Sub(self.CHUNK_OFFSET * 2 * InfMap.chunk_size)
            end
        end
        i = i + 1
    end
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
