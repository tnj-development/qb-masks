local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function() -- LOADS ANIMATION
    while not HasAnimDictLoaded("mp_masks@standard_car@ds@") do
        RequestAnimDict("mp_masks@standard_car@ds@")
        Wait(1)
    end
end)