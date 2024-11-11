for k,v in pairs(ents.FindByClass('splinemesh')) do v:Remove() end

local pos = Vector(0,-1000,100)
local ang = Angle(0,0,0)
local plan = {
    {CURVE = false, LENGTH = 600},
    {CURVE = true, RADIUS = 600, ANGLE = 60},
    {CURVE = false, LENGTH = 600},
    {CURVE = true, RADIUS = 600, ANGLE = -45},
}

local splinemeshes = {}

for k,planElement in pairs(plan) do

    splinemeshes[k] = ents.Create( "splinemesh" ) -- Spawn prop
    if ( !IsValid( splinemeshes[k] ) ) then return end -- Safety first

    if k > 1 then
        local worldEndMatrix = splinemeshes[k-1].OrigMatrix * splinemeshes[k-1].endMatrix
        pos = worldEndMatrix:GetTranslation()
        ang = worldEndMatrix:GetAngles()
    end

    splinemeshes[k]:SetPos( pos ) -- Set pos where is player looking
    splinemeshes[k]:SetAngles( ang ) -- Set pos where is player looking

    for planKey,planValue in pairs(planElement) do
        splinemeshes[k][planKey] = planValue
    end

    splinemeshes[k]:Spawn() -- Instantiate prop
end