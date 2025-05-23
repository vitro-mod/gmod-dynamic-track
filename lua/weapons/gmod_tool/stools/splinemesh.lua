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

	return self:SpawnStatic(trace)
end

function TOOL:SpawnStatic(trace)
	local ent = ents.Create( "splinemesh_static" )
	ent.Model = self:GetClientInfo('model')
	ent:SetModel(ent.Model)

	local pos, ang = self:GetPosAng(trace, ent)

	ent:SetName(self:GetClientInfo('name'))
	ent:SetPos(pos)
	ent:SetAngles( ang )
	ent:Spawn()

	undo.Create("splinemesh")
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
-- 	print('deploy')
-- end

function TOOL:Holster()
end

TOOL.Color = Color(255,0,0)

function TOOL:UpdateGhost()
	local ent = self.GhostEntity
	if ( !IsValid( ent ) ) then return end

	local trace = self:GetOwner():GetEyeTrace()
	if ( !trace.Hit or IsValid( trace.Entity ) and ( trace.Entity:IsPlayer() ) ) then
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

	for _,e in pairs(ents.FindByClass('splinemesh_static')) do
		if not e.Snaps then continue end

		for __,snap in pairs(e.Snaps) do
			if snap:GetTranslation():Distance2DSqr(resultPos) < 80 * 80 then
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
	
	for k,v in pairs(potentialIntersections) do
		for k2,v2 in pairs(potentialIntersections) do
			if k == k2 then continue end
			local abs1 = math.abs(v.angle.y)
			local abs2 = math.abs(v2.angle.y)
			if abs1 - abs2 < 1 then continue end
			if abs1 - abs2 > 179.5 and abs1 - abs2 < 180.5 then continue end
			
			local isIntersecting, dist1, dist2 = util.IsRayIntersectingRay(v.start, v.finish, v2.start, v2.finish)
			local point = v.angle:Right() * dist1 + v.start
			if CLIENT then
				cam.Start3D()
				if isIntersecting then render.DrawLine(v.start, point, self.Color) end
				if isIntersecting then render.DrawSphere( point, 10, 10, 10, self.Color ) end
				cam.End3D()
			end
			if point:Distance2DSqr(resultPos) < 80 * 80 then
				resultPos = point
				-- resultAng = (self:GetOwner():GetAngles().y - v2.angle.y < self:GetOwner():GetAngles().y - v.angle.y) and v2.angle or v.angle
				resultAng = v2.angle
			end
		end
	end

	if CLIENT and InfMap then
		resultPos = InfMap.localize_vector(resultPos)
	end

	return resultPos, resultAng
end

function TOOL:Think()
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
-- 		self:BuildCPanel()
-- 		self.NotBuilt = false
--         self.NeedUpdate = false
-- 	end
-- end

-- local function SendSettings(self)
-- 	self.settings = self.settings or {}
-- 	net.Start('splinemesh_tool')
-- 	net.WriteTable(self.settings)
-- 	net.SendToServer()
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
		self.UI.DynamicModels = CPanel:PropSelect('Dynamic models:', 'splinemesh_model', {
			['models/mn_r/mn_r.mdl'] = {model = 'models/mn_r/mn_r.mdl'},
			['models/metrostroi/tracks/tunnel256_gamma.mdl'] = {model = 'models/metrostroi/tracks/tunnel256_gamma.mdl'}
		})
	else
		self.UI.StaticModels = CPanel:PropSelect('Static models:', 'splinemesh_model', buildPropTable(SplineMesh.Definitions.Static))

		self.UI.Name = CPanel:TextEntry('Name: ', 'splinemesh_name')
	end
	
	self.UI.AngleGrid = CPanel:CheckBox('Snap to angle grid: ', 'splinemesh_anglegrid')
	self.UI.AngleGridStep = CPanel:NumSlider('Angle grid step: ', 'splinemesh_anglegrid_step', 1, 90, 0)

	if self.UpdateCPanel then self:UpdateCPanel() end
end

cvars.RemoveChangeCallback('splinemesh_dynamic', 'splinemesh_dynamic_tool')
cvars.AddChangeCallback('splinemesh_dynamic', function(convar, old, new)
	if not CLIENT then return end
	if not LocalPlayer then return end

	local localPlayer = LocalPlayer()
	if not localPlayer.GetTool then return end

	local TOOL = LocalPlayer():GetTool("splinemesh")
	if TOOL.BuildCPanel then TOOL:BuildCPanel() end

end, 'splinemesh_dynamic_tool')

cvars.RemoveChangeCallback('splinemesh_model', 'splinemesh_model_tool')
cvars.AddChangeCallback('splinemesh_model', function(convar, old, new)
	if not CLIENT then return end
	if not LocalPlayer then return end

	local localPlayer = LocalPlayer()
	if not localPlayer.GetTool then return end

	local TOOL = LocalPlayer():GetTool("splinemesh")
	TOOL:ReleaseGhostEntity()
	TOOL.ClientConVars['snapnum']:SetInt(1)

end, 'splinemesh_model_tool')
