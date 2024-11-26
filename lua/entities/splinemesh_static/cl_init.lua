include("shared.lua")

function ENT:Draw()
    -- cam.PushModelMatrix( SplineMesh.RenderOffset * self.RenderMatrix )
    self:DrawModel()
    -- cam.PopModelMatrix()
end