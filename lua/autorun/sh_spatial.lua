SplineMesh = SplineMesh or {}
SplineMesh.Spatial = {}
SplineMesh.Spatial.CELL_SIZE = 50
SplineMesh.Spatial.Lookup = {}

local empty_table = {}

function SplineMesh.Spatial.Indexes(vector)
    return math.floor(vector.x/SplineMesh.Spatial.CELL_SIZE),
        math.floor(vector.y/SplineMesh.Spatial.CELL_SIZE), 
        math.floor(vector.z/SplineMesh.Spatial.CELL_SIZE)
end

function SplineMesh.Spatial.Insert(vector, key)
    local ix, iy, iz = SplineMesh.Spatial.Indexes(vector)
    SplineMesh.Spatial.Lookup[ix] = SplineMesh.Spatial.Lookup[ix] or {}
    SplineMesh.Spatial.Lookup[ix][iy] = SplineMesh.Spatial.Lookup[ix][iy] or {}
    SplineMesh.Spatial.Lookup[ix][iy][iz] = SplineMesh.Spatial.Lookup[ix][iy][iz] or {}
    SplineMesh.Spatial.Lookup[ix][iy][iz][key] = true
end

function SplineMesh.Spatial.Neighbours(vector)
    local ix, iy, iz = SplineMesh.Spatial.Indexes(vector)
    local lookup = SplineMesh.Spatial.Lookup
    if not lookup[ix] or not lookup[ix][iy] or not lookup[ix][iy][iz] then return empty_table end

    local result = {}

end
