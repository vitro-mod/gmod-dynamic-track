SplineMesh.Spawn = function(pos, ang, plan, profile)
    if not plan then
        print('SplineMesh: plan is not provided!')
    end
    if not profile then profile = {} end
    if not pos then pos = Vector() end
    if not ang then ang = Angle() end

    local splinemeshes = {}

    for k,planElement in pairs(plan) do

        splinemeshes[k] = ents.Create( "splinemesh" ) -- Spawn prop
        if ( !IsValid( splinemeshes[k] ) ) then return end -- Safety first

        if k > 1 then
            local worldEndMatrix = splinemeshes[k-1].OrigMatrix * splinemeshes[k-1].endMatrix
            pos = worldEndMatrix:GetTranslation()
            ang = worldEndMatrix:GetAngles()

            splinemeshes[k].profileStart = splinemeshes[k-1].endDistance
        end

        splinemeshes[k]:SetPos( pos ) -- Set pos where is player looking
        splinemeshes[k]:SetAngles( ang ) -- Set pos where is player looking

        for planKey,planValue in pairs(planElement) do
            splinemeshes[k][planKey] = planValue
        end

        splinemeshes[k].PROFILE = profile

        splinemeshes[k]:Spawn() -- Instantiate prop
    end
end
