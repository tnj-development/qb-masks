local QBCore = exports['qb-core']:GetCoreObject()
local skin
local data = {}


for k, v in pairs(Config["Masks"]) do
    QBCore.Functions.CreateUseableItem(k, function(source, item)   
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        local ped = GetPlayerPed(src)
        local model = GetEntityModel(ped)
        if Player.Functions.RemoveItem(k, 1) then -- change this
            if model ~= nil then
                local result = MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { Player.PlayerData.citizenid, 1 })
                if result[1] ~= nil then
                    skin = json.decode(result[1].skin)
                end
    
                -- MASK BS
                skin["mask"].item = v.drawableId
                skin["mask"].texture = v.textureId
    
                data[src] = {
                    mask = v.drawableId,
                    item = "mask"
                }
    
                SetPedComponentVariation(ped, 1, skin["mask"].item, skin["mask"].texture, 2)
                TaskPlayAnim(ped, "mp_masks@standard_car@ds@", "put_on_mask", 8.00, -8.00, 800, 51, 0.00, 0, 0, 0)
                skin = json.encode(skin)
                -- TODO: Update primary key to be citizenid so this can be an insert on duplicate update query
                MySQL.Async.execute('DELETE FROM playerskins WHERE citizenid = ?', { Player.PlayerData.citizenid }, function()
                    MySQL.Async.insert('INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, ?)', {
                        Player.PlayerData.citizenid,
                        model,
                        skin,
                        1
                    })
                end)
            end
        end 
    end)
end

-- QBCore.Functions.CreateUseableItem("mask", function(source, item) -- change this
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     local ped = GetPlayerPed(src)
--     local model = GetEntityModel(ped)
--     if Player.Functions.RemoveItem("mask", 1) then -- change this
--         if model ~= nil then
--             local result = MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { Player.PlayerData.citizenid, 1 })
--             if result[1] ~= nil then
--                 skin = json.decode(result[1].skin)
--             end

--             -- MASK BS
--             skin["mask"].item = 55
--             skin["mask"].texture = 0

--             data[src] = {
--                 mask = 55,
--                 item = "mask"
--             }

--             SetPedComponentVariation(ped, 1, skin["mask"].item, skin["mask"].texture, 2)
--             TaskPlayAnim(ped, "mp_masks@standard_car@ds@", "put_on_mask", 8.00, -8.00, 800, 51, 0.00, 0, 0, 0)
--             skin = json.encode(skin)
--             -- TODO: Update primary key to be citizenid so this can be an insert on duplicate update query
--             MySQL.Async.execute('DELETE FROM playerskins WHERE citizenid = ?', { Player.PlayerData.citizenid }, function()
--                 MySQL.Async.insert('INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, ?)', {
--                     Player.PlayerData.citizenid,
--                     model,
--                     skin,
--                     1
--                 })
--             end)
--         end
--     end
-- end)

RegisterCommand("maskoff", function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local ped = GetPlayerPed(src)
    local model = GetEntityModel(ped)
    if model ~= nil then
        local result = MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { Player.PlayerData.citizenid, 1 })
        if result[1] ~= nil then
            skin = json.decode(result[1].skin)
        end

        -- MASK BS
        if data[src].item == nil then print("fucked up") return end
        if skin["mask"].item == data[src].mask then
            SetPedComponentVariation(ped, 1, 0, 0, 2)
            Player.Functions.AddItem(data[src].item, 1)
        end
        skin["mask"].item = 0
        skin["mask"].texture = 0
        data[src] = {
            mask = 0,
            item = nil
        }

        TaskPlayAnim(ped, "mp_masks@standard_car@ds@", "put_on_mask", 8.00, -8.00, 800, 51, 0.00, 0, 0, 0)
        skin = json.encode(skin)
        -- TODO: Update primary key to be citizenid so this can be an insert on duplicate update query
        MySQL.Async.execute('DELETE FROM playerskins WHERE citizenid = ?', { Player.PlayerData.citizenid }, function()
            MySQL.Async.insert('INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, ?)', {
                Player.PlayerData.citizenid,
                model,
                skin,
                1
            })
        end)
    end
    
end)
