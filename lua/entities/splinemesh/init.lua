AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:OnRemove()
    if not self.clones then return end
    for k,v in pairs(self.clones) do
        SafeRemoveEntity(v)
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
        if k == 'TrackMeshNum' then self.TrackMeshNum = v continue end
        if k == 'CurveRadius' then self.RADIUS = v continue end
        if k == 'CurveAngle' then self.ANGLE = v continue end
        if k == 'TrackLength' then self.LENGTH = v continue end
        if k == 'IsCurve' then self.CURVE = v continue end
        if k == 'ForwardAxis' then self.FORWARD_AXIS = v continue end
        if k == 'FlipModel' then self.FLIP_MODEL = v continue end
        -- if k == 'ProfileStart' then self.profileStart = v continue end

        -- self[k] = v
    end

    self:Spawn()
end
