ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Physics SplineMesh"
ENT.Author			= "vitro_mod"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

if SERVER then
    ENT.Model = "models/metrostroi/tracks/tunnel256_gamma.mdl"
    ENT.MeshNum = 3
    ENT.RADIUS = 250
    ENT.ANGLE = -45
    ENT.LENGTH = 50
    ENT.CURVE = false
    ENT.ROLL = 0---6.75
    ENT.FORWARD_AXIS = 'Y'
end

function ENT:Initialize()
    self.OrigPos = self:GetPos()
    self.OrigAngles = self:GetAngles()
    self.OrigMatrix = Matrix(self:GetWorldTransformMatrix())

    if SERVER then
        self:SetNW2String('Model', self.Model)
        self:SetNW2Int('MeshNum', self.MeshNum)
        self:SetNW2Float('Radius', self.RADIUS)
        self:SetNW2Float('Angle', self.ANGLE)
        self:SetNW2Float('Length', self.LENGTH)
        self:SetNW2Bool('IsCurve', self.CURVE)
        self:SetNW2Float('Roll', self.ROLL)
        self.Model = Model(self.Model)
        self:SetNW2Vector('OrigPos', self.OrigPos)
        self:SetNW2Angle('OrigAngles', self.OrigAngles)
        self:SetNW2String('ForwardAxis', self.FORWARD_AXIS)
    elseif CLIENT then
        self.Model = Model(self:GetNW2String("Model"))
        self.MeshNum = self:GetNW2Int("MeshNum")
        self.RADIUS = self:GetNW2Float("Radius")
        self.ANGLE = self:GetNW2Float("Angle")
        self.LENGTH = self:GetNW2Float("Length")
        self.CURVE = self:GetNW2Bool("IsCurve")
        self.ROLL = self:GetNW2Float("Roll")
        self.OrigPos = self:GetNW2Vector("OrigPos")
        self.OrigAngles = self:GetNW2Angle("OrigAngles")
        self.FORWARD_AXIS = self:GetNW2String("ForwardAxis")
    end

    self.OrigMatrix = Matrix()
    self.OrigMatrix:Translate(self.OrigPos)
    self.OrigMatrix:Rotate(self.OrigAngles)
    self:SetPos( Vector(0,0,0) ) -- Set pos where is player looking
    self:SetAngles( Angle(0,0,0) )

    self:BuildSegmentMatricies()
    self:SetModel( self.Model )
    self:PhysicsInit(SOLID_VPHYSICS)

    if CLIENT then
        self:CreateMesh()
        --self:SetRenderBounds( self.Mins, self.Maxs )
        self:SetRenderBounds( Vector(-50000, -50000, -50000), Vector(50000, 50000, 50000) )

        self:DrawShadow( false )
        self.wireframe = Material( "editor/wireframe" )
        local color = self.wireframe:GetVector('$color')
        color:SetUnpacked(1,1,0)
        self.wireframe:SetVector('$color', color)
        self.collisionMeshes = {}
        self.colors = {}
        self.defaultColor = Vector()
        self.defaultColor:Random(0,1)

        self.RenderMatrix = self.OrigMatrix
        if self.RenderMatrix:GetAngles():IsZero() and self.RenderMatrix:GetTranslation():IsZero() then
            self.RenderMatrix = Matrix() -- otherwise we multiply on zero matrix and model disappears
        end
    end

    local scaledSegment = self.length / self.segments
    local scale = scaledSegment / self.Maxs.y

    self.convexes = self:GetPhysicsObject():GetMeshConvexes()
    self.convexesNum = #self.convexes
    for k,v in pairs(self.convexes) do
        self.convexes[k] = {verticies = v}

        if self.FORWARD_AXIS == 'X' then
            SplineMesh.RotateXY(self.convexes[k])
        end

        self.convexes[k] = self:DeformMesh(self.convexes[k])
        self.convexes[k] = self.convexes[k].verticies
    end

    self.physics = {}
    self.chunkPhysics = {}
    if InfMap then
        self.InfMapOffsets = {}
        InfMap.filter['splinemesh'] = true
        InfMap.filter['splinemesh_clone'] = true
        self.ChunkKey = InfMap.ChunkToText(self.CHUNK_OFFSET)
        self.clones = {}
    end

    local newConvexes = {}
    for i,matrix in pairs(self.matricies) do
        for k,convex in pairs(self.convexes) do

            local currentSegmentConvex = (i - 1) * self.convexesNum + k

            newConvexes[currentSegmentConvex] = table.CopyAV(convex)
            self.physics[currentSegmentConvex] = {}

            for k2,vertex in pairs(newConvexes[currentSegmentConvex]) do
                self.physics[currentSegmentConvex][k2] = vertex.pos
                vertex.pos:Rotate(matrix:GetAngles())
                vertex.pos:Add(matrix:GetTranslation())
                vertex.pos:Rotate(self.OrigMatrix:GetAngles())
                vertex.pos:Add(self.OrigMatrix:GetTranslation())
                
                if not InfMap then continue end

                local wrappedpos, deltachunk = InfMap.localize_vector(vertex.pos)
                local chunkKey = InfMap.ChunkToText(deltachunk)

                self.InfMapOffsets[chunkKey] = self.InfMapOffsets[chunkKey] || {}
                self.InfMapOffsets[chunkKey][currentSegmentConvex] = true

                local prev_source_bound = 2 * InfMap.chunk_size - 16384

                if wrappedpos.x <= -prev_source_bound then
                    local chunkKey = InfMap.ChunkToText(deltachunk - Vector(1, 0, 0))
                    self.InfMapOffsets[chunkKey] = self.InfMapOffsets[chunkKey] || {}
                    self.InfMapOffsets[chunkKey][currentSegmentConvex] = true
                end
                if wrappedpos.x >= prev_source_bound then
                    local chunkKey = InfMap.ChunkToText(deltachunk + Vector(1, 0, 0))
                    self.InfMapOffsets[chunkKey] = self.InfMapOffsets[chunkKey] || {}
                    self.InfMapOffsets[chunkKey][currentSegmentConvex] = true
                end
                if wrappedpos.y <= -prev_source_bound then
                    local chunkKey = InfMap.ChunkToText(deltachunk - Vector(0, 1, 0))
                    self.InfMapOffsets[chunkKey] = self.InfMapOffsets[chunkKey] || {}
                    self.InfMapOffsets[chunkKey][currentSegmentConvex] = true
                end
                if wrappedpos.y >= prev_source_bound then
                    local chunkKey = InfMap.ChunkToText(deltachunk + Vector(0, 1, 0))
                    self.InfMapOffsets[chunkKey] = self.InfMapOffsets[chunkKey] || {}
                    self.InfMapOffsets[chunkKey][currentSegmentConvex] = true
                end

                if CLIENT then
                    self.colors[chunkKey] = Vector()
                    self.colors[chunkKey]:Random(0,1)

                    self.collisionMeshes[currentSegmentConvex] = Mesh()
                    self.collisionMeshes[currentSegmentConvex]:BuildFromTriangles(newConvexes[currentSegmentConvex])
                end

                if chunkKey == self.ChunkKey then
                    self.chunkPhysics[currentSegmentConvex] = SplineMesh.PrepareConvexes(newConvexes[currentSegmentConvex])
                end

            end
        end
    end

    self:PhysicsDestroy()

    if SERVER then
        if InfMap then
            for chunkKey,v in pairs(self.InfMapOffsets) do
                local e = ents.Create("splinemesh_clone")
                if ( !IsValid( e ) ) then return end -- Safety first
                e.parent = self
                table.insert(self.clones, e)
                e.chunkKey = chunkKey
                print(e)
                -- e:SetPos(self:GetPos())
                -- e:SetAngles(self:GetAngles())
                e:Spawn()
            end
        end

        self.convexes = newConvexes
    end
end

function ENT:BuildSegmentMatricies()

    local metersInUnits = 0.01905 --0.0254*0.75
    self.radius = self.RADIUS / metersInUnits
    self.length = self.LENGTH / metersInUnits

	self.MESHes = util.GetModelMeshes( self.Model )
	if ( !self.MESHes ) then return end
	self.MESH = self.MESHes[ self.MeshNum ]

    if self.FORWARD_AXIS == 'X' then
        SplineMesh.RotateXY(self.MESH)
    end

    local min, max = SplineMesh.GetBoundingBox(self.MESH)

    self.Mins = min
    self.Maxs = max

    self.segment = max.y - min.y

    local transform = Matrix()

    if self.CURVE then 
        local arc = math.rad(math.abs(self.ANGLE)) * self.radius

        self.segments = math.Round(arc / self.segment)
        if self.segments == 0 then self.segments = 1 end
        self.bezierSpline = SplineMesh.ApproximateArc(self.ANGLE / self.segments, self.radius)
        self.matricies, self.endMatrix = SplineMesh.ArcSegments(self.ANGLE / self.segments, self.bezierSpline.endPos, self.segments)
    else
        self.segments = math.Round(self.length / self.segment)
        if self.segments == 0 then self.segments = 1 end
        self.bezierSpline = SplineMesh.ApproximateStraight(self.length / self.segments)
        self.matricies, self.endMatrix = SplineMesh.StraightSegments(self.length, self.segments)
    end
end

function ENT:DeformMesh(MESH)

    MESH = SplineMesh.Deform(MESH, self.bezierSpline, self.segment, self.ROLL)

    return MESH
end