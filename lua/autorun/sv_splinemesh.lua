hook.Remove( "PhysgunPickup", "SplineMeshRestrictPhysGun")
hook.Add( "PhysgunPickup", "SplineMeshRestrictPhysGun", function( ply, ent )
	if ent:GetClass() == 'splinemesh' then return false end
	if ent:GetClass() == 'splinemesh_static' then return false end
	if ent:GetClass() == 'splinemesh_clone' then return false end
	if ent:GetClass() == 'prop_physics' and ent.IsSplineMeshStatic then return false end
end )

SplineMesh = SplineMesh or {}
