SplineMesh = SplineMesh or {}

SplineMesh.Deform = function(mesh, spline, scale, roll, offset)
    local superelevation = Angle(roll, 0, 0)

    for k,v in pairs(mesh.verticies) do
        v.pos:Add(offset)
        local t = v.pos.y / scale
        local bezier = spline:Sample(t)
        local derivative = spline:Derivative():Sample(t)
        derivative:Normalize()
        derivative:Mul(v.pos.x)
        v.pos = bezier + Vector(derivative.y, -derivative.x) + Vector(0,0,v.pos.z)
        v.pos:Rotate(superelevation) --superelevation
    end

    return mesh
end
