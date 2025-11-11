SplineMesh = SplineMesh or {}

--- Approximate circular arc with a CubicBezier
-- https://math.stackexchange.com/questions/873224/calculate-control-points-of-cubic-bezier-curve-approximating-a-part-of-a-circle
-- @param angle number Angle of arc in degrees
-- @param radius number Radius of arc
-- @return Bezier3 Approximated spline
SplineMesh.ApproximateArc = function(angle, radius, flip)

    -- if angle == 0 then return end

    local isRight = angle > 0

    if flip then isRight = not isRight end

    local ang = math.abs(angle)

    local radians = math.rad(ang)
    local tangent = (4/3) * radius * math.tan(radians / 4)

    local startPos = Vector()

    local curveX = radius * (1 - math.cos(radians))

    local endPos = Vector(isRight and curveX or -curveX, radius * math.sin(radians))

    local startTangent = Vector(0, tangent)
    local endTangent = Vector(0, -tangent)
    endTangent:Rotate(Angle(0, isRight and (360 - ang) or (360 + ang)))
    endTangent:Add(endPos)

    if flip then
        endPos.x = -endPos.x
        endTangent.x = -endTangent.x
        return Bezier3(endPos, endTangent, startTangent, startPos)
    end

    return Bezier3(startPos, startTangent, endTangent, endPos)
end

SplineMesh.ApproximateStraight = function(length, flip)
    local startPos = Vector()
    local endPos = Vector(0, length)

    local startTangent = Vector(0, length / 3)
    local endTangent = Vector(0, 2 * length / 3)

    if flip then
        return Bezier3(endPos, endTangent, startTangent, startPos)
    end

    return Bezier3(startPos, startTangent, endTangent, endPos)
end