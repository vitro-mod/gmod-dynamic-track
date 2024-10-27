SplineMesh = SplineMesh || {}


-- SplineMesh.WeldConvexes = function(convexes)
--     local i = 1;
--     local result = {}
--     for k,convex in pairs(convexes) do
--         for k2,vertex in pairs(convex) do
--             result[i] = vertex
--             i = i + 1
--         end
--     end
    
--     return result
-- end

-- -- Weld multiple convexes in one mesh and add pos key for PhysicsFromMesh function
-- SplineMesh.WeldConvexesPos = function(convexes)
--     local i = 1;
--     local result = {}
--     for k,convex in pairs(convexes) do
--         for k2,vertex in pairs(convex) do
--             result[i] = {pos = vertex}
--             i = i + 1
--         end
--     end
    
--     return result
-- end

-- Remove pos key from convexes to make them ready to be fed in PhysicsInitMultiConvex function
SplineMesh.PrepareConvexes = function(convexes)
    local result = {}
    for k,convex in pairs(convexes) do
        result[k] = convexes[k].pos
    end

    return result
end
