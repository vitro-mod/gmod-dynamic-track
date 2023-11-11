SplineMesh = SplineMesh || {}

SplineMesh.ArcDeform = function(mesh, spline, scale, roll)
    local superelevation = Angle()
    if roll ~= 0 then 
        superelevation:SetUnpacked(roll, 0, 0) 
    end
    for k,v in pairs(mesh.verticies) do
        --v.pos:Mul(Vector(1,1,1))
        --v.pos:Sub(Vector(min.x, 0, 0))
        local t = v.pos.y / scale
        local bezier = spline:Sample(t)
        local derivative = spline:Derivative():Sample(t)
        derivative:Normalize()
        derivative:Mul(v.pos.x)
        v.pos:Rotate(superelevation) --superelevation
        v.pos = bezier + Vector(derivative.y, -derivative.x) + Vector(0,0,v.pos.z)
    end

    return mesh
end

SplineMesh.StraightDeform = function(mesh, scale)
    for k,v in pairs(mesh.verticies) do
        v.pos:Mul(Vector(1, scale, 1))
    end

    return mesh
end