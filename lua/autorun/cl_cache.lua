SplineMesh = SplineMesh or {}
SplineMesh.Cache = SplineMesh.Cache or {}
SplineMesh.Cache.Entries = SplineMesh.Cache.Entries or {}

function SplineMesh.Cache.Set(key, value)
    SplineMesh.Cache.Entries[key] = value
end

function SplineMesh.Cache.Get(key)
    return SplineMesh.Cache.Entries[key]
end

function SplineMesh.Cache.Clear()
    SplineMesh.Cache.Entries = {}
end

concommand.Add("splinemesh_cache_clear", function()
    SplineMesh.Cache.Clear()
    print("[SplineMesh] Cache cleared.")
end)