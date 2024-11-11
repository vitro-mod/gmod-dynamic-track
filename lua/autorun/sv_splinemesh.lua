hook.Add( "PhysgunPickup", "SplineMeshRestrictPhysGun", function( ply, ent )
	if ent:GetClass() == 'splinemesh' then return false end
	if ent:GetClass() == 'splinemesh_clone' then return false end
end )

SplineMesh = SplineMesh or {}
