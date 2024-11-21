SplineMesh = SplineMesh or {}
SplineMesh.RenderOffset = Matrix()

hook.Remove("PropUpdateChunk", "SplineMesh_Render")
hook.Add("PropUpdateChunk", "SplineMesh_Render", function(ent, chunk, oldchunk)
    if ent != LocalPlayer() then return end
    
    local lpco = LocalPlayer().CHUNK_OFFSET
    SplineMesh.RenderOffset:SetTranslation(lpco * -2 * InfMap.chunk_size)
end)

hook.Remove("PropUpdateChunk", "SplineMesh_Clone_Render")
hook.Add("PropUpdateChunk", "SplineMesh_Clone_Render", function(ent, chunk, oldchunk)
    if ent != LocalPlayer() then return end
 
    local lpco = InfMap.ChunkToText(LocalPlayer().CHUNK_OFFSET)

    local function update_vcollide_wireframe()
        if GetConVar('vcollide_wireframe'):GetBool() then
            RunConsoleCommand('vcollide_wireframe', '0')
            RunConsoleCommand('vcollide_wireframe', '1')
        end
    end

    for k,v in pairs(ents.FindByClass('splinemesh_clone')) do
        if not IsValid(v) then continue end

        local co = InfMap.ChunkToText(v.CHUNK_OFFSET)

        -- print(v, lpco, co)
        if lpco ~= co then
            if v:GetRenderMode() ~= RENDERMODE_NONE then
                v._OldRenderMode = v:GetRenderMode()
            end
            v:SetRenderMode(RENDERMODE_NONE)
            update_vcollide_wireframe()
        elseif v._OldRenderMode then
            v:SetRenderMode(v._OldRenderMode)
            update_vcollide_wireframe()
        end
    end
end)
