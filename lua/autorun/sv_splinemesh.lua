hook.Add( "PhysgunPickup", "SplineMeshRestrictPhysGun", function( ply, ent )
	if ent:GetClass() == 'splinemesh' then return false end
	if ent:GetClass() == 'splinemesh_clone' then return false end
end )

if SERVER then
    util.AddNetworkString("splinemesh_collision")
end

SplineMesh = SplineMesh or {}
SplineMesh.DrawCollision = false

concommand.Add("splinemesh_sc", function( ply, cmd, args )
    SplineMesh.DrawCollision = not SplineMesh.DrawCollision
    net.Start( "splinemesh_collision" )
    net.WriteBool(SplineMesh.DrawCollision)
    net.Send(ply)
end)