SplineMesh = SplineMesh or {}

-- Remove pos key from convexes to make them ready to be fed in PhysicsInitMultiConvex function
SplineMesh.PrepareConvexes = function(convexes)
    local result = {}
    for k,convex in pairs(convexes) do
        result[k] = convexes[k].pos
    end

    return result
end
