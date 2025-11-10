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
            {model = 'models/nekrasovskaya/depo_strelka_1_5_left_ostryak_1.mdl', opendir = '1', pos = Vector(0.649*uim, 5.29*uim, 0), ang = Angle(0, -1.5, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_left_ostryak_2.mdl', opendir = '1', pos = Vector(-0.797*uim, 5.29*uim, 0), ang = Angle(0, 0, 0)},
        },
        snapCenter = true,
    },
    ['models/nekrasovskaya/depo_strelka_1_5_right.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 19.5 * uim, 0), ang = Angle()},
            {pos = Vector(2.22 * uim, 19.312 * uim, 0), ang = Angle(0,-10.3,0)},
        },
        doors = {
            {model = 'models/nekrasovskaya/depo_strelka_1_5_right_ostryak_1.mdl', opendir = '2', pos = Vector(-0.649*uim, 5.29*uim, 0), ang = Angle(0, 1.5, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_right_ostryak_2.mdl', opendir = '2', pos = Vector(0.797*uim, 5.29*uim, 0), ang = Angle(0, 0, 0)},
        },
        snapCenter = true,
    },
    ['models/nekrasovskaya/depo_strelka_1_5_left_syezd.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 19.5 * uim, 0), ang = Angle()},
            {pos = Vector(-4.305 * uim, 18.375 * uim, 0), ang = Angle(0, 180, 0)},
            {pos = Vector(-4.305 * uim, 37.88 * uim, 0), ang = Angle()},
        },
        doors = {
            {model = 'models/nekrasovskaya/depo_strelka_1_5_left_ostryak_1.mdl', opendir = '1', pos = Vector(0.649*uim, 5.29*uim, 0), ang = Angle(0, -1.5, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_left_ostryak_2.mdl', opendir = '1', pos = Vector(-0.797*uim, 5.29*uim, 0), ang = Angle(0, 0, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_left_ostryak_1.mdl', opendir = '1', pos = Vector((-0.649-4.305)*uim, (37.88-5.29)*uim, 0), ang = Angle(0, 180-1.5, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_left_ostryak_2.mdl', opendir = '1', pos = Vector((0.797-4.305)*uim, (37.88-5.29)*uim, 0), ang = Angle(0, 180, 0)},
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
            {model = 'models/nekrasovskaya/depo_strelka_1_5_right_ostryak_1.mdl', opendir = '2', pos = Vector(-0.649*uim, 5.29*uim, 0), ang = Angle(0, 1.5, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_right_ostryak_2.mdl', opendir = '2', pos = Vector(0.797*uim, 5.29*uim, 0), ang = Angle(0, 0, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_right_ostryak_1.mdl', opendir = '2', pos = Vector((0.649+4.305)*uim, (37.88-5.29)*uim, 0), ang = Angle(0, 180+1.5, 0)},
            {model = 'models/nekrasovskaya/depo_strelka_1_5_right_ostryak_2.mdl', opendir = '2', pos = Vector((-0.797+4.305)*uim, (37.88-5.29)*uim, 0), ang = Angle(0, 180, 0)},
        }
    },
    ['models/nekrasovskaya/depo_track_71.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 71, 0), ang = Angle()},
        }
    },
    ['models/nekrasovskaya/depo_track_151.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 151, 0), ang = Angle()},
        }
    },
    ['models/nekrasovskaya/depo_track_188.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 188, 0), ang = Angle()},
        }
    },
    ['models/nekrasovskaya/depo_track_256.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 256, 0), ang = Angle()},
        }
    },
    ['models/nekrasovskaya/depo_track_352.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 352, 0), ang = Angle()},
        }
    },
    ['models/nekrasovskaya/depo_track_447.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 447, 0), ang = Angle()},
        }
    },
    ['models/nekrasovskaya/depo_track_512.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(0, 512, 0), ang = Angle()},
        }
    },
    ['models/nekrasovskaya/depo_track_768_povorot_10p25.mdl'] = {
        snaps = {
            {pos = Vector(), ang = Angle(0, 180, 0)},
            {pos = Vector(1.305 * uim, 14.55 * uim, 0), ang = Angle(0,-10.3,0)},
        },
        snapCenter = true,
    },
}

SplineMesh.Definitions.Dynamic = {
    ['models/mn_r/mn_r.mdl'] = {
        model = 'models/mn_r/mn_r.mdl',
        forward_axis = 'X',
        track_mesh_num = 1,
    },
    ['models/metrostroi/tracks/metrotrack_256.mdl'] = {
        model = 'models/metrostroi/tracks/metrotrack_256.mdl',
        forward_axis = 'Y',
        track_mesh_num = 3,
    },
    ['models/metrostroi/tracks/tunnel256_gamma.mdl'] = {
        model = 'models/metrostroi/tracks/tunnel256_gamma.mdl',
        forward_axis = 'Y',
        track_mesh_num = 3,
    },
    ['models/mn_r/mn_t_rn1.mdl'] = {
        model = 'models/mn_r/mn_t_rn1.mdl',
        forward_axis = 'X',
        track_mesh_num = 1,
    },
    ['models/kalininskaya/tunnel_roundnew_512.mdl'] = {
        model = 'models/kalininskaya/tunnel_roundnew_512.mdl',
        forward_axis = 'Y',
        track_mesh_num = 4,
    },
    ['models/kalininskaya/tunnel_kvadrat_512.mdl'] = {
        model = 'models/kalininskaya/tunnel_kvadrat_512.mdl',
        forward_axis = 'Y',
        track_mesh_num = 4,
    },
}

local function countCenters()
    for k,v in pairs(SplineMesh.Definitions.Static) do
        if not v.snapCenter then continue end

        local start = v.snaps[1].pos
        local finish = v.snaps[1].pos + (v.snaps[1].ang + Angle(0,180,0)):Right():GetNegated() * 2000
        local divergingStart = v.snaps[#v.snaps].pos
        local divergingFinish = v.snaps[#v.snaps].pos + v.snaps[#v.snaps].ang:Right() * finish.y

        local isIntersecting, dist1, dist2 = util.IsRayIntersectingRay(start, finish, divergingStart, divergingFinish)

        v.center = start + Vector(0, dist1, 0)
        -- debugoverlay.Line(divergingStart, Vector(0, dist1, 0), 10, Color(255,255,0), true)
        -- debugoverlay.Line(start, finish, 10, Color(255,255,0), true)
    end
end

local function reloadSnaps()
    for _,e in pairs(ents.FindByClass('splinemesh_static')) do
        e:SetupSnaps()
    end
end

local function reloadDoors()
    if not SERVER then return end
    for _,e in pairs(ents.FindByClass('splinemesh_static')) do
        for k,v in pairs(e.Doors) do
            v:Remove()
        end
        e:SpawnDoors()
    end
end

countCenters()
reloadSnaps()
reloadDoors()