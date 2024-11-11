SplineMesh = SplineMesh || {}

SplineMesh.Deform = function(mesh, spline, scale, roll)
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
        v.pos = bezier + Vector(derivative.y, -derivative.x) + Vector(0,0,v.pos.z)
        v.pos:Rotate(superelevation) --superelevation
    end

    return mesh
end
