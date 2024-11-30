SplineMesh = SplineMesh or {}

if not SERVER then return end

local function getFile(path,name,id)
    local data,found
    if file.Exists(Format(path..".txt",name),"DATA") then
        print(Format("SplineMesh: Loading %s definition...",id))
        data= util.JSONToTable(file.Read(Format(path..".txt",name),"DATA"))
        found = true
    end
    if not data and file.Exists(Format(path..".lua",name),"LUA") then
        print(Format("SplineMesh: Loading default %s definition...",id))
        data= util.JSONToTable(file.Read(Format(path..".lua",name),"LUA"))
        found = true
    end
    if not found then
        print(Format("%s definition file not found: %s",id,Format(path,name)))
        return
    elseif not data then
        print(Format("Parse error in %s %s definition JSON",id,Format(path,name)))
        return
    end
    return data
end

function SplineMesh.Save()
    if not file.Exists("splinemesh_data", "DATA") then
		file.CreateDir("splinemesh_data")
	end
	name = name or game.GetMap()

    local entities = {}

    for _, entity in pairs(ents.FindByClass('splinemesh')) do
        if not entity.Serialize then continue end
        table.insert(entities, entity:Serialize())
    end

    for _, entity in pairs(ents.FindByClass('splinemesh_static')) do
        if not entity.Serialize then continue end
        table.insert(entities, entity:Serialize())
    end

    print("SplineMesh: Saving splinemeshes...")
    local data = util.TableToJSON(entities, true)
    local filename = string.format("splinemesh_data/splinemeshes_%s.txt", name)
	file.Write(filename, data)
	print(string.format("Saved to %s",filename))
end

function SplineMesh.Load()
    local name = game.GetMap()
    local data = getFile("splinemesh_data/splinemeshes_%s",name,"SplineMesh")

    if not data then return end

    SplineMesh.Cleanup()

    print("SplineMesh: Loading...")

    for k,v in pairs(data) do
        local ent = ents.Create(v.Class)
        ent:Deserialize(v)
    end
end

function SplineMesh.Cleanup()
    for k,v in pairs(ents.FindByClass("splinemesh")) do SafeRemoveEntity(v) end
    for k,v in pairs(ents.FindByClass("splinemesh_static")) do SafeRemoveEntity(v) end
end

concommand.Add("splinemesh_save", function(ply, _, args)
    if (ply:IsValid()) and (not ply:IsAdmin()) then return end
    SplineMesh.Save()
end)

concommand.Add("splinemesh_load", function(ply, _, args)
    if (ply:IsValid()) and (not ply:IsAdmin()) then return end
    SplineMesh.Load()
end)

concommand.Add("splinemesh_cleanup", function(ply, _, args)
    if (ply:IsValid()) and (not ply:IsAdmin()) then return end
    SplineMesh.Cleanup()
end)
