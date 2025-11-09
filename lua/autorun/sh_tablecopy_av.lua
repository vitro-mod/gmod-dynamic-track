function table.CopyAV( t, lookup_table )
    if ( t == nil ) then return nil end

    local copy = {}
    setmetatable( copy, debug.getmetatable( t ) )
    for i, v in pairs( t ) do
        if ( isvector( v ) ) then
            copy[ i ] = Vector( v )
        elseif ( isangle( v ) ) then
            copy[ i ] = Angle( v )
        elseif ( !istable( v ) ) then
            copy[ i ] = v
        else
            lookup_table = lookup_table or {}
            lookup_table[ t ] = copy
            if ( lookup_table[ v ] ) then
                copy[ i ] = lookup_table[ v ] -- we already copied this table. reuse the copy.
            else
                copy[ i ] = table.CopyAV( v, lookup_table ) -- not yet copied. copy it.
            end
        end
    end
    return copy
end
