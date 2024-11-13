-- local profile = { 
--     {l = 200, s = 3, r = 3000},
--     {l = 200, s = 40, r = 5000},
--     {l = 200, s = -3},
-- }

local function calculateHeight(profile, distance)
    local height = 0
    local currentDistance = 0

    for i, section in ipairs(profile) do
        local sectionLength = section.l
        local sectionSlope = section.s / 1000  -- Переводим уклон из тысячных в доли

        if currentDistance + sectionLength >= distance then
            -- Если заданное расстояние находится в пределах текущего участка
            local remainingDistance = distance - currentDistance
            local startRadius, endRadius
            local startDifference, endDifference
            local startTangent, endTangent

            if i > 1 and profile[i - 1].r then
                startDifference = (section.s - profile[i - 1].s) / 1000
                startRadius = profile[i - 1].r
                startTangent = math.abs(startRadius * startDifference / 2)
            end

            if i < #profile and section.r then
                endDifference = (profile[i + 1].s - section.s) / 1000
                endRadius = section.r
                endTangent = math.abs(endRadius * endDifference / 2)
            end

            local dh = 0

            -- Проверка, что мы на вертикальной кривой:
            if startTangent and remainingDistance < startTangent then
                -- Мы в начале участка и сопрягающая с предыдущим еще не закончилась
                local x = startTangent - remainingDistance
                dh = x*x / (2 * startRadius)

                if startDifference < 0 then dh = -dh end
            elseif endTangent and remainingDistance > (sectionLength - endTangent) then
                -- Мы в конце участка и уже началась сопрягающая со следующим
                local linearPart = sectionLength - endTangent
                local x = remainingDistance - linearPart
                dh = x*x / (2 * endRadius)

                if endDifference < 0 then dh = -dh end
            end
                
            height = height + remainingDistance * sectionSlope + dh
            break
        else
            -- Если заданное расстояние еще дальше, добавляем полную высоту этого участка
            height = height + sectionLength * sectionSlope
            currentDistance = currentDistance + sectionLength
        end
    end

    return height
end

SplineMesh.ProfileSample = function(profile, distance)
    return calculateHeight(profile, distance * 0.01905) / 0.01905
end

SplineMesh.ProfileApplyToMatrix = function(matrix, profile, segmentNum, segmentLength, profileStart)
    local distance = profileStart + (segmentNum * segmentLength)

    local height1 = SplineMesh.ProfileSample(profile, distance)
    local height2 = SplineMesh.ProfileSample(profile, distance + segmentLength)
    local tan = (height2 - height1) / segmentLength

    local pitch = math.deg(math.atan(tan))

    matrix:SetTranslation(matrix:GetTranslation() + Vector(0, 0, height1))
    matrix:SetAngles(matrix:GetAngles() + Angle(0, 0, pitch))
end

SplineMesh.ProfileApplyToMatricies = function(matricies, profile, profileStart, segmentLength)
    for k,matrix in pairs(matricies) do
        SplineMesh.ProfileApplyToMatrix(matrix, profile, (k-1), segmentLength, profileStart)
    end
end
