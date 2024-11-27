AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:OnRemove()
    if self.clones then
        for k,v in pairs(self.clones) do
            SafeRemoveEntity(v)
        end
    end

    if self.Doors then
        for k,v in pairs(self.Doors) do
            SafeRemoveEntity(v)
        end
    end
end
