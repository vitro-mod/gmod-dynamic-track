for k,v in pairs(ents.FindByClass('splinemesh')) do v:Remove() end

local plan = {
    {CURVE = false, LENGTH = 600},
    {CURVE = true, RADIUS = 800, ANGLE = 60},
    {CURVE = false, LENGTH = 600},
    {CURVE = true, RADIUS = 600, ANGLE = -45},
}

SplineMesh.Spawn(Vector(0, -1000, 100), Angle(), plan)
