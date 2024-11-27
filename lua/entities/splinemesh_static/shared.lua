ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Physics SplineMesh Static"
ENT.Author			= "vitro_mod"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.METERS_IN_UNIT = 0.01905 --0.0254*0.75
ENT.UNITS_IN_METER = 1 / 0.01905

if InfMap then
    InfMap.filter['splinemesh_static'] = true
    InfMap.filter['splinemesh_clone'] = true
    ENT.PREV_SOURCE_BOUND = 2 * InfMap.chunk_size - 16384
end

if SERVER then
    ENT.Model = "models/mn_r/mn_r.mdl"
end

function ENT:SetupDataTables()
    self:NetworkVar('String', 'MdlFile')
    self:NetworkVar('Vector', 'OrigPos')
    self:NetworkVar('Angle', 'OrigAngles')
end

function ENT:Initialize()
    if SERVER then
        self.OrigPos = self:GetPos()
        self.OrigAngles = self:GetAngles()
        self.OrigMatrix = Matrix(self:GetWorldTransformMatrix())

        self:SetMdlFile(self.Model)
        self:SetOrigPos(self.OrigPos)
        self:SetOrigAngles(self.OrigAngles)
    elseif CLIENT then
        self.Model = self:GetMdlFile()
        self.OrigPos = self:GetOrigPos()
        self.OrigAngles = self:GetOrigAngles()
    end

    self.OrigMatrix = Matrix()
    self.OrigMatrix:Translate(self.OrigPos)
    self.OrigMatrix:Rotate(self.OrigAngles)
    -- self:SetPos( Vector(0,0,0) ) -- Set pos where is player looking
    -- self:SetAngles( Angle(0,0,0) )

    self:SetModel( self.Model )
    self:PhysicsInit(SOLID_VPHYSICS)

    if CLIENT then
        --self:SetRenderBounds( self.Mins, self.Maxs )
        self:SetRenderBounds( Vector(-50000, -50000, -50000), Vector(50000, 50000, 50000) )

        self:DrawShadow( false )

        self.RenderMatrix = self.OrigMatrix
        if self.RenderMatrix:GetAngles():IsZero() and self.RenderMatrix:GetTranslation():IsZero() then
            self.RenderMatrix = Matrix() -- otherwise we multiply on zero matrix and model disappears
        end
    end

    self.convexes = self:GetPhysicsObject():GetMeshConvexes()
    self.matricies = {Matrix()}

    if InfMap then
        self.InfMapOffsets = {}
        local _, deltachunk = InfMap.localize_vector(self.OrigPos)
        self.ChunkKey = InfMap.ChunkToText(deltachunk)
    end

    self:PhysicsDestroy()
    self:PhysicsInitBox(Vector(0, 0, 0), Vector(0, 0, 0))
    -- self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self:PhysicsDestroy()

    self:SortCollisionByChunks()
    self:SpawnCollisionClones()

    self:SetupSnaps()
    self:SpawnDoors()
end

function ENT:SortCollisionByChunks()
    self.ChunkCollisionMatricies = {}

    local directions = {
        {axis = "x", vector = Vector(1, 0, 0)},
        {axis = "y", vector = Vector(0, 1, 0)},
        {axis = "z", vector = Vector(0, 0, 1)}
    }

    for i,matrix in pairs(self.matricies) do
        local translation = matrix:GetTranslation()
        translation:Add(self.OrigMatrix:GetTranslation())

        local wrappedpos, deltachunk = InfMap.localize_vector(translation)
        local chunkKey = InfMap.ChunkToText(deltachunk)

        self.ChunkCollisionMatricies[chunkKey] = self.ChunkCollisionMatricies[chunkKey] or {}
        self.ChunkCollisionMatricies[chunkKey][i] = true

        for _, dir in ipairs(directions) do
            if wrappedpos[dir.axis] <= -self.PREV_SOURCE_BOUND then
                local chunkKey = InfMap.ChunkToText(deltachunk - dir.vector)
                self.ChunkCollisionMatricies[chunkKey] = self.ChunkCollisionMatricies[chunkKey] or {}
                self.ChunkCollisionMatricies[chunkKey][i] = true
            end
            if wrappedpos[dir.axis] >= self.PREV_SOURCE_BOUND then
                local chunkKey = InfMap.ChunkToText(deltachunk + dir.vector)
                self.ChunkCollisionMatricies[chunkKey] = self.ChunkCollisionMatricies[chunkKey] or {}
                self.ChunkCollisionMatricies[chunkKey][i] = true
            end
        end
    end
end

function ENT:SpawnCollisionClones()
    if not SERVER then return end

    self.clones = {}

    if not InfMap then return end

    for chunkKey,v in pairs(self.ChunkCollisionMatricies) do
        local e = ents.Create("splinemesh_clone")
        if ( !IsValid( e ) ) then return end -- Safety first

        e.parent = self
        e:SetParentSpline(self)
        table.insert(self.clones, e)

        e.chunkKey = chunkKey
        e:SetChunkKey(chunkKey)

        print('SpawnCollisionClones: ', e)
        e:Spawn()
    end
end

function ENT:SetupSnaps()
    self.Snaps = {}
    
    local staticDef = SplineMesh.Definitions.Static[self:GetMdlFile()]
    if not staticDef then return end
    if not staticDef.snaps then return end

    for k,v in pairs(staticDef.snaps) do
        local snap = Matrix(self.OrigMatrix)
        snap:Translate(v.pos)
        snap:Rotate(v.ang)
        self.Snaps[k] = snap
    end

    -- PrintTable(self.Snaps)
end

function ENT:SpawnDoors()
    if not SERVER then return end
    self.Doors = {}

    local staticDef = SplineMesh.Definitions.Static[self:GetMdlFile()]
    if not staticDef then return end
    if not staticDef.doors then return end

    for k,doorDef in pairs(staticDef.doors) do
        local door = ents.Create('prop_door_rotating')
        door:SetModel(doorDef.model)
        door:PhysicsInit(SOLID_VPHYSICS)
        -- door:SetMoveType(MOVETYPE_NONE)
        -- door:DrawShadow(false)
        -- door:SetParent(self)
        door:SetPos(self:LocalToWorld(doorDef.pos))
        door:SetAngles(self:LocalToWorldAngles(doorDef.ang))
        door:SetKeyValue("returndelay","-1")
        door:SetKeyValue("distance","1.5")
        door:SetKeyValue("speed","0.4")
        door:SetKeyValue("soundmoveoverride","autoswitch_amb_tun.wav")
        door:SetKeyValue("soundcloseoverride","common/null.wav")
        door:Spawn()
        self.Doors[k] = door
    end
end
