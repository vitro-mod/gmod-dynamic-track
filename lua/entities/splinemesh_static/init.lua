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

function ENT:Serialize()
    local serialized = self:GetNetworkVars()

    serialized.Name = self:GetName()
    serialized.Class = self:GetClass()

    return serialized
end

function ENT:Deserialize(tbl)
    for k,v in pairs(tbl) do
        if k == 'Class' then continue end
        if k == 'Name' then self:SetName(v) continue end
        if k == 'MdlFile' then self.Model = v continue end
        if k == 'OrigPos' then self:SetPos(v) continue end
        if k == 'OrigAngles' then self:SetAngles(v) continue end

        self[k] = v
    end

    self:Spawn()
end
