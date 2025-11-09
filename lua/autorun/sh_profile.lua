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

SplineMesh.ProfileApplyToMatricies = function(matricies, endMatrix, profile, profileStart, segmentLength)
    for k,matrix in pairs(matricies) do
        local distance = profileStart + ((k - 1) * segmentLength)
        local height = SplineMesh.ProfileSample(profile, distance)
        local tran = matrix:GetTranslation()
        tran.z = tran.z + height
        matrix:SetTranslation(tran)

        if k > 1 then
            local prevHeight = matricies[k-1]:GetTranslation().z
            local dh = height - prevHeight
            local tan = dh / segmentLength
            local pitch = math.deg(math.atan(tan))
            local ang = matricies[k-1]:GetAngles()
            ang.z = pitch
            matricies[k-1]:SetAngles(ang)
        end
    end

    local distance = profileStart + (#matricies * segmentLength)
    local height = SplineMesh.ProfileSample(profile, distance)
    local prevHeight = matricies[#matricies]:GetTranslation().z
    local dh = height - prevHeight
    local tan = dh / segmentLength
    local pitch = math.deg(math.atan(tan))
    local ang = matricies[#matricies]:GetAngles()
    ang.z = pitch
    matricies[#matricies]:SetAngles(ang)
end
