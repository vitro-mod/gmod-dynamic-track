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
