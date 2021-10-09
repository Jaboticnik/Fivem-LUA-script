ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
  TriggerEvent('esx_service:activateService', 'mafia', Config.MaxInService)
end

TriggerEvent('esx_society:registerSociety', 'mafia', 'mafia', 'society_mafia', 'society_mafia', 'society_mafia', {type = 'public'})

RegisterServerEvent('esx_voltamafia:giveWeapon')
AddEventHandler('esx_voltamafia:giveWeapon', function(weapon, ammo)
  local xPlayer = ESX.GetPlayerFromId(source)
  xPlayer.addWeapon(weapon, ammo)
end)

RegisterServerEvent('esx_voltamafia:confiscatePlayerItem')
AddEventHandler('esx_voltamafia:confiscatePlayerItem', function(target, itemType, itemName, amount)

  local sourceXPlayer = ESX.GetPlayerFromId(source)
  local targetXPlayer = ESX.GetPlayerFromId(target)

    if itemType == 'item_standard' then

     local label = sourceXPlayer.getInventoryItem(itemName).label

     targetXPlayer.removeInventoryItem(itemName, amount)
     sourceXPlayer.addInventoryItem(itemName, amount)

	    sourceXPlayer.showNotification(_U('you_have_confinv') .. amount .. ' ' .. label .. _U('from') .. targetXPlayer.name)
    	targetXPlayer.showNotification( '~b~' .. targetXPlayer.name .. _U('confinv') .. amount .. ' ' .. label )

     end

     if itemType == 'item_account' then

      targetXPlayer.removeAccountMoney(itemName, amount)
      sourceXPlayer.addAccountMoney(itemName, amount)

    	sourceXPlayer.showNotification(_U('you_have_confdm') .. amount .. _U('from') .. targetXPlayer.name)
    	targetXPlayer.showNotification('~b~' .. targetXPlayer.name .. _U('confdm') .. amount)
	
     end

     if itemType == 'item_weapon' then

      targetXPlayer.removeWeapon(itemName)
      sourceXPlayer.addWeapon(itemName, amount)

	    sourceXPlayer.showNotification(_U('you_have_confweapon') .. ESX.GetWeaponLabel(itemName) .. _U('from') .. targetXPlayer.name)
	    targetXPlayer.showNotification('~b~' .. targetXPlayer.name .. _U('confweapon') .. ESX.GetWeaponLabel(itemName))
	
     end

end)

RegisterServerEvent('esx_voltamafia:handcuff')
AddEventHandler('esx_voltamafia:handcuff', function(target)
	TriggerClientEvent('esx_voltamafia:handcuff', target)
end)

RegisterServerEvent('esx_voltamafia:drag')
AddEventHandler('esx_voltamafia:drag', function(target)
	local _source = source
	TriggerClientEvent('esx_voltamafia:drag', target, _source)
end)

RegisterServerEvent('esx_voltamafia:putInVehicle')
AddEventHandler('esx_voltamafia:putInVehicle', function(target)
	TriggerClientEvent('esx_voltamafia:putInVehicle', target)
end)

RegisterServerEvent('esx_voltamafia:OutVehicle')
AddEventHandler('esx_voltamafia:OutVehicle', function(target)
	TriggerClientEvent('esx_voltamafia:OutVehicle', target)
end)

RegisterServerEvent('esx_voltamafia:getStockItem')
AddEventHandler('esx_voltamafia:getStockItem', function(itemName, count)

  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mafia', function(inventory)

    local item = inventory.getItem(itemName)

    if item.count >= count then
      inventory.removeItem(itemName, count)
      xPlayer.addInventoryItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn') .. count .. ' ' .. item.label)

  end)

end)

RegisterServerEvent('esx_voltamafia:putStockItems')
AddEventHandler('esx_voltamafia:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mafia', function(inventory)

		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_deposited', count, inventoryItem.label))
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end

	end)

end)

ESX.RegisterServerCallback('esx_voltamafia:getOtherPlayerData', function(source, cb, target)

    if Config.EnableESXIdentity then

     local xPlayer = ESX.GetPlayerFromId(target)

     local identifier = GetPlayerIdentifiers(target)[1]

      local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
       ['@identifier'] = identifier
      })

     local user      = result[1]
     local firstname     = user['firstname']
     local lastname      = user['lastname']
     local sex           = user['sex']
     local dob           = user['dateofbirth']
     local height        = user['height'] .. " Inches"

     local data = {
      name        = GetPlayerName(target),
      job         = xPlayer.job,
      inventory   = xPlayer.inventory,
      accounts    = xPlayer.accounts,
      weapons     = xPlayer.loadout,
      firstname   = firstname,
      lastname    = lastname,
      sex         = sex,
      dob         = dateofbirth,
      height      = height
     }

    TriggerEvent('esx_status:getStatus', source, 'drunk', function(status)

      if status ~= nil then
        data.drunk = math.floor(status.percent)
      end

    end)

    if Config.EnableLicenses then

      TriggerEvent('esx_license:getLicenses', source, function(licenses)
        data.licenses = licenses
        cb(data)
      end)

    else
      cb(data)
    end

  else

    local xPlayer = ESX.GetPlayerFromId(target)

    local data = {
      name       = GetPlayerName(target),
      job        = xPlayer.job,
      inventory  = xPlayer.inventory,
      accounts   = xPlayer.accounts,
      weapons    = xPlayer.loadout
    }

    TriggerEvent('esx_status:getStatus', _source, 'drunk', function(status)

      if status ~= nil then
        data.drunk = status.getPercent()
      end

    end)

    TriggerEvent('esx_license:getLicenses', _source, function(licenses)
      data.licenses = licenses
    end)

    cb(data)

  end

