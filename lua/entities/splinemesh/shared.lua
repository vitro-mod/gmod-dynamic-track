ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.PrintName        = "Physics SplineMesh"
ENT.Author            = "vitro_mod"

ENT.Spawnable        = false
ENT.AdminSpawnable    = false

ENT.METERS_IN_UNIT = 0.01905 --0.0254*0.75
ENT.UNITS_IN_METER = 1 / 0.01905

if InfMap then
    InfMap.filter['splinemesh'] = true
    InfMap.filter['splinemesh_clone'] = true
    ENT.PREV_SOURCE_BOUND = 2 * InfMap.chunk_size - 16384
end

if SERVER then
    ENT.Model = "models/mn_r/mn_t_rn1.mdl"
    ENT.TrackMeshNum = 3
    -- ENT.Model = "models/mn_r/mn_r_noall.mdl"
    -- ENT.TrackMeshNum = 1
    -- ENT.Model = "models/metrostroi/tracks/tunnel256_gamma.mdl"
    -- ENT.TrackMeshNum = 3
    -- ENT.Model = "models/nekrasovskaya/tunnel_2track_round_434.mdl"
    -- ENT.TrackMeshNum = 1
    ENT.RADIUS = 250
    ENT.ANGLE = -45
    ENT.LENGTH = 50
    ENT.CURVE = false
    ENT.ROLL = 0---6.75
    ENT.FORWARD_AXIS = 'X'
    -- ENT.FORWARD_AXIS = 'Y'
    ENT.PROFILE = {}
    ENT.profileStart = 0
end

function ENT:SetupDataTables()
    self:NetworkVar('String', 'MdlFile')
    self:NetworkVar('Int', 'TrackMeshNum')
    self:NetworkVar('Float', 'CurveRadius')
    self:NetworkVar('Float', 'CurveAngle')
    self:NetworkVar('Float', 'TrackLength')
    self:NetworkVar('Bool', 'IsCurve')
    self:NetworkVar('Float', 'CurveRoll')
    self:NetworkVar('Vector', 'OrigPos')
    self:NetworkVar('Angle', 'OrigAngles')
    self:NetworkVar('String', 'ForwardAxis')
    self:NetworkVar('String', 'Profile')
    self:NetworkVar('Float', 'ProfileStart')
end

function ENT:Initialize()
    if SERVER then
        self.OrigPos = self:GetPos()
        self.OrigAngles = self:GetAngles()
        self.OrigMatrix = Matrix(self:GetWorldTransformMatrix())

        self:SetMdlFile(self.Model)
        self:SetTrackMeshNum(self.TrackMeshNum)
        self:SetCurveRadius(self.RADIUS)
        self:SetCurveAngle(self.ANGLE)
        self:SetTrackLength(self.LENGTH)
        self:SetIsCurve(self.CURVE)
        self:SetCurveRoll(self.ROLL)
        self:SetOrigPos(self.OrigPos)
        self:SetOrigAngles(self.OrigAngles)
        self:SetForwardAxis(self.FORWARD_AXIS)
        self:SetProfile(util.TableToJSON(self.PROFILE))
        self:SetProfileStart(self.profileStart)
    elseif CLIENT then
        self.Model = self:GetMdlFile()
        self.TrackMeshNum = self:GetTrackMeshNum()
        self.RADIUS = self:GetCurveRadius()
        self.ANGLE = self:GetCurveAngle()
        self.LENGTH = self:GetTrackLength()
        self.CURVE = self:GetIsCurve()
        self.ROLL = self:GetCurveRoll()
        self.OrigPos = self:GetOrigPos()
        self.OrigAngles = self:GetOrigAngles()
        self.FORWARD_AXIS = self:GetForwardAxis()
        self.PROFILE = util.JSONToTable(self:GetProfile())
        self.profileStart = self:GetProfileStart()
    end

    self.OrigMatrix = Matrix()
    self.OrigMatrix:Translate(self.OrigPos)
    self.OrigMatrix:Rotate(self.OrigAngles)
    -- self:SetPos( Vector(0,0,0) ) -- Set pos where is player looking
    -- self:SetAngles( Angle(0,0,0) )

    self:InitMeshes()
    if not self.Meshes or #self.Meshes == 0 then
        print('SplineMesh invalid meshes!', self)
        if SERVER then SafeRemoveEntity(self) end
        return
    end

    self:PrepareMeshes()
    self:CountMeshBoundingBox()
    self:BuildSegmentMatricies()
    self:DeformMeshes()

    if CLIENT then
        self:CreateMesh()
        --self:SetRenderBounds( self.Mins, self.Maxs )
        self:SetRenderBounds( Vector(-50000, -50000, -50000), Vector(50000, 50000, 50000) )

        self:DrawShadow( false )

        self.RenderMatrix = self.OrigMatrix
        if self.RenderMatrix:GetAngles():IsZero() and self.RenderMatrix:GetTranslation():IsZero() then
            self.RenderMatrix = Matrix() -- otherwise we multiply on zero matrix and model disappears
        end
    end

    -- self.NoPhysics = true

    if not self.NoPhysics then
        self:SetModel( self.Model )
        self:PhysicsInit(SOLID_VPHYSICS)

        self.convexes = self:GetPhysicsObject():GetMeshConvexes()
        self.convexesNum = #self.convexes
        for k,v in pairs(self.convexes) do
            self.convexes[k] = {verticies = v}

            if self.FORWARD_AXIS == 'X' then
                SplineMesh.RotateXY(self.convexes[k])
            end

            self:DeformMesh(self.convexes[k])

            self.convexes[k] = self.convexes[k].verticies
        end
    end

    if InfMap then
        self.InfMapOffsets = {}
        local _, deltachunk = InfMap.localize_vector(self.OrigPos)
        self.ChunkKey = InfMap.ChunkToText(deltachunk)
    end

    self:PhysicsDestroy()

    if not self.NoPhysics then
        self:PhysicsInitBox(Vector(0, 0, 0), Vector(0, 0, 0))
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        self:SortCollisionByChunks()
        self:SpawnCollisionClones()
    end

    self:SetupSnaps()
