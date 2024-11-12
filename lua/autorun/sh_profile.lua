-- local profile = { 
--     {l = 200, s = 3},
--     {l = 200, s = 40},
--     {l = 200, s = -3},
-- }

SplineMesh.ProfileSample = function(profile, distance)
    distance = distance * 0.01905
    local height = 0
    local currentDistance = 0

    for _, section in ipairs(profile) do
        local sectionLength = section.l
        local sectionSlope = section.s / 1000  -- Переводим уклон из тысячных в доли

        if currentDistance + sectionLength >= distance then
            -- Если заданное расстояние находится в пределах текущего участка
            local remainingDistance = distance - currentDistance
            height = height + remainingDistance * sectionSlope
            break
        else
            -- Если заданное расстояние еще дальше, добавляем полную высоту этого участка
            height = height + sectionLength * sectionSlope
            currentDistance = currentDistance + sectionLength
        end
    end

    return height / 0.01905
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
