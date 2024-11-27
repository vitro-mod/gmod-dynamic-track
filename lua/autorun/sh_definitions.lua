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
        },
        doors = {
            {model = 'models/nekrasovskaya/depo_strelka_1_5_left_ostryak_1.mdl', pos = Vector(0.649*uim, 5.29*uim, 0), ang = Angle(0, -1.5, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_left_ostryak_2.mdl', pos = Vector(-0.797*uim, 5.29*uim, 0), ang = Angle(0, 0, 0)},
        }
    },
    ['models/nekrasovskaya/depo_strelka_1_5_right.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 19.5 * uim, 0), ang = Angle()},
            {pos = Vector(2.22 * uim, 19.312 * uim, 0), ang = Angle(0,-10.3,0)},
        },
        doors = {
            {model = 'models/nekrasovskaya/depo_strelka_1_5_right_ostryak_1.mdl', pos = Vector(-0.649*uim, 5.29*uim, 0), ang = Angle(0, 1.5, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_right_ostryak_2.mdl', pos = Vector(0.797*uim, 5.29*uim, 0), ang = Angle(0, 0, 0)},
        }
    },
    ['models/nekrasovskaya/depo_strelka_1_5_left_syezd.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 19.5 * uim, 0), ang = Angle()},
            {pos = Vector(-4.305 * uim, 18.375 * uim, 0), ang = Angle(0, 180, 0)},
            {pos = Vector(-4.305 * uim, 37.88 * uim, 0), ang = Angle()},
        },
        doors = {
            {model = 'models/nekrasovskaya/depo_strelka_1_5_left_ostryak_1.mdl', pos = Vector(0.649*uim, 5.29*uim, 0), ang = Angle(0, -1.5, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_left_ostryak_2.mdl', pos = Vector(-0.797*uim, 5.29*uim, 0), ang = Angle(0, 0, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_left_ostryak_1.mdl', pos = Vector((-0.649-4.305)*uim, (37.88-5.29)*uim, 0), ang = Angle(0, 180-1.5, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_left_ostryak_2.mdl', pos = Vector((0.797-4.305)*uim, (37.88-5.29)*uim, 0), ang = Angle(0, 180, 0)},
        }
    },
    ['models/nekrasovskaya/depo_strelka_1_5_right_syezd.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 19.5 * uim, 0), ang = Angle()},
            {pos = Vector(4.305 * uim, 18.375 * uim, 0), ang = Angle(0, 180, 0)},
            {pos = Vector(4.305 * uim, 37.88 * uim, 0), ang = Angle()},
        },
        doors = {
            {model = 'models/nekrasovskaya/depo_strelka_1_5_right_ostryak_1.mdl', pos = Vector(-0.649*uim, 5.29*uim, 0), ang = Angle(0, 1.5, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_right_ostryak_2.mdl', pos = Vector(0.797*uim, 5.29*uim, 0), ang = Angle(0, 0, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_right_ostryak_1.mdl', pos = Vector((0.649+4.305)*uim, (37.88-5.29)*uim, 0), ang = Angle(0, 180+1.5, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_right_ostryak_2.mdl', pos = Vector((-0.797+4.305)*uim, (37.88-5.29)*uim, 0), ang = Angle(0, 180, 0)},
        }
    },
}

for _,e in pairs(ents.FindByClass('splinemesh_static')) do
    e:SetupSnaps()

    if SERVER then
        for k,v in pairs(e.Doors) do
            v:Remove()
        end
        e:SpawnDoors()
    end
end
