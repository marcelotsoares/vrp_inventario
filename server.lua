local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPinv = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_inventario",vRPinv)
Proxy.addInterface("vrp_inventario",vRPinv)

function getItemType(idname)
  -- idname = {ftype: bebida ou comida, vary_hunger, vary_thirst}
  -- o idname fica em: cfg/item/food.lua
  -- Exemplo: items["water"] = {"Garrafa de Agua","", gen("drink",0,-25),0.5}
  -- ["water"] é o idname
  local items = {
    -- Bebidas
    water = {ftype = "bebida", vary_hunger = 0, vary_thirst = -25, prop = "prop_ld_flow_bottle"},
    milk = {ftype = "bebida", vary_hunger = 0, vary_thirst = -5, prop = "prop_ld_flow_bottle"},
    coffee = {ftype = "bebida", vary_hunger = 0, vary_thirst = -10, prop = "prop_ld_flow_bottle"},
    tea = {ftype = "bebida", vary_hunger = 0, vary_thirst = -15, prop = "prop_ld_flow_bottle"},
    icetea = {ftype = "bebida", vary_hunger = 0, vary_thirst = -20, prop = "prop_ld_flow_bottle"},
    orangejuice = {ftype = "bebida", vary_hunger = 0, vary_thirst = -25, prop = "prop_ld_flow_bottle"},
    gocagola = {ftype = "bebida", vary_hunger = 0, vary_thirst = -35, prop = "prop_ld_flow_bottle"},
    redgull = {ftype = "bebida", vary_hunger = 0, vary_thirst = -40, prop = "prop_ld_flow_bottle"},
    lemonlimonad = {ftype = "bebida", vary_hunger = 0, vary_thirst = -45, prop = "prop_ld_flow_bottle"},
    vodka = {ftype = "bebida", vary_hunger = 15, vary_thirst = -65, prop = "prop_ld_flow_bottle"},
    -- Comidas
    bread = {ftype = "comida", vary_hunger = -10, vary_thirst = 0, prop = "prop_ld_flow_bottle"},
    donuts = {ftype = "comida", vary_hunger = -15, vary_thirst = 0, prop = "prop_ld_flow_bottle"},
    tacos = {ftype = "comida", vary_hunger = -20, vary_thirst = 0, prop = "prop_ld_flow_bottle"},
    sandwich = {ftype = "comida", vary_hunger = -25, vary_thirst = 0, prop = "prop_ld_flow_bottle"},
    kebab = {ftype = "comida", vary_hunger = -45, vary_thirst = 0, prop = "prop_ld_flow_bottle"},
    pdonut = {ftype = "comida", vary_hunger = -25, vary_thirst = 0, prop = "prop_ld_flow_bottle"},
    -- Drogas
    pilulas = {ftype = "drogas", vary_health = 25}
  }
  if items[idname] then
    return items[idname]
  else
    return {}
  end
end

function maybeDrink(player, user_id, idname)
  if getItemType(idname).ftype == "bebida" then
    if vRP.tryGetInventoryItem(user_id,idname,1,false) then
      if vary_hunger ~= 0 then vRP.varyHunger(user_id, getItemType(idname).vary_hunger) end
      if vary_thirst ~= 0 then vRP.varyThirst(user_id, getItemType(idname).vary_thirst) end
      play_drink(player)
      return true
    end
  end
  return false
end

function maybeEat(player, user_id, idname)
  if getItemType(idname).ftype == "comida" then
    if vRP.tryGetInventoryItem(user_id,idname,1,false) then
      if vary_hunger ~= 0 then vRP.varyHunger(user_id, getItemType(idname).vary_hunger) end
      if vary_thirst ~= 0 then vRP.varyThirst(user_id, getItemType(idname).vary_thirst) end
      play_eat(player)
      return true
    end
 end
 return false
end

function maybeDrugs(player, user_id, idname)
  if getItemType(idname).ftype == "drogas" then
    if vRP.tryGetInventoryItem(user_id,idname,1,false) then
      vRPclient._varyHealth(player, getItemType(idname).vary_health)
      play_drink(player)
      return true
    end
 end
 return false
end

function maybeGiveMoney(player, user_id, idname)
  if idname == "dinheiro" then
    local amount = vRP.getInventoryItemAmount(user_id, idname)
    local ramount = vRP.prompt(player, "Quanto você quer despacotar? (max "..amount..")", "")
    ramount = parseInt(ramount)
    if vRP.tryGetInventoryItem(user_id, idname, ramount, true) then
      vRP.giveMoney(user_id, ramount)
      return true
    end
  end
  return false
