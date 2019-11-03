local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 246) then
            TransitionToBlurred(1000)
            TriggerServerEvent('inventario:pegarInventario')
        end
    end
end)

RegisterNetEvent('inventario:enviarInventario')
AddEventHandler('inventario:enviarInventario', function(inventario, dinheiro, weight, max_weight)
	SetNuiFocus(true, true)
	SendNUIMessage({
        show = true,
        inventario = inventario,
        dinheiro = dinheiro,
        weight = weight,
        max_weight = max_weight
	})
end)

RegisterNetEvent('inventario:enviarInventarioSecundario')
AddEventHandler('inventario:enviarInventarioSecundario', function(cofre, weight, max_weight)
	SetNuiFocus(true, true)
	SendNUIMessage({
        showSecundary = true,
        InventarioSecundario = cofre,
        weight = weight,
        max_weight = max_weight
	})
end)

RegisterNUICallback('fechar', function()
    TransitionFromBlurred(1000)
    SetNuiFocus(false, false)
end)

RegisterNUICallback('dropar', function(data, cb)
    local idname = data.id
    TriggerServerEvent('inventario:dropar', idname)
end)

RegisterNUICallback('usar', function(data, cb)
    local idname = data.id
    TriggerServerEvent('inventario:usar', idname)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)