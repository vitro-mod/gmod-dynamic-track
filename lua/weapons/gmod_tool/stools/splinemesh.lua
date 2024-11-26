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

if CLIENT then
	language.Add('Tool.splinemesh.name', 'SplineMesh Tool')
	language.Add('Tool.splinemesh.desc', 'Adds or modifies splinemesh')
	language.Add('Tool.splinemesh.left', 'Create splinemesh')
	language.Add('Tool.splinemesh.right', 'Remove splinemesh')
	language.Add('Tool.splinemesh.reload', 'Read splinemesh')
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	if not trace.Hit then return false end

	PrintTable(trace)

	local ent = ents.Create( "splinemesh_static" )
	ent.Model = self:GetClientInfo('model')
	ent:SetPos(trace.HitPos)
	local ang = trace.HitNormal:Angle()
	ang.pitch = ang.pitch + 90
	ang.y = self:GetOwner():GetAngles().y - 90
	ent:SetAngles( ang )
	ent:Spawn()

	undo.Create("splinemesh")
	undo.AddEntity(ent)
	undo.SetPlayer(self:GetOwner())
	undo.Finish()

	return true
end

function TOOL:RightClick(trace)
end

function TOOL:Reload(trace)
end

-- function TOOL:Deploy()
-- 	print('deploy')
-- end

function TOOL:Holster()
end

function TOOL:UpdateGhost( ent, ply )

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()
	if ( !trace.Hit or IsValid( trace.Entity ) and ( trace.Entity:IsPlayer() ) ) then

		ent:SetNoDraw( true )
		return

	end

	local ang = trace.HitNormal:Angle()
	ang.pitch = ang.pitch + 90

	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ang.y = ply:GetAngles().y - 90
	ent:SetAngles( ang )

	ent:SetNoDraw( false )

end

function TOOL:Think()
	if not self.GhostEntity then
		self:MakeGhostEntity(self:GetClientInfo('model'), vector_origin, angle_zero )
	end

	self:UpdateGhost( self.GhostEntity, self:GetOwner() )
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
		self.UI.StaticModels = CPanel:PropSelect('Static models:', 'splinemesh_model', {
			['models/nekrasovskaya/depo_strelka_1_5_left.mdl'] = {model = 'models/nekrasovskaya/depo_strelka_1_5_left.mdl'},
			['models/nekrasovskaya/depo_strelka_1_5_left_syezd.mdl'] = {model = 'models/nekrasovskaya/depo_strelka_1_5_left_syezd.mdl'},
			['models/nekrasovskaya/depo_strelka_1_5_right.mdl'] = {model = 'models/nekrasovskaya/depo_strelka_1_5_right.mdl'},
			['models/nekrasovskaya/depo_strelka_1_5_right_syezd.mdl'] = {model = 'models/nekrasovskaya/depo_strelka_1_5_right_syezd.mdl'},
		})
	end

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

end, 'splinemesh_model_tool')