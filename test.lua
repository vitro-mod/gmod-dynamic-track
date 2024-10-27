for k,v in pairs(ents.FindByClass('splinemesh')) do v:Remove() end

local melon = ents.Create( "splinemesh" ) -- Spawn prop
if ( !IsValid( melon ) ) then return end -- Safety first
melon:SetPos( Vector(0,-1000,0) ) -- Set pos where is player looking
melon:SetAngles(Angle(0,0,0))
melon.CURVE = true
melon.RADIUS = 500
melon.ANGLE = -20
melon:Spawn() -- Instantiate prop

local melon2 = ents.Create( "splinemesh" ) -- Spawn prop
if ( !IsValid( melon2 ) ) then return end -- Safety first
local pos = (melon.OrigMatrix * melon.endMatrix):GetTranslation()
local chunk
pos, chunk = InfMap.localize_vector(pos)
local ang = melon:LocalToWorldAngles(melon.endMatrix:GetAngles())
melon2:SetPos( pos ) -- Set pos where is player looking
melon2:SetAngles( ang ) -- Set pos where is player looking
melon2.CURVE = false
melon2.LENGTH = 100
melon2:Spawn() -- Instantiate prop
InfMap.prop_update_chunk(melon2, chunk)

local melon3 = ents.Create( "splinemesh" ) -- Spawn prop
if ( !IsValid( melon3 ) ) then return end -- Safety first
local pos = (melon2.OrigMatrix * melon2.endMatrix):GetTranslation()
local chunk
pos, chunk = InfMap.localize_vector(pos)
local ang = melon2:LocalToWorldAngles(melon2.endMatrix:GetAngles())
melon3:SetPos( pos ) -- Set pos where is player looking
melon3:SetAngles( ang ) -- Set pos where is player looking
melon3.CURVE = true
melon3.RADIUS = 500
melon3.ANGLE = 20
melon3:Spawn() -- Instantiate prop
InfMap.prop_update_chunk(melon3, chunk)
