SplineMesh = SplineMesh or {}

SplineMesh.Deform = function(mesh, spline, scale, roll, offset)
    local superelevation = Angle(roll, 0, 0)
    local derivative = spline:Derivative()
    local seen = {}

    for _, vertex in ipairs(mesh.verticies) do
        if not seen[vertex] then
            seen[vertex] = true
            local pos = vertex.pos + offset
            local t = pos.y / scale
            local tangent = derivative:Sample(t)
            if tangent:LengthSqr() == 0 then
                tangent = Vector(0, 1, 0)
            else
                tangent:Normalize()
            end

            vertex.pos = spline:Sample(t) + Vector(tangent.y * pos.x, -tangent.x * pos.x, pos.z)
            vertex.pos:Rotate(superelevation)

            if vertex.normal then
                local normal = vertex.normal
                vertex.normal = Vector(
                    tangent.y * normal.x + tangent.x * normal.y,
                    tangent.y * normal.y - tangent.x * normal.x,
                    normal.z
                )
                vertex.normal:Rotate(superelevation)
            end
        end
    end

    return mesh
end
