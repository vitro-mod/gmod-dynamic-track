local ent = Entity(1)
local curves = splinemeshes1
local speed = 1 -- единиц t в секунду
local curveIndex = 1
local matrixIndex = 1
local t = 0
local frameMatrix = Matrix()
local entMatrix = Matrix()
frameMatrix:Identity()
entMatrix:Identity()
hook.Remove("Think", "MoveEntityBezierChain")
hook.Add("Think", "MoveEntityBezierChain", function()
    if not IsValid(ent) then
        hook.Remove("Think", "MoveEntityBezierChain")
        return
    end

    ent:SetMoveType(MOVETYPE_NONE)
    local curve = curves[curveIndex].bezierSpline
    if not curve then
        hook.Remove("Think", "MoveEntityBezierChain")
        return
    end

    -- Позиции
    local pos = curve:Sample(t)
    local nextT = math.min(t + FrameTime() * speed, 1)
    local nextPos = curve:Sample(nextT)
    -- Создаем матрицу движения по кривой
    frameMatrix:SetTranslation(pos)
    -- Устанавливаем угол по направлению движения
    local dir = (nextPos - pos):GetNormalized()
    if dir:Length() > 0 then frameMatrix:SetAngles(dir:Angle()) end
    -- Применяем трансформацию: результат = OrigMatrix * frameMatrix
    entMatrix = curves[curveIndex].OrigMatrix * curves[curveIndex].matricies[matrixIndex] * frameMatrix
    -- Устанавливаем финальную позицию и угол
    ent:SetPos(entMatrix:GetTranslation())
    ent:SetAngles(entMatrix:GetAngles())
    t = nextT
    if t >= 1 then
        t = 0
        matrixIndex = matrixIndex + 1
        if matrixIndex > #curves[curveIndex].matricies then
            matrixIndex = 1
            curveIndex = curveIndex + 1
            if curveIndex > #curves then
                hook.Remove("Think", "MoveEntityBezierChain")
            end
        end
    end
end)
