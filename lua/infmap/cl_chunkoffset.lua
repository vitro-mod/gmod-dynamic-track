SplineMesh = SplineMesh or {}
SplineMesh.RenderOffset = Matrix()

hook.Remove("PropUpdateChunk", "SplineMesh_Render")
hook.Add("PropUpdateChunk", "SplineMesh_Render", function(ent, chunk, oldchunk)
    if ent != LocalPlayer() then return end
    
    local lpco = LocalPlayer().CHUNK_OFFSET
    SplineMesh.RenderOffset:SetTranslation(lpco * -2 * InfMap.chunk_size)
end)