AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:OnRemove()
    if not self.clones then return end
    for k,v in pairs(self.clones) do
        SafeRemoveEntity(v)
    end
end