SplineMesh = SplineMesh or {}

--- Get matricies of certain number of circular segments
-- @param number angle Angle in degrees
-- @param number radius Radius
-- @param number segments Number of segments
-- @return table Table of matricies
SplineMesh.ArcSegments = function(angle, pos, segments)
    local matricies = {}
    local ang = math.abs(angle)
    local isRight = angle > 0

    for i=1,segments do
        local m = Matrix()
        if i > 1 then
            m:SetUnpacked(matricies[i-1]:Unpack())
            m:Translate(pos)
            m:Rotate(Angle(0, isRight and -ang or ang))
        end
        matricies[i] = m
    end

    local endMatrix = Matrix(matricies[segments])
    endMatrix:Translate(pos)
    endMatrix:Rotate(Angle(0, isRight and -ang or ang))

    return matricies, endMatrix
end

SplineMesh.StraightSegments = function(length, segments)
    local segmentLength = length / segments
    local matricies = {}

    for i=1,segments do
        local m = Matrix()
        if i > 1 then
            m:SetUnpacked(matricies[i-1]:Unpack())
            m:Translate(Vector(0, segmentLength, 0))
        end
        matricies[i] = m
    end

    local endMatrix = Matrix(matricies[segments])
    endMatrix:Translate(Vector(0, segmentLength, 0))

    return matricies, endMatrix
end
