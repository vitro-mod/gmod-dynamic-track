AddCSLuaFile()
TOOL.Category   = 'SplineMesh'
TOOL.Name       = 'SplineMesh Tool'
TOOL.Command    = nil
TOOL.ConfigName = ''
TOOL.Information = {
    { name = 'left' },
    { name = 'right' },
    { name = 'reload' }
}
TOOL.ClientConVar = {}
TOOL.ClientConVar['model'] = 'models/nekrasovskaya/depo_strelka_1_5_left.mdl'
TOOL.ClientConVar['dynamic'] = 1
TOOL.ClientConVar['snapnum'] = 1
TOOL.ClientConVar['name'] = ''
TOOL.ClientConVar['anglegrid'] = 0
TOOL.ClientConVar['anglegrid_step'] = 1
TOOL.ClientConVar['is_curve'] = 0
TOOL.ClientConVar['curve_radius'] = 500
TOOL.ClientConVar['curve_angle'] = -20
TOOL.ClientConVar['track_length'] = 50
TOOL.ClientConVar['forward_axis'] = 'Y'
TOOL.ClientConVar['track_mesh_num'] = 1

local angle_opposite = Angle(0,180,0)

if CLIENT then
    language.Add('Tool.splinemesh.name', 'SplineMesh Tool')
    language.Add('Tool.splinemesh.desc', 'Adds or modifies splinemesh')
    language.Add('Tool.splinemesh.left', 'Create splinemesh')
    language.Add('Tool.splinemesh.right', 'Remove splinemesh')
    language.Add('Tool.splinemesh.reload', 'Read splinemesh')
end

function TOOL:LeftClick(trace)
    if not IsFirstTimePredicted() then return end
    if CLIENT then return true end
    if not trace.Hit then return false end

    local isDynamic = true
    if self.GetClientNumber then isDynamic = self:GetClientNumber('dynamic') == 1 end

    return isDynamic and self:SpawnDynamic(trace) or self:SpawnStatic(trace)
end

function TOOL:SpawnStatic(trace)
    local ent = ents.Create( 'splinemesh_static' )
    ent.Model = self:GetClientInfo('model')
    ent:SetModel(ent.Model)

    local pos, ang = self:GetPosAng(trace, ent)

    ent:SetName(self:GetClientInfo('name'))
    ent:SetPos(pos)
    ent:SetAngles( ang )
    ent:Spawn()

    undo.Create('splinemesh')
    undo.AddEntity(ent)
    undo.SetPlayer(self:GetOwner())
    undo.Finish()

    return true
end

function TOOL:SpawnDynamic(trace)
    local ent = ents.Create( 'splinemesh' )
    ent.Model = self:GetClientInfo('model')
    ent.TrackMeshNum = self:GetClientNumber('track_mesh_num')
    ent:SetModel(ent.Model)

    local pos, ang = self:GetPosAng(trace, ent)

    ent:SetPos(pos)
    ent:SetAngles( ang )
    ent.CURVE = self:GetClientNumber('is_curve') == 1
    ent.RADIUS = self:GetClientNumber('curve_radius')
    ent.ANGLE = self:GetClientNumber('curve_angle')
    ent.LENGTH = self:GetClientNumber('track_length')
    ent.FORWARD_AXIS = self:GetClientInfo('forward_axis')
    ent:Spawn()

    undo.Create('splinemesh')
    undo.AddEntity(ent)
    undo.SetPlayer(self:GetOwner())
    undo.Finish()

    return true
end

function TOOL:RightClick(trace)
    if not IsFirstTimePredicted() then return end

    if not trace.Hit then return false end
    if not IsValid(trace.Entity) then return false end
    if trace.Entity:GetClass() == 'splinemesh_clone' then
        if CLIENT then return true end
        SafeRemoveEntity(trace.Entity.parent)
    end
end

function TOOL:Reload(trace)
    if not IsFirstTimePredicted() then return end

    if CLIENT then
        if not SplineMesh.Definitions.Static[self:GetClientInfo('model')] then return false end
        local snapnum = self.ClientConVars['snapnum']
        snapnum:SetInt(snapnum:GetInt() + 1)
        if snapnum:GetInt() > #SplineMesh.Definitions.Static[self:GetClientInfo('model')].snaps then
            snapnum:SetInt(1)
        end
        -- return true
    end

    -- print(self:GetClientNumber('snapnum'))
end

-- function TOOL:Deploy()
--     print('deploy')
-- end

function TOOL:Holster()
end

