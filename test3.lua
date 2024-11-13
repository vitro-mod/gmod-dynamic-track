for k,v in pairs(ents.FindByClass('splinemesh')) do v:Remove() end

local pos = Vector(0,-1000,0)
local ang = Angle(0,0,0)

local profile = {
    {l = 200, s = 3, r = 3000},
    {l = 300, s = 40, r = 3000},
    {l = 300, s = 5, r = 3000},
    {l = 300, s = -40, r = 3000},
    {l = 200, s = 3},
}
local plan = {
    {CURVE = false, LENGTH = 100},
    {CURVE = true, RADIUS = 600, ANGLE = 20},
    {CURVE = false, LENGTH = 100},
    {CURVE = true, RADIUS = 600, ANGLE = -20},
    {CURVE = false, LENGTH = 100},
    {CURVE = true, RADIUS = 600, ANGLE = -20},
    {CURVE = false, LENGTH = 100},
    {CURVE = true, RADIUS = 600, ANGLE = 20},
    {CURVE = false, LENGTH = 100},
}

SplineMesh.Spawn(pos, ang, plan, profile)
