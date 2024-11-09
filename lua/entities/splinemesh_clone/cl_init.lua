include("shared.lua")

function ENT:OnRemove()
    SafeRemoveEntity(self.clientProp)
end