TOOL.Color = Color(255,0,0)

function TOOL:UpdateGhost()
    local ent = self.GhostEntity
    if ( not IsValid( ent ) ) then return end

    local trace = self:GetOwner():GetEyeTrace()
    if ( not trace.Hit or IsValid( trace.Entity ) and ( trace.Entity:IsPlayer() ) ) then
        ent:SetNoDraw( true )
        return
    end

    local pos, ang = self:GetPosAng(trace, ent)

    ent:SetPos( pos )
    ent:SetAngles( ang )

    ent:SetNoDraw( false )
end

function TOOL:GetPosAng(trace, ent)
    local min = ent:OBBMins()
    local pos = trace.HitPos - trace.HitNormal * min.z
    local ang = trace.HitNormal:Angle()
    ang.x = ang.x + 90
    ang.y = self:GetOwner():GetAngles().y - 90

    if self:GetClientNumber('anglegrid') == 1 then
        local step = self:GetClientNumber('anglegrid_step')
        ang.y = math.floor((ang.y - (step / 2)) / step) * step + (step)
    end

    pos, ang = self:Snap(pos, ang)
    pos, ang = self:SnapIntersections(pos, ang)
    pos, ang = self:RotateSnap(pos, ang)

    return pos, ang
end

function TOOL:Snap(pos, ang)
    local resultPos = pos
    local resultAng = ang

    if CLIENT and InfMap then
        resultPos = InfMap.unlocalize_vector(resultPos, self:GetOwner().CHUNK_OFFSET)
    end

    for _,e in pairs(ents.FindByClass('splinemesh')) do
        if not e.Snaps then continue end

        for __,snap in pairs(e.Snaps) do
            if snap:GetTranslation():Distance2DSqr(resultPos) < 65 * 65 then
                resultPos = snap:GetTranslation()
                resultAng = snap:GetAngles()
            end
        end
    end

    for _,e in pairs(ents.FindByClass('splinemesh_static')) do
        if not e.Snaps then continue end

        for __,snap in pairs(e.Snaps) do
            if snap:GetTranslation():Distance2DSqr(resultPos) < 65 * 65 then
                resultPos = snap:GetTranslation()
                resultAng = snap:GetAngles()
            end
        end
    end

    if CLIENT and InfMap then
        resultPos = InfMap.localize_vector(resultPos)
    end

    return resultPos, resultAng
end

function TOOL:RotateSnap(pos, ang)
    if not self._pos then self._pos = Vector(pos) end

    local resultPos = pos
    local resultAng = ang

    local staticDef = SplineMesh.Definitions.Static[self:GetClientInfo('model')]
    if not staticDef then return resultPos, resultAng end
    if not staticDef.snaps then return resultPos, resultAng end

    local snap = staticDef.snaps[self:GetClientNumber('snapnum')]

    if not snap then return resultPos, resultAng end

    self._pos:Set(snap.pos)

    ang:Sub(snap.ang)
    ang:Add(angle_opposite)
    self._pos:Rotate(ang)
    pos:Sub(self._pos)

    if self:GetOwner():KeyDown(IN_SPEED) and staticDef.center then
        if not self._center then self._center = Vector(staticDef.center) end
        self._center:Set(staticDef.center)
        self._center:Rotate(ang)
        pos:Add((self._pos - self._center))
    end

    return resultPos, resultAng
end

