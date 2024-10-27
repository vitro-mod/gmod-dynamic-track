SplineMesh = SplineMesh || {}

---Get bounding box of mesh
--https://wiki.facepunch.com/gmod/util.GetModelMeshes
--@param mesh The mesh table like returned by util.GetModelMeshes
SplineMesh.GetBoundingBox = function(mesh)
    local minX, minY, minZ = mesh.verticies[1].pos:Unpack()
    local maxX, maxY, maxZ = mesh.verticies[1].pos:Unpack()


    for k,v in pairs (mesh.verticies) do
        if v.pos.x < minX then minX = v.pos.x end
        if v.pos.y < minY then minY = v.pos.y end
        if v.pos.z < minZ then minZ = v.pos.z end
        
        if v.pos.x > maxX then maxX = v.pos.x end
        if v.pos.y > maxY then maxY = v.pos.y end
        if v.pos.z > maxZ then maxZ = v.pos.z end
    end

    local min = Vector(minX, minY, minZ)
    local max = Vector(maxX, maxY, maxZ)

    return min, max
end

SplineMesh.RotateXY = function(mesh)
    for k,v in pairs (mesh.verticies) do
        local x = v.pos.x
        v.pos.x = v.pos.y
        v.pos.y = -x
    end
end