end

function maybeGiveWeapons(player, user_id, idname)
  local wbody = splitString(idname, "|")
  if wbody[2] then
    if idname == "wbody|"..wbody[2] then
      local uweapons = vRPclient.getWeapons(player)
      if not uweapons[wbody[2]] then
        if vRP.tryGetInventoryItem(user_id, "wbody|"..wbody[2], 1, true) then
          local weapons = {}
          weapons[wbody[2]] = {ammo = 0}
          vRPclient._giveWeapons(player, weapons)
          return true
        end
      end
    end
  end
  return false
end

function maybeGiveBullets(player, user_id, idname)
  local wammo = splitString(idname, "|")
  if wammo[2] then
    if idname == "wammo|"..wammo[2] then
      local amount = vRP.getInventoryItemAmount(user_id, "wammo|"..wammo[2])
      local ramount = vRP.prompt(player, "Quantidade para carregar (max "..amount..")", "")
      ramount = parseInt(ramount)

      local uweapons = vRPclient.getWeapons(player)
      if uweapons[wammo[2]] then
        if vRP.tryGetInventoryItem(user_id, "wammo|"..wammo[2], ramount, true) then
          local weapons = {}
          weapons[wammo[2]] = {ammo = ramount}
          vRPclient._giveWeapons(player, weapons,false)
          return true
        end
      end
    end
  end
  return false
end

function notifyUnusable(player, user_id, idname)
  vRPclient._notifyError(player, "Não utilizável")
end

function play_eat(player)
  local seq = {
    {"mp_player_inteat@burger", "mp_player_int_eat_burger_enter",1},
    {"mp_player_inteat@burger", "mp_player_int_eat_burger",1},
    {"mp_player_inteat@burger", "mp_player_int_eat_burger_fp",1},
    {"mp_player_inteat@burger", "mp_player_int_eat_exit_burger",1}
  }

  vRPclient._playAnim(player,true,seq,false)
end

function play_drink(player)
  local seq = {
    {"mp_player_intdrink","intro_bottle",1},
    {"mp_player_intdrink","loop_bottle",1},
    {"mp_player_intdrink","outro_bottle",1}
  }

  vRPclient._playAnim(player,true,seq,false)
end

RegisterServerEvent('inventario:pegarInventario')
AddEventHandler('inventario:pegarInventario', function()
    local source = source
    local user_id = vRP.getUserId(source)
    local inventario = {}
    local dinheiro = addComma(math.floor(vRP.getMoney(user_id)))
    local weight = vRP.getInventoryWeight(user_id)
    local max_weight = vRP.getInventoryMaxWeight(user_id)
    for k,v in pairs(vRP.getInventory(user_id)) do
      inventario[k] = {
        amount=v.amount,
        name=vRP.getItemName(k)
      }
    end
    TriggerClientEvent('inventario:enviarInventario', source, inventario, dinheiro, weight, max_weight)
end)

RegisterServerEvent('inventario:dropar')
AddEventHandler('inventario:dropar', function(idname)
  local player = source
  local user_id = vRP.getUserId(player)
  local amount = vRP.prompt(player, "Quantidade: (max: "..vRP.getInventoryItemAmount(user_id, idname)..")","")
  local amount = parseInt(amount)
  local handcuffed = vRPclient.isHandcuffed(player)
	if not vRPclient.isInComa(player) and not handcuffed then
    if vRP.tryGetInventoryItem(user_id,idname,amount,false) then
      vRPclient._notify(player, "Você dropou: "..amount.." "..vRP.getItemName(idname))
      vRPclient._playAnim(player,true,{{"pickup_object","pickup_low",1}},false)
      TriggerClientEvent("DropSystem:drop", player, idname, amount)
    else
      vRPclient._notify(player, "Valor inválido")
    end
  end
end)

RegisterServerEvent('inventario:usar')
AddEventHandler('inventario:usar', function(idname)
  local player = source
  local name = vRP.getItemName(idname)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local p = {player, user_id, idname}
    local t = table.unpack
    local handcuffed = vRPclient.isHandcuffed(player)
	  if not vRPclient.isInComa(player) and not handcuffed then
      local result = maybeDrink(t(p)) or maybeEat(t(p)) or maybeDrugs(t(p)) or maybeGiveMoney(t(p)) or maybeGiveWeapons(t(p)) or maybeGiveBullets(t(p)) or notifyUnusable(t(p))
    end
  end
end)

function splitString(str, sep)
  if sep == nil then sep = "%s" end

  local t={}
  local i=1

  for str in string.gmatch(str, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end

  return t
end

function addComma(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end