function TOOL:SnapIntersections(pos, ang)
    local resultPos = pos
    local resultAng = ang

    if not self:GetOwner():KeyDown(IN_SPEED) then return resultPos, resultAng end

    if CLIENT and InfMap then
        resultPos = InfMap.unlocalize_vector(resultPos, self:GetOwner().CHUNK_OFFSET)
    end

    -- if not CLIENT then return resultPos, resultAng end

    local potentialIntersections = {}
    for _,e in pairs(ents.FindInSphere(pos, 2000)) do
        if e:GetClass() ~= 'splinemesh_static' then continue end
        if not e.Snaps then continue end

        for __,snap in pairs(e.Snaps) do
            -- render.DrawSphere( snap:GetTranslation(), 10, 10, 10, Color( 255, 0, 0) )
            table.insert(potentialIntersections, {
                start = snap:GetTranslation(),
                finish = snap:GetTranslation() + snap:GetAngles():Right() * 3000,
                angle = snap:GetAngles(),
                entity = e
            })
        end
    end

    local lastMin = 10000
    local lastSnap = {}

    for k,v in pairs(potentialIntersections) do
        for k2,v2 in pairs(potentialIntersections) do
            if k2 <= k then continue end
            local abs1 = math.abs(v.angle.y)
            local abs2 = math.abs(v2.angle.y)
            if abs1 - abs2 < 1 then continue end
            if abs1 - abs2 > 179.5 and abs1 - abs2 < 180.5 then continue end

            local isIntersecting, dist1, dist2 = util.IsRayIntersectingRay(v.start, v.finish, v2.start, v2.finish)
            local point = v.angle:Right() * dist1 + v.start
            if CLIENT then
                cam.Start3D()
                if isIntersecting then 
                    local start, start_co = InfMap.localize_vector(v.start)
                    local pnt, pnt_co = InfMap.localize_vector(point)
                    local lpco = self:GetOwner().CHUNK_OFFSET
                    if lpco:IsEqualTol(pnt_co, 0.1) and lpco:IsEqualTol(pnt_co, 0.1) then
                        -- render.DrawLine(start, pnt, self.Color)
                        render.DrawSphere( pnt, 10, 5, 5, self.Color )
                    end
                end
                cam.End3D()
            end
            if point:Distance2DSqr(resultPos) < 65 * 65 then
                resultPos = point
                local plAngle = self:GetOwner():GetAngles().y
                -- print(plAngle, v.angle.y, v2.angle.y )
                -- resultAng = (plAngle - v2.angle.y < plAngle - v.angle.y) and v2.angle or v.angle
                resultAng = v.angle
                -- print(v.angle, v2.angle)
                -- if point:Distance2DSqr(resultPos) < lastMin then
                --     lastSnap = {pos = point, ang = v2.angle}
                --     lastMin = point:Distance2DSqr(resultPos)
                -- end
            end
        end
    end

    -- if (lastSnap.pos) then
    --     resultPos = lastSnap.pos
    --     resultAng = lastSnap.ang
    -- end

    if CLIENT and InfMap then
        resultPos = InfMap.localize_vector(resultPos)
    end

    return resultPos, resultAng
end

function TOOL:Think()
    -- local isDynamic = true
    -- if self.GetClientNumber then isDynamic = self:GetClientNumber('dynamic') == 1 end

    if not self.GhostEntity then
        self:MakeGhostEntity(self:GetClientInfo('model'), vector_origin, angle_zero )
    end
end

function TOOL:DrawHUD()
    self:UpdateGhost()
end
-- if SERVER then util.AddNetworkString('splinemesh_tool') end
-- TOOL.settings = TOOL.settings or {}

-- TOOL.NotBuilt = true

-- function TOOL:Think()
--     if CLIENT and (self.NotBuilt or self.NeedUpdate) then
--         self:BuildCPanel()
--         self.NotBuilt = false
--         self.NeedUpdate = false
--     end
-- end

-- local function SendSettings(self)
--     self.settings = self.settings or {}
--     net.Start('splinemesh_tool')
--     net.WriteTable(self.settings)
--     net.SendToServer()
-- end

-- net.Receive('vitromod_belltool_send', function(_, ply)
--     local TOOL = LocalPlayer and LocalPlayer():GetTool('splinemesh') or ply:GetTool('splinemesh')
--     TOOL.settings = net.ReadTable()
--     if CLIENT then
--         TOOL.NeedUpdate = true
--     end
-- end)

local function buildPropTable(modelList)
    local result = {}
    for k,v in pairs(modelList) do
        result[k] = {model = k}
    end
    return result
end