end)

ESX.RegisterServerCallback('esx_voltamafia:getVehicleInfos', function(source, cb, plate)

	if Config.EnableESXIdentity then

    MySQL.Async.fetchAll(
      'SELECT * FROM owned_vehicles',
      {},
      function(result)

        local foundIdentifier = nil

        for i=1, #result, 1 do

          local vehicleData = json.decode(result[i].vehicle)

          if vehicleData.plate == plate then
            foundIdentifier = result[i].owner
            break
          end

        end

        if foundIdentifier ~= nil then

          MySQL.Async.fetchAll(
            'SELECT * FROM users WHERE identifier = @identifier',
            {
              ['@identifier'] = foundIdentifier
            },
            function(result)

              local ownerName = result[1].firstname .. " " .. result[1].lastname

              local infos = {
                plate = plate,
                owner = ownerName
              }

              cb(infos)

            end
          )

        else

          local infos = {
          plate = plate
          }

          cb(infos)

        end

      end
    )

  else

    MySQL.Async.fetchAll(
      'SELECT * FROM owned_vehicles',
      {},
      function(result)

        local foundIdentifier = nil

        for i=1, #result, 1 do

          local vehicleData = json.decode(result[i].vehicle)

          if vehicleData.plate == plate then
            foundIdentifier = result[i].owner
            break
          end

        end

        if foundIdentifier ~= nil then

          MySQL.Async.fetchAll(
            'SELECT * FROM users WHERE identifier = @identifier',
            {
              ['@identifier'] = foundIdentifier
            },
            function(result)

              local infos = {
                plate = plate,
                owner = result[1].name
              }

              cb(infos)

            end
          )

        else

          local infos = {
          plate = plate
          }

          cb(infos)

        end

      end
    )

  end

end)

ESX.RegisterServerCallback('esx_voltamafia:getArmoryWeapons', function(source, cb)

  TriggerEvent('esx_datastore:getSharedDataStore', 'society_mafia', function(store)

    local weapons = store.get('weapons')

    if weapons == nil then
      weapons = {}
    end

    cb(weapons)

  end)

end)

ESX.RegisterServerCallback('esx_voltamafia:addArmoryWeapon', function(source, cb, weaponName)

  local xPlayer = ESX.GetPlayerFromId(source)

  xPlayer.removeWeapon(weaponName)

  TriggerEvent('esx_datastore:getSharedDataStore', 'society_mafia', function(store)

    local weapons = store.get('weapons')

    if weapons == nil then
      weapons = {}
    end

    local foundWeapon = false

    for i=1, #weapons, 1 do
      if weapons[i].name == weaponName then
        weapons[i].count = weapons[i].count + 1
        foundWeapon = true
      end
    end

    if not foundWeapon then
      table.insert(weapons, {
        name  = weaponName,
        count = 1
      })
    end

     store.set('weapons', weapons)

     cb()

  end)

end)

ESX.RegisterServerCallback('esx_voltamafia:removeArmoryWeapon', function(source, cb, weaponName)

  local xPlayer = ESX.GetPlayerFromId(source)

  xPlayer.addWeapon(weaponName, 1000)

  TriggerEvent('esx_datastore:getSharedDataStore', 'society_mafia', function(store)

    local weapons = store.get('weapons')

    if weapons == nil then
      weapons = {}
    end

    local foundWeapon = false

    for i=1, #weapons, 1 do
      if weapons[i].name == weaponName then
        weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
        foundWeapon = true
      end
    end

    if not foundWeapon then
      table.insert(weapons, {
        name  = weaponName,
        count = 0
      })
    end

     store.set('weapons', weapons)

     cb()

  end)

end)


ESX.RegisterServerCallback('esx_voltamafia:buy', function(source, cb, amount)

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mafia', function(account)

    if account.money >= amount then
      account.removeMoney(amount)
      cb(true)
    else
      cb(false)
    end

  end)

end)

ESX.RegisterServerCallback('esx_voltamafia:getStockItems', function(source, cb)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mafia', function(inventory)
    cb(inventory.items)
  end)

end)

ESX.RegisterServerCallback('esx_voltamafia:getPlayerInventory', function(source, cb)

  local xPlayer = ESX.GetPlayerFromId(source)
  local items   = xPlayer.inventory

  cb({
    items = items
  })

end)

