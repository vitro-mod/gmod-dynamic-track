SplineMesh = SplineMesh or {}

---Get bounding box of mesh
--https://wiki.facepunch.com/gmod/util.GetModelMeshes
--@param mesh The mesh table like returned by util.GetModelMeshes
SplineMesh.GetBoundingBox = function(mesh)
    if not mesh or not mesh.verticies then
        error("SplineMesh.GetBoundingBox: Invalid mesh provided")
    end

    local firstPos = mesh.verticies[1].pos
    local minX, minY, minZ = firstPos:Unpack()
    local maxX, maxY, maxZ = minX, minY, minZ

    for k, v in pairs(mesh.verticies) do
        local x, y, z = v.pos:Unpack()

        if x < minX then minX = x end
        if y < minY then minY = y end
        if z < minZ then minZ = z end

        if x > maxX then maxX = x end
        if y > maxY then maxY = y end
        if z > maxZ then maxZ = z end
    end

    return Vector(minX, minY, minZ), Vector(maxX, maxY, maxZ)
end

SplineMesh.RotateXY = function(mesh)
    for k,v in pairs(mesh.verticies) do
        local x = v.pos.x
        v.pos.x = v.pos.y
        v.pos.y = -x
    end
end

SplineMesh.PhysicsRotateXY = function(physicsMesh)
    for k,v in pairs(physicsMesh) do
        local x = v.pos.x
        v.pos.x = v.pos.y
        v.pos.y = -x
    end
end