end

function ENT:InitMeshes()
    self.Meshes = util.GetModelMeshes( self.Model )
    if not self.Meshes then return end

    self.TrackMesh = self.Meshes[ self.TrackMeshNum ]
end

function ENT:PrepareMeshes()
    if self.FORWARD_AXIS ~= 'X' then return end

    for k,currentMesh in pairs(self.Meshes) do
        SplineMesh.RotateXY(currentMesh)
    end
end

function ENT:CountMeshBoundingBox()
    local min, max = SplineMesh.GetBoundingBox(self.TrackMesh)

    self.Mins = min
    self.Maxs = max
end

function ENT:DeformMeshes()
    for k,currentMesh in pairs(self.Meshes) do
        self:DeformMesh(currentMesh)
    end
end

function ENT:BuildSegmentMatricies()

    local radius = self.RADIUS * self.UNITS_IN_METER
    local length = self.LENGTH * self.UNITS_IN_METER

    local segmentLength = self.Maxs.y - self.Mins.y

    if self.CURVE then 
        local arc = math.rad(math.abs(self.ANGLE)) * radius

        self.segments = math.Round(arc / segmentLength)
        if self.segments == 0 then self.segments = 1 end
        self.bezierSpline = SplineMesh.ApproximateArc(self.ANGLE / self.segments, radius)
        self.matricies, self.endMatrix = SplineMesh.ArcSegments(self.ANGLE / self.segments, self.bezierSpline.endPos, self.segments)
    else
        self.segments = math.Round(length / segmentLength)
        if self.segments == 0 then self.segments = 1 end
        self.bezierSpline = SplineMesh.ApproximateStraight(length / self.segments)
        self.matricies, self.endMatrix = SplineMesh.StraightSegments(length, self.segments)
    end
    
    self.endDistance = self.profileStart + (segmentLength * self.segments)

    SplineMesh.ProfileApplyToMatricies(self.matricies, self.endMatrix, self.PROFILE, self.profileStart, segmentLength)
end

function ENT:DeformMesh(MESH)
    local segmentLength = self.Maxs.y - self.Mins.y
    local offset = Vector(0, -self.Mins.y, 0)

    MESH = SplineMesh.Deform(MESH, self.bezierSpline, segmentLength, self.ROLL, offset)

    return MESH
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
    local begin = Matrix(self.OrigMatrix)
    begin:Rotate(Angle(0, 180, 0))
    self.Snaps[1] = begin
    self.Snaps[2] = self.OrigMatrix * self.endMatrix
end
