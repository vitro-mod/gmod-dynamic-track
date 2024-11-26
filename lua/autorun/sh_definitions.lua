SplineMesh = SplineMesh or {}

SplineMesh.METERS_IN_UNIT = 0.01905 --0.0254*0.75
SplineMesh.UNITS_IN_METER = 1 / 0.01905

local uim = SplineMesh.UNITS_IN_METER

SplineMesh.Definitions = {}
SplineMesh.Definitions.Static = {
    ['models/nekrasovskaya/depo_strelka_1_5_left.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 19.5 * uim, 0), ang = Angle()},
            {pos = Vector(-2.22 * uim, 19.312 * uim, 0), ang = Angle(0,10.3,0)},
        }
    },
    ['models/nekrasovskaya/depo_strelka_1_5_right.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 19.5 * uim, 0), ang = Angle()},
            {pos = Vector(2.22 * uim, 19.312 * uim, 0), ang = Angle(0,-10.3,0)},
        }
    },
}

for _,e in pairs(ents.FindByClass('splinemesh_static')) do
    e:SetupSnaps()
end
