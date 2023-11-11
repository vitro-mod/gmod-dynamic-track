--- Create Bezier2 object (QuadraticBezier)
-- @param startPos Vector
-- @param tangent Vector
-- @param endPos Vector
function Bezier2(startPos, tangent, endPos)
    return {
        startPos = startPos, 
        tangent = tangent,
        endPos = endPos,
        Sample = _b2sample,
        -- Derivative = _b2derivative
    }
end

--- Create Bezier3 object (CubicBezier)
-- @param startPos Vector
-- @param startTangent Vector
-- @param endTangent Vector
-- @param endPos Vector
function Bezier3(startPos, startTangent, endTangent, endPos)
    return {
        startPos = startPos, 
        startTangent = startTangent, 
        endTangent = endTangent, 
        endPos = endPos,
        Sample = _b3sample,
        Derivative = _b3derivative,
    }
end

function _b2sample(self, t)
    return math.QuadraticBezier(t, self.startPos, self.tangent, self.endPos)
end

function _b3sample(self, t)
    return math.CubicBezier(t, self.startPos, self.startTangent, self.endTangent, self.endPos)
end

-- function _b2derivative(self)
--     local p0 = self.startPos
-- 	local p1 = self.tangent
-- 	local p2 = self.endPos

--     local d0 = 2*(p1-p0)
-- 	local d1 = 2*(p2-p1)

--     return d0, d1
-- end

function _b3derivative(self)
    if self._derivative then return self._derivative end
    local p0 = self.startPos
	local p1 = self.startTangent
	local p2 = self.endTangent
	local p3 = self.endPos

    local d0 = 3*(p1-p0)
	local d1 = 3*(p2-p1)
	local d2 = 3*(p3-p2)

    self._derivative = Bezier2(d0, d1, d2)
    return self._derivative
end