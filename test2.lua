for k,v in pairs(ents.FindByClass('splinemesh')) do v:Remove() end

local melon = ents.Create( "splinemesh" ) -- Spawn prop
if ( !IsValid( melon ) ) then return end -- Safety first
melon:SetPos( Vector(0,-1000,100) ) -- Set pos where is player looking
melon:SetAngles(Angle(0,0,0))
melon.CURVE = false
melon.LENGTH = 600
melon:Spawn() -- Instantiate prop

local melon1 = ents.Create( "splinemesh" ) -- Spawn prop
if ( !IsValid( melon1 ) ) then return end -- Safety first
local worldEndMatrix = melon.OrigMatrix * melon.endMatrix
local pos = worldEndMatrix:GetTranslation()
local ang = worldEndMatrix:GetAngles()
melon1:SetPos( pos ) -- Set pos where is player looking
melon1:SetAngles( ang ) -- Set pos where is player looking
melon1.CURVE = true
melon1.RADIUS = 800
melon1.ANGLE = 60
melon1:Spawn() -- Instantiate prop

local melon2 = ents.Create( "splinemesh" ) -- Spawn prop
if ( !IsValid( melon2 ) ) then return end -- Safety first
local worldEndMatrix = melon1.OrigMatrix * melon1.endMatrix
local pos = worldEndMatrix:GetTranslation()
local ang = worldEndMatrix:GetAngles()
melon2:SetPos( pos ) -- Set pos where is player looking
melon2:SetAngles( ang ) -- Set pos where is player looking
melon2.CURVE = false
melon2.LENGTH = 600
melon2:Spawn() -- Instantiate prop

local melon3 = ents.Create( "splinemesh" ) -- Spawn prop
if ( !IsValid( melon3 ) ) then return end -- Safety first
local worldEndMatrix = melon2.OrigMatrix * melon2.endMatrix
local pos = worldEndMatrix:GetTranslation()
local ang = worldEndMatrix:GetAngles()
melon3:SetPos( pos ) -- Set pos where is player looking
melon3:SetAngles( ang ) -- Set pos where is player looking
melon3.CURVE = true
melon3.RADIUS = 600
melon3.ANGLE = -45
melon3:Spawn() -- Instantiate prop
