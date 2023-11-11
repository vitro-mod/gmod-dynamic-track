function InfMap.ChunkToText(chunkOffset)
    return table.concat(chunkOffset:ToTable(), ' ')
end

function InfMap.TextToChunk(textChunkOffset)
    return Vector(textChunkOffset)
end