function TOOL:BuildCPanel()
    local CPanel = controlpanel.Get('splinemesh')
    if not CPanel then return end

    self.UI = {}

    CPanel:ClearControls()
    CPanel:SetPadding(0)
    CPanel:SetSpacing(0)
    CPanel:Dock( FILL )

    self.UI.DynamicButton = CPanel:Button('Dynamic', 'splinemesh_dynamic', '1')
    self.UI.StaticButton = CPanel:Button('Static', 'splinemesh_dynamic', '0')

    local isDynamic = true
    if self.GetClientNumber then
        isDynamic = self:GetClientNumber('dynamic') == 1
    end

    if isDynamic then
        self.UI.DynamicModels = CPanel:PropSelect('Dynamic models:', 'splinemesh_model', buildPropTable(SplineMesh.Definitions.Dynamic))

        self.UI.IsCurve = CPanel:CheckBox('Curve', 'splinemesh_is_curve')
        self.UI.Radius = CPanel:NumSlider('Curve Radius: ', 'splinemesh_curve_radius', 0, 10000, 0)
        self.UI.Angle = CPanel:NumSlider('Curve Angle: ', 'splinemesh_curve_angle', -180, 180, 0)
        self.UI.Length = CPanel:NumSlider('Track Length: ', 'splinemesh_track_length', 0, 1000, 0)
    else
        self.UI.StaticModels = CPanel:PropSelect('Static models:', 'splinemesh_model', buildPropTable(SplineMesh.Definitions.Static))

        self.UI.Name = CPanel:TextEntry('Name: ', 'splinemesh_name')
    end

    cvars.AddChangeCallback('splinemesh_model', function(convar_name, value_old, value_new)
        if not isDynamic then return end
        GetConVar('splinemesh_forward_axis'):SetString(SplineMesh.Definitions.Dynamic[value_new].forward_axis or 'Y')
        GetConVar('splinemesh_track_mesh_num'):SetInt(SplineMesh.Definitions.Dynamic[value_new].track_mesh_num or 1)
    end)
    
    self.UI.AngleGrid = CPanel:CheckBox('Snap to angle grid: ', 'splinemesh_anglegrid')
    self.UI.AngleGridStep = CPanel:NumSlider('Angle grid step: ', 'splinemesh_anglegrid_step', 1, 90, 0)

    if self.UpdateCPanel then self:UpdateCPanel() end
end

function TOOL:MakeGhostEntity(model, pos, angle)
    util.PrecacheModel(model)
    -- We do ghosting serverside in single player
    -- It's done clientside in multiplayer
    if SERVER and not game.SinglePlayer() then return end
    if CLIENT and game.SinglePlayer() then return end
    -- The reason we need this is because in multiplayer, when you holster a tool serverside,
    -- either by using the spawnnmenu's Weapons tab or by simply entering a vehicle,
    -- the Think hook is called once after Holster is called on the client, recreating the ghost entity right after it was removed.
    if not IsFirstTimePredicted() then return end
    -- Release the old ghost entity
    self:ReleaseGhostEntity()
    -- Don't allow ragdolls/effects to be ghosts
    if not util.IsValidProp(model) then return end
    if CLIENT then
        self.GhostEntity = ents.CreateClientProp(model)
    else
        self.GhostEntity = ents.Create('prop_physics')
    end

    -- If there's too many entities we might not spawn..
    if not IsValid(self.GhostEntity) then
        self.GhostEntity = nil
        return
    end

    self.GhostEntity:SetModel(model)
    self.GhostEntity:SetPos(pos)
    self.GhostEntity:SetAngles(angle)
    self.GhostEntity:Spawn()
    -- We do not want physics at all
    self.GhostEntity:PhysicsDestroy()
    -- SOLID_NONE causes issues with Entity.NearestPoint used by Wheel tool
    --self.GhostEntity:SetSolid( SOLID_NONE )
    self.GhostEntity:SetMoveType(MOVETYPE_NONE)
    self.GhostEntity:SetNotSolid(true)
    self.GhostEntity:SetRenderMode(RENDERMODE_TRANSCOLOR)
    -- self.GhostEntity:SetColor(Color(255, 255, 255, 150))
    -- Do not save this thing in saves/dupes
    self.GhostEntity.DoNotDuplicate = true
    -- Mark this entity as ghost prop for other code
    self.GhostEntity.IsToolGhost = true
end

cvars.RemoveChangeCallback('splinemesh_dynamic', 'splinemesh_dynamic_tool')
cvars.AddChangeCallback('splinemesh_dynamic', function(convar, old, new)
    if not CLIENT then return end
    if not LocalPlayer then return end

    local localPlayer = LocalPlayer()
    if not localPlayer.GetTool then return end

    local TOOL = LocalPlayer():GetTool('splinemesh')
    if TOOL.BuildCPanel then TOOL:BuildCPanel() end

end, 'splinemesh_dynamic_tool')

cvars.RemoveChangeCallback('splinemesh_model', 'splinemesh_model_tool')
cvars.AddChangeCallback('splinemesh_model', function(convar, old, new)
    if not CLIENT then return end
    if not LocalPlayer then return end

    local localPlayer = LocalPlayer()
    if not localPlayer.GetTool then return end

    local TOOL = LocalPlayer():GetTool('splinemesh')
    TOOL:ReleaseGhostEntity()
    TOOL.ClientConVars['snapnum']:SetInt(1)

end, 'splinemesh_model_tool')
