for k,v in pairs(ents.FindByClass('splinemesh')) do v:Remove() end

local melon = ents.Create( "splinemesh" ) -- Spawn prop
if ( !IsValid( melon ) ) then return end -- Safety first
melon:SetPos( Vector(0,-1000,100) ) -- Set pos where is player looking
melon:SetAngles(Angle(0,0,0))
melon.CURVE = false
melon.LENGTH = 100
melon:Spawn() -- Instantiate prop