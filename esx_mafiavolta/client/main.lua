local PlayerData                = {}
local GUI                       = {}
local HasAlreadyEnteredMarker   = false
local LastStation               = nil
local LastPart                  = nil
local LastPartNum               = nil
local LastEntity                = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local IsHandcuffed              = false
local IsDragged                 = false
local CopPed                    = 0

ESX                             = nil
GUI.Time                        = 0

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

function SetVehicleMaxMods(vehicle)

  local props = {
		modEngine       = 4,
		modBrakes       = 4,
		modTransmission = 4,
		modSuspension   = 4,
		modTurbo        = true
	}

  ESX.Game.SetVehicleProperties(vehicle, props)

end

function OpenArmoryMenu(station)


 	local elements = {
		  {label = '------------------------------------------------------', value = ''},
		  {label = 'Take a weapon', value = 'get_weapon'},
		  {label = 'Put a weapon', value = 'put_weapon'},
		  {label = 'Take an item', value = 'get_stock'},
		  {label = 'Put an item',  value = 'put_stock'},
		  
	}

	if GetAmmoInPedWeapon(GetPlayerPed(-1), GetHashKey('WEAPON_ADVANCEDRIFLE')) >= 201  then
		--ESX.ShowNotification('Imel si ~r~preveliko kolicino nabojev~s~, nekaj smo ti jih ~r~uzeli~s~.')
		SetPedAmmo(GetPlayerPed(-1), GetHashKey('WEAPON_ADVANCEDRIFLE'), 201)
    end
		
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'armory',
      {
        title    = _U('armory') .. ' - ' .. PlayerData.job.grade_label,
        align    = 'right',
        elements = elements,
      },
      function(data, menu)

        if data.current.value == 'get_weapon' then
          OpenGetWeaponMenu()
        end

        if data.current.value == 'put_weapon' then
          OpenPutWeaponMenu()
        end

        if data.current.value == 'put_stock' then
          OpenPutStocksMenu()
        end

        if data.current.value == 'get_stock' then
          OpenGetStocksMenu()
        end

        if data.current.value == 'put_confiscated' then
          OpenPutConfiscatedItemsMenu()
        end

        if data.current.value == 'get_confiscated' and PlayerData.job.grade == 3 then
          OpenGetConfiscatedItemsMenu()
        end
		
		if data.current.value == 'remove_weapons' then
		  OpenPutWeaponMenu()
		end
		
		if data.current.value == 'remove_all_weapons' then
		  ESX.ShowNotification('~g~Odstranjena~s~ vsa ~b~Oro�ja~s~.')
		  RemoveAllPedWeapons(GetPlayerPed(-1), true)
		end
		

      end,
      function(data, menu)

        menu.close()

        CurrentAction     = 'menu_armory'
        CurrentActionMsg  = _U('open_armory')
        CurrentActionData = {station = station}
      end
    )

end

local police_vehicles = { 
  'hexer',
  'caracara',
  'emerus'
}

function VehicleExtrasMenu()
	local ped = GetPlayerPed(-1)
	local veh = GetVehiclePedIsUsing(ped)
	local liveries = GetVehicleLiveryCount(veh)
	
    local elements = {
		{label = 'Fix vehicle',   value = 'repair'},
		{label = 'Clean vehicle',   value = 'wash'},
		{label = 'Delete vehicle',  value = 'delete_vehicle'},
		{label = 'Change colour',  value = 'color_change'}

	}
	
	if liveries >= 2 then
		table.insert(elements, {label = 'Change stickers', value = 'livery_change'})
	else
		table.insert(elements, {label = 'This vehicle has no stickers ...', value = ''})
	end
	
	if DoesExtraExist(veh, 1) or DoesExtraExist(veh, 0) then
		table.insert(elements, {label = 'Get all extras', value = 'extrasON'})
		table.insert(elements, {label = 'Remove all extras', value = 'extrasOFF'})
	else
		table.insert(elements, {label = 'To vozilo nima dodatkov...', value = ''})
	end
	

	
	for i = 1, 9, 1 do
		if DoesExtraExist(veh, i) then
			table.insert(elements, {label = 'Extra item ' .. i, value = 'extra' .. i})
		else
		break
		end
	end

	ESX.UI.Menu.CloseAll()
	
    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'vozila_extras',
      {
        title    = 'Vehicle garage menu',
        align    = 'right',
        elements = elements
      },
      function(data, menu)

      local model = data.current.value
	  
	  
	  if model == 'color_change' then
		
		local barve = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 67, 62, 32}
		local i = math.random(#barve)
		local polmav = GetHashKey('polmav')
			
		local vehnow = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		local niavta = true
		local vehnow2 = GetEntityModel(vehnow)
		local vehnow3 = GetDisplayNameFromVehicleModel(vehnow2)
		for j=1, #police_vehicles, 1 do
			local police_vehicle = police_vehicles[j]
			local hashkey = GetHashKey(police_vehicle)
			if hashkey == vehnow2 and hashkey ~= polmav then
				SetVehicleColours(veh, barve[i], barve[i])
				niavta = false
				break
			end

		end
		if niavta then
			ESX.ShowNotification('This vehicle ~ s ~ does not have ~ s ~ permits to change the color ~ s ~!')
		end
 
	  end
	  if model == 'livery_change' then
	 
		
		local i = math.random(3)
		local j = math.random(3)

		if i == j then
			i = i - j
			SetVehicleLivery(veh, i)
		else
			SetVehicleLivery(veh, i)
		end

	  end
	 
 
		  if model == 'extra1' and not IsVehicleExtraTurnedOn(veh, 1) then
				SetVehicleExtra(veh, 1, 0)
				SetVehicleFixed(veh)
		  elseif model == 'extra1' and IsVehicleExtraTurnedOn(veh, 1) then
				SetVehicleExtra(veh, 1, 1)
				SetVehicleFixed(veh)
		  end
		  if model == 'extra2' and not IsVehicleExtraTurnedOn(veh, 2) then
				SetVehicleExtra(veh, 2, 0)
				SetVehicleFixed(veh)
		  elseif model == 'extra2' and IsVehicleExtraTurnedOn(veh, 2) then
				SetVehicleExtra(veh, 2, 1)
				SetVehicleFixed(veh)
		  end
		  if model == 'extra3' and not IsVehicleExtraTurnedOn(veh, 3) then
				SetVehicleExtra(veh, 3, 0)
				SetVehicleFixed(veh)
		  elseif model == 'extra3' and IsVehicleExtraTurnedOn(veh, 3) then
				SetVehicleExtra(veh, 3, 1)
				SetVehicleFixed(veh)
		  end
		  if model == 'extra4' and not IsVehicleExtraTurnedOn(veh, 4) then
				SetVehicleExtra(veh, 4, 0)
				SetVehicleFixed(veh)
		  elseif model == 'extra4' and IsVehicleExtraTurnedOn(veh, 4) then
				SetVehicleExtra(veh, 4, 1)
				SetVehicleFixed(veh)
		  end
		  if model == 'extra5' and not IsVehicleExtraTurnedOn(veh, 5) then
				SetVehicleExtra(veh, 5, 0)
				SetVehicleFixed(veh)
		  elseif model == 'extra5' and IsVehicleExtraTurnedOn(veh, 5) then
				SetVehicleExtra(veh, 5, 1)
				SetVehicleFixed(veh)
		  end
		  if model == 'extra6' and not IsVehicleExtraTurnedOn(veh, 6) then
				SetVehicleExtra(veh, 6, 0)
				SetVehicleFixed(veh)
		  elseif model == 'extra6' and IsVehicleExtraTurnedOn(veh, 6) then
				SetVehicleExtra(veh, 6, 1)
				SetVehicleFixed(veh)
		  end
		  if model == 'extra7' and not IsVehicleExtraTurnedOn(veh, 7) then
				SetVehicleExtra(veh, 7, 0)
				SetVehicleFixed(veh)
		  elseif model == 'extra7' and IsVehicleExtraTurnedOn(veh, 7) then
				SetVehicleExtra(veh, 7, 1)
				SetVehicleFixed(veh)
		  end
		  if model == 'extra8' and not IsVehicleExtraTurnedOn(veh, 8) then
				SetVehicleExtra(veh, 8, 0)
				SetVehicleFixed(veh)
		  elseif model == 'extra8' and IsVehicleExtraTurnedOn(veh, 8) then
				SetVehicleExtra(veh, 8, 1)
				SetVehicleFixed(veh)
		  end
		  if model == 'extra9' and not IsVehicleExtraTurnedOn(veh, 9) then
				SetVehicleExtra(veh, 9, 0)
				SetVehicleFixed(veh)
		  elseif model == 'extra9' and IsVehicleExtraTurnedOn(veh, 9) then
				SetVehicleExtra(veh, 9, 1)
				SetVehicleFixed(veh)
		  end

	  if model == 'extrasON' then
		SetVehicleExtra(veh, 1, 0)
		SetVehicleExtra(veh, 2, 0)
		SetVehicleExtra(veh, 3, 0)
		SetVehicleExtra(veh, 4, 0)
		SetVehicleExtra(veh, 5, 0)
		SetVehicleExtra(veh, 6, 0)
		SetVehicleExtra(veh, 7, 0)
		SetVehicleExtra(veh, 8, 0)
		SetVehicleExtra(veh, 9, 0)
		SetVehicleFixed(veh)
	  end
	  if model == 'extrasOFF' then
		SetVehicleExtra(veh, 1, 1)
		SetVehicleExtra(veh, 2, 1)
		SetVehicleExtra(veh, 3, 1)
		SetVehicleExtra(veh, 4, 1)
		SetVehicleExtra(veh, 5, 1)
		SetVehicleExtra(veh, 6, 1)
		SetVehicleExtra(veh, 7, 1)
		SetVehicleExtra(veh, 8, 1)
		SetVehicleExtra(veh, 9, 1)
		SetVehicleFixed(veh)
	  end
	  
	  if model == 'repair' then
	  
		
		local vehnow = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		local niavta = true
		local vehnow2 = GetEntityModel(vehnow)
		--local vehnow3 = GetDisplayNameFromVehicleModel(vehnow2)
		for i=1, #police_vehicles, 1 do
			local police_vehicle = police_vehicles[i]
			local hashkey = GetHashKey(police_vehicle)
			if hashkey == vehnow2 then
				SetVehicleFixed(veh)
				ESX.ShowNotification('Vehicle repaired ... ')
				niavta = false
				break
			end

		end
		if niavta then
			ESX.ShowNotification('This vehicle ~ r ~ has no permits! ~ S ~')
		end
		
	  end

	  if model == 'wash' then
	  
		
		local vehnow = GetVehiclePedIsIn(GetPlayerPed(-1), false)

		local niavta = true
		local vehnow2 = GetEntityModel(vehnow)
		local vehnow3 = GetDisplayNameFromVehicleModel(vehnow2)
		for i=1, #police_vehicles, 1 do
			local police_vehicle = police_vehicles[i]
			local hashkey = GetHashKey(police_vehicle)
			if hashkey == vehnow2 then
				WashDecalsFromVehicle(veh, 1.0)
				SetVehicleDirtLevel(veh)
				ESX.ShowNotification('Vehicle cleaned ... ')
				niavta = false
				break
			end

		end
		if niavta then
			ESX.ShowNotification('This vehicle has no permits!~s~')
		end
		
	  end
	  
	  
	  
      if model == 'delete_vehicle' then
		local vehnow = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		local niavta = true
		local vehnow2 = GetEntityModel(vehnow)
		local vehnow3 = GetDisplayNameFromVehicleModel(vehnow2)
		for i=1, #police_vehicles, 1 do
			local police_vehicle = police_vehicles[i]
			local hashkey = GetHashKey(police_vehicle)
			if hashkey == vehnow2 then
				ESX.Game.DeleteVehicle(veh)
				ESX.ShowNotification('Vehicle deleted... ')
				niavta = false
				menu.close()
				break
			end
		
		end
		if niavta then
			ESX.ShowNotification('This vehicle has no permits!')
		end

      end
	  
        CurrentAction     = ''
        CurrentActionMsg  = ''
        CurrentActionData  = {}
	  end,
      function(data, menu)

        menu.close()

        CurrentAction     = ''
        CurrentActionMsg  = ''
        CurrentActionData  = {}
      end
    )
end

function OpenGetWeaponMenu()

  ESX.TriggerServerCallback('esx_voltamafia:getArmoryWeapons', function(weapons)

    local elements = {}

    for i=1, #weapons, 1 do
      if weapons[i].count > 0 then
        table.insert(elements, {label = 'x' .. weapons[i].count .. ' ' .. ESX.GetWeaponLabel(weapons[i].name), value = weapons[i].name})
      end
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'armory_get_weapon',
      {
        title    = _U('get_weapon_menu'),
        align    = 'top-left',
        elements = elements,
      },
      function(data, menu)

        menu.close()

        ESX.TriggerServerCallback('esx_voltamafia:removeArmoryWeapon', function()
          OpenGetWeaponMenu()
        end, data.current.value)

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenPutWeaponMenu()

  local elements   = {}
  local playerPed  = GetPlayerPed(-1)
  local weaponList = ESX.GetWeaponList()

  for i=1, #weaponList, 1 do

    local weaponHash = GetHashKey(weaponList[i].name)

    if HasPedGotWeapon(playerPed,  weaponHash,  false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
      local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
      table.insert(elements, {label = weaponList[i].label, value = weaponList[i].name})
    end

  end

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'armory_put_weapon',
    {
      title    = 'Shrani orozje',
      align    = 'top-left',
      elements = elements,
    },
    function(data, menu)

      menu.close()

      ESX.TriggerServerCallback('esx_voltamafia:addArmoryWeapon', function()
        OpenPutWeaponMenu()
      end, data.current.value)

    end,
    function(data, menu)
      menu.close()
    end
  )

end

function OpenBuyWeaponsMenu(station)

  ESX.TriggerServerCallback('esx_voltamafia:getArmoryWeapons', function(weapons)

    local elements = {}

    for i=1, #Config.mafiaStations[station].AuthorizedWeapons, 1 do

      local weapon = Config.mafiaStations[station].AuthorizedWeapons[i]
      local count  = 0

      for i=1, #weapons, 1 do
        if weapons[i].name == weapon.name then
          count = weapons[i].count
          break
        end
      end

      table.insert(elements, {label = 'x' .. count .. ' ' .. ESX.GetWeaponLabel(weapon.name) .. ' $' .. weapon.price, value = weapon.name, price = weapon.price})

    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'armory_buy_weapons',
      {
        title    = 'Mafijska shramba',
        align    = 'top-left',
        elements = elements,
      },
      function(data, menu)

        ESX.TriggerServerCallback('esx_voltamafia:buy', function(hasEnoughMoney)

          if hasEnoughMoney then
            ESX.TriggerServerCallback('esx_voltamafia:addArmoryWeapon', function()
              OpenBuyWeaponsMenu(station)
            end, data.current.value)
          else
            ESX.ShowNotification('not_enough_money')
          end

        end, data.current.price)

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenGetStocksMenu()

  ESX.TriggerServerCallback('esx_voltamafia:getStockItems', function(items)

    print(json.encode(items))

    local elements = {}

    for i=1, #items, 1 do
      table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = _U('get_stock'),
		align    = 'top-left',
        elements = elements
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
          {
            title = _U('quantity')
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil then
              ESX.ShowNotification('quantity_invalid')
            else
              menu2.close()
              menu.close()
              OpenGetStocksMenu()

              TriggerServerEvent('esx_voltamafia:getStockItem', itemName, count)
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenVehicleSpawnerMenu(station, partNum)

  local vehicles = Config.mafiaStations[station].Vehicles

  ESX.UI.Menu.CloseAll()

  if Config.EnableSocietyOwnedVehicles then

    local elements = {}

    ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(garageVehicles)

      for i=1, #garageVehicles, 1 do
        table.insert(elements, {label = GetDisplayNameFromVehicleModel(garageVehicles[i].model) .. ' [' .. garageVehicles[i].plate .. ']', value = garageVehicles[i]})
      end

      ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'vehicle_spawner',
        {
          title    = _U('vehicle_menu'),
          align    = 'top-left',
          elements = elements,
        },
        function(data, menu)

          menu.close()

          local vehicleProps = data.current.value

          ESX.Game.SpawnVehicle(vehicleProps.model, vehicles[partNum].SpawnPoint, 270.0, function(vehicle)
            SetVehicleCustomPrimaryColour(vehicle, Config.PrimaryRGB[1], Config.PrimaryRGB[2], Config.PrimaryRGB[3])
            SetVehicleCustomSecondaryColour(vehicle, Config.SecondaryRGB[1], Config.SecondaryRGB[2], Config.SecondaryRGB[3])
            SetVehicleNumberPlateText(vehicle, Config.Plate)
            ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
            local playerPed = GetPlayerPed(-1)
            TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
          end)

          TriggerServerEvent('esx_society:removeVehicleFromGarage', 'mafia', vehicleProps)

        end,
        function(data, menu)

          menu.close()

          CurrentAction     = 'menu_vehicle_spawner'
          CurrentActionMsg  = _U('vehicle_spawner')
          CurrentActionData = {station = station, partNum = partNum}

        end
      )

    end, 'mafia')

  else

    local elements = {}

    for i=1, #Config.mafiaStations[station].AuthorizedVehicles, 1 do
      local vehicle = Config.mafiaStations[station].AuthorizedVehicles[i]
      table.insert(elements, {label = vehicle.label, value = vehicle.name})
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'vehicle_spawner',
      {
        title    = _U('vehicle_menu'),
        align    = 'top-left',
        elements = elements,
      },
      function(data, menu)

        menu.close()

        local model = data.current.value

        local vehicle = GetClosestVehicle(vehicles[partNum].SpawnPoint.x,  vehicles[partNum].SpawnPoint.y,  vehicles[partNum].SpawnPoint.z,  3.0,  0,  71)

        if not DoesEntityExist(vehicle) then

          local playerPed = GetPlayerPed(-1)

          if Config.MaxInService == -1 then

            ESX.Game.SpawnVehicle(model, {
              x = vehicles[partNum].SpawnPoint.x,
              y = vehicles[partNum].SpawnPoint.y,
              z = vehicles[partNum].SpawnPoint.z
            }, vehicles[partNum].Heading, function(vehicle)
              TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
              SetVehicleMaxMods(vehicle)
              SetVehicleNumberPlateText(vehicle, Config.Plate)
              SetVehicleCustomPrimaryColour(vehicle, Config.PrimaryRGB[1], Config.PrimaryRGB[2], Config.PrimaryRGB[3])
              SetVehicleCustomSecondaryColour(vehicle, Config.SecondaryRGB[1], Config.SecondaryRGB[2], Config.SecondaryRGB[3])
            end)

          else

            ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)

              if canTakeService then

                ESX.Game.SpawnVehicle(model, {
                  x = vehicles[partNum].SpawnPoint.x,
                  y = vehicles[partNum].SpawnPoint.y,
                  z = vehicles[partNum].SpawnPoint.z
                }, vehicles[partNum].Heading, function(vehicle)
                  TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
                  SetVehicleMaxMods(vehicle)
                  SetVehicleNumberPlateText(vehicle, Config.Plate)
                  SetVehicleCustomPrimaryColour(vehicle, Config.PrimaryRGB[1], Config.PrimaryRGB[2], Config.PrimaryRGB[3])
                  SetVehicleCustomSecondaryColour(vehicle, Config.SecondaryRGB[1], Config.SecondaryRGB[2], Config.SecondaryRGB[3])
                end)

              else
                ESX.ShowNotification(_U('service_max') .. inServiceCount .. '/' .. maxInService)
              end

            end, 'mafia')

          end

        else
          ESX.ShowNotification(_U('vehicle_out'))
        end

      end,
      function(data, menu)

        menu.close()

        CurrentAction     = 'menu_vehicle_spawner'
        CurrentActionMsg  = _U('vehicle_spawner')
        CurrentActionData = {station = station, partNum = partNum}

      end
    )

  end

end

function OpenBallasActionsMenu()

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'ballas_actions',
    {
      title    = 'Mafia',
      align    = 'top-left',
      elements = {
        {label = _U('citizen_interaction'), value = 'citizen_interaction'},
        {label = _U('vehicle_interaction'), value = 'vehicle_interaction'},
      },
    },
    function(data, menu)

      if data.current.value == 'citizen_interaction' then

        ESX.UI.Menu.Open(
          'default', GetCurrentResourceName(), 'citizen_interaction',
          {
            title    = _U('citizen_interaction'),
            align    = 'top-left',
            elements = {
              {label = _U('id_card'),       value = 'identity_card'},
              {label = _U('search'),        value = 'body_search'},
              {label = _U('handcuff'),    value = 'handcuff'},
              {label = _U('drag'),      value = 'drag'},
              {label = _U('put_in_vehicle'),  value = 'put_in_vehicle'},
              {label = _U('out_the_vehicle'), value = 'out_the_vehicle'}
            },
          },
          function(data2, menu2)

            local player, distance = ESX.Game.GetClosestPlayer()

            if distance ~= -1 and distance <= 3.0 then

              if data2.current.value == 'identity_card' then
                OpenIdentityCardMenu(player)
              end

              if data2.current.value == 'body_search' then
                OpenBodySearchMenu(player)
              end

              if data2.current.value == 'handcuff' then
                TriggerServerEvent('esx_voltamafia:handcuff', GetPlayerServerId(player))
              end

              if data2.current.value == 'drag' then
                TriggerServerEvent('esx_voltamafia:drag', GetPlayerServerId(player))
              end

              if data2.current.value == 'put_in_vehicle' then
                TriggerServerEvent('esx_voltamafia:putInVehicle', GetPlayerServerId(player))
              end

              if data2.current.value == 'out_the_vehicle' then
                  TriggerServerEvent('esx_voltamafia:OutVehicle', GetPlayerServerId(player))
              end

            else
              ESX.ShowNotification(_U('no_players_nearby'))
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end

      if data.current.value == 'vehicle_interaction' then

        ESX.UI.Menu.Open(
          'default', GetCurrentResourceName(), 'vehicle_interaction',
          {
            title    = _U('vehicle_interaction'),
            align    = 'top-left',
            elements = {
              {label = _U('vehicle_info'), value = 'vehicle_infos'},
              {label = _U('pick_lock'),    value = 'hijack_vehicle'},
            },
          },
          function(data2, menu2)

            local playerPed = GetPlayerPed(-1)
            local coords    = GetEntityCoords(playerPed)
            local vehicle   = GetClosestVehicle(coords.x,  coords.y,  coords.z,  3.0,  0,  71)

            if DoesEntityExist(vehicle) then

              local vehicleData = ESX.Game.GetVehicleProperties(vehicle)

              if data2.current.value == 'vehicle_infos' then
                OpenVehicleInfosMenu(vehicleData)
              end

              if data2.current.value == 'hijack_vehicle' then

                local playerPed = GetPlayerPed(-1)
                local coords    = GetEntityCoords(playerPed)

                if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then

                  local vehicle = GetClosestVehicle(coords.x,  coords.y,  coords.z,  3.0,  0,  71)

                  if DoesEntityExist(vehicle) then

                    Citizen.CreateThread(function()

                      TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)

                      Wait(20000)

                      ClearPedTasksImmediately(playerPed)

                      SetVehicleDoorsLocked(vehicle, 1)
                      SetVehicleDoorsLockedForAllPlayers(vehicle, false)

                      TriggerEvent('esx:showNotification', _U('vehicle_unlocked'))

                    end)

                  end

                end

              end

            else
              ESX.ShowNotification(_U('no_vehicles_nearby'))
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end

    end,
    function(data, menu)

      menu.close()

    end
  )

end

function OpenIdentityCardMenu(player)

  if Config.EnableESXIdentity then

    ESX.TriggerServerCallback('esx_voltamafia:getOtherPlayerData', function(data)

      local jobLabel    = nil
      local sexLabel    = nil
      local sex         = nil
      local dobLabel    = nil
      local heightLabel = nil
      local idLabel     = nil

      if data.job.grade_label ~= nil and  data.job.grade_label ~= '' then
        jobLabel = 'Job : ' .. data.job.label .. ' - ' .. data.job.grade_label
      else
        jobLabel = 'Job : ' .. data.job.label
      end

      if data.sex ~= nil then
        if (data.sex == 'm') or (data.sex == 'M') then
          sex = 'Male'
        else
          sex = 'Female'
        end
        sexLabel = 'Sex : ' .. sex
      else
        sexLabel = 'Sex : Unknown'
      end

      if data.dob ~= nil then
        dobLabel = 'DOB : ' .. data.dob
      else
        dobLabel = 'DOB : Unknown'
      end

      if data.height ~= nil then
        heightLabel = 'Height : ' .. data.height
      else
        heightLabel = 'Height : Unknown'
      end

      if data.name ~= nil then
        idLabel = 'ID : ' .. data.name
      else
        idLabel = 'ID : Unknown'
      end

      local elements = {
        {label = _U('name') .. data.firstname .. " " .. data.lastname, value = nil},
        {label = sexLabel,    value = nil},
        {label = dobLabel,    value = nil},
        {label = heightLabel, value = nil},
        {label = jobLabel,    value = nil},
        {label = idLabel,     value = nil},
      }

      if data.drunk ~= nil then
        table.insert(elements, {label = _U('bac') .. data.drunk .. '%', value = nil})
      end

      if data.licenses ~= nil then

        table.insert(elements, {label = '--- Licenses ---', value = nil})

        for i=1, #data.licenses, 1 do
          table.insert(elements, {label = data.licenses[i].label, value = nil})
        end

      end

      ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'citizen_interaction',
        {
          title    = _U('citizen_interaction'),
          align    = 'top-left',
          elements = elements,
        },
        function(data, menu)

        end,
        function(data, menu)
          menu.close()
        end
      )

    end, GetPlayerServerId(player))

  else

    ESX.TriggerServerCallback('esx_voltamafia:getOtherPlayerData', function(data)

      local jobLabel = nil

      if data.job.grade_label ~= nil and  data.job.grade_label ~= '' then
        jobLabel = 'Job : ' .. data.job.label .. ' - ' .. data.job.grade_label
      else
        jobLabel = 'Job : ' .. data.job.label
      end

        local elements = {
          {label = _U('name') .. data.name, value = nil},
          {label = jobLabel,              value = nil},
        }

      if data.drunk ~= nil then
        table.insert(elements, {label = _U('bac') .. data.drunk .. '%', value = nil})
      end

      if data.licenses ~= nil then

        table.insert(elements, {label = '--- Licenses ---', value = nil})

        for i=1, #data.licenses, 1 do
          table.insert(elements, {label = data.licenses[i].label, value = nil})
        end

      end

      ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'citizen_interaction',
        {
          title    = _U('citizen_interaction'),
          align    = 'top-left',
          elements = elements,
        },
        function(data, menu)

        end,
        function(data, menu)
          menu.close()
        end
      )

    end, GetPlayerServerId(player))

  end

end

function OpenBodySearchMenu(player)

  ESX.TriggerServerCallback('esx_voltamafia:getOtherPlayerData', function(data)

    local elements = {}

    local blackMoney = 0

    for i=1, #data.accounts, 1 do
      if data.accounts[i].name == 'black_money' then
        blackMoney = data.accounts[i].money
      end
    end

    table.insert(elements, {
      label          = _U('confiscate_dirty') .. blackMoney,
      value          = 'black_money',
      itemType       = 'item_account',
      amount         = blackMoney
    })

    table.insert(elements, {label = '--- Armes ---', value = nil})

    for i=1, #data.weapons, 1 do
      table.insert(elements, {
        label          = _U('confiscate') .. ESX.GetWeaponLabel(data.weapons[i].name),
        value          = data.weapons[i].name,
        itemType       = 'item_weapon',
        amount         = data.ammo,
      })
    end

    table.insert(elements, {label = _U('inventory_label'), value = nil})

    for i=1, #data.inventory, 1 do
      if data.inventory[i].count > 0 then
        table.insert(elements, {
          label          = _U('confiscate_inv') .. data.inventory[i].count .. ' ' .. data.inventory[i].label,
          value          = data.inventory[i].name,
          itemType       = 'item_standard',
          amount         = data.inventory[i].count,
        })
      end
    end


    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'body_search',
      {
        title    = _U('search'),
        align    = 'top-left',
        elements = elements,
      },
      function(data, menu)

        local itemType = data.current.itemType
        local itemName = data.current.value
        local amount   = data.current.amount

        if data.current.value ~= nil then

          TriggerServerEvent('esx_voltamafia:confiscatePlayerItem', GetPlayerServerId(player), itemType, itemName, amount)

          OpenBodySearchMenu(player)

        end

      end,
      function(data, menu)
        menu.close()
      end
    )

  end, GetPlayerServerId(player))

end

function OpenVehicleInfosMenu(vehicleData)

  ESX.TriggerServerCallback('esx_voltamafia:getVehicleInfos', function(infos)

    local elements = {}

    table.insert(elements, {label = _U('plate') .. infos.plate, value = nil})

    if infos.owner == nil then
      table.insert(elements, {label = _U('owner_unknown'), value = nil})
    else
      table.insert(elements, {label = _U('owner') .. infos.owner, value = nil})
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'vehicle_infos',
      {
        title    = _U('vehicle_info'),
        align    = 'top-left',
        elements = elements,
      },
      nil,
      function(data, menu)
        menu.close()
      end
    )

  end, vehicleData.plate)

end

function OpenGetWeaponMenu()

  ESX.TriggerServerCallback('esx_voltamafia:getArmoryWeapons', function(weapons)

    local elements = {}

    for i=1, #weapons, 1 do
      if weapons[i].count > 0 then
        table.insert(elements, {label = 'x' .. weapons[i].count .. ' ' .. ESX.GetWeaponLabel(weapons[i].name), value = weapons[i].name})
      end
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'armory_get_weapon',
      {
        title    = _U('get_weapon_menu'),
        align    = 'top-left',
        elements = elements,
      },
      function(data, menu)

        menu.close()

        ESX.TriggerServerCallback('esx_voltamafia:removeArmoryWeapon', function()
          OpenGetWeaponMenu()
        end, data.current.value)

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenPutWeaponMenu()

  local elements   = {}
  local playerPed  = GetPlayerPed(-1)
  local weaponList = ESX.GetWeaponList()

  for i=1, #weaponList, 1 do

    local weaponHash = GetHashKey(weaponList[i].name)

    if HasPedGotWeapon(playerPed,  weaponHash,  false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
      local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
      table.insert(elements, {label = weaponList[i].label, value = weaponList[i].name})
    end

  end

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'armory_put_weapon',
    {
      title    = _U('put_weapon_menu'),
      align    = 'top-left',
      elements = elements,
    },
    function(data, menu)

      menu.close()

      ESX.TriggerServerCallback('esx_voltamafia:addArmoryWeapon', function()
        OpenPutWeaponMenu()
      end, data.current.value)

    end,
    function(data, menu)
      menu.close()
    end
  )

end

function OpenBuyWeaponsMenu(station)

  ESX.TriggerServerCallback('esx_voltamafia:getArmoryWeapons', function(weapons)

    local elements = {}

    for i=1, #Config.mafiaStations[station].AuthorizedWeapons, 1 do

      local weapon = Config.mafiaStations[station].AuthorizedWeapons[i]
      local count  = 0

      for i=1, #weapons, 1 do
        if weapons[i].name == weapon.name then
          count = weapons[i].count
          break
        end
      end

      table.insert(elements, {label = 'x' .. count .. ' ' .. ESX.GetWeaponLabel(weapon.name) .. ' $' .. weapon.price, value = weapon.name, price = weapon.price})

    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'armory_buy_weapons',
      {
        title    = _U('buy_weapon_menu'),
        align    = 'top-left',
        elements = elements,
      },
      function(data, menu)

        ESX.TriggerServerCallback('esx_voltamafia:buy', function(hasEnoughMoney)

          if hasEnoughMoney then
            ESX.TriggerServerCallback('esx_voltamafia:addArmoryWeapon', function()
              OpenBuyWeaponsMenu(station)
            end, data.current.value)
          else
            ESX.ShowNotification(_U('not_enough_money'))
          end

        end, data.current.price)

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenGetStocksMenu()

  ESX.TriggerServerCallback('esx_voltamafia:getStockItems', function(items)

    print(json.encode(items))

    local elements = {}

    for i=1, #items, 1 do
      table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = _U('ballas_stock'),
        elements = elements
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
          {
            title = _U('quantity')
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil then
              ESX.ShowNotification(_U('quantity_invalid'))
            else
              menu2.close()
              menu.close()
              OpenGetStocksMenu()

              TriggerServerEvent('esx_voltamafia:getStockItem', itemName, count)
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenPutStocksMenu()

	ESX.TriggerServerCallback('esx_voltamafia:getPlayerInventory', function(inventory)

		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu',
		{
			title    = _U('inventory'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)

			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)

				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_voltamafia:putStockItems', itemName, count)

					Citizen.Wait(300)
					OpenPutStocksMenu()
				end

			end, function(data2, menu2)
				menu2.close()
			end)

		end, function(data, menu)
			menu.close()
		end)
	end)

end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

AddEventHandler('esx_voltamafia:hasEnteredMarker', function(station, part, partNum)

  if part == 'Armory' then
    CurrentAction     = 'menu_armory'
    CurrentActionMsg  = _U('open_armory')
    CurrentActionData = {station = station}
  end

  if part == 'VehicleSpawner' then
    CurrentAction     = 'menu_vehicle_spawner'
    CurrentActionMsg  = _U('vehicle_spawner')
    CurrentActionData = {station = station, partNum = partNum}
  end

  if part == 'VehicleDeleter' then

	if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
		VehicleExtrasMenu()
	else
		ESX.ShowNotification('Nisi v vozilu.')
	end

  end

  if part == 'BossActions' then
    CurrentAction     = 'menu_boss_actions'
    CurrentActionMsg  = _U('open_bossmenu')
    CurrentActionData = {}
  end

end)

AddEventHandler('esx_voltamafia:hasExitedMarker', function(station, part, partNum)
  ESX.UI.Menu.CloseAll()
  CurrentAction = nil
end)

RegisterNetEvent('esx_voltamafia:handcuff')
AddEventHandler('esx_voltamafia:handcuff', function()

  IsHandcuffed    = not IsHandcuffed;
  local playerPed = GetPlayerPed(-1)

  Citizen.CreateThread(function()

    if IsHandcuffed then

      RequestAnimDict('mp_arresting')

      while not HasAnimDictLoaded('mp_arresting') do
        Wait(100)
      end

      TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
      SetEnableHandcuffs(playerPed, true)
      SetPedCanPlayGestureAnims(playerPed, false)
      FreezeEntityPosition(playerPed,  true)

    else

      ClearPedSecondaryTask(playerPed)
      SetEnableHandcuffs(playerPed, false)
      SetPedCanPlayGestureAnims(playerPed,  true)
      FreezeEntityPosition(playerPed, false)

    end

  end)
end)

RegisterNetEvent('esx_voltamafia:drag')
AddEventHandler('esx_voltamafia:drag', function(cop)
  TriggerServerEvent('esx:clientLog', 'starting dragging')
  IsDragged = not IsDragged
  CopPed = tonumber(cop)
end)

Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      if IsDragged then
        local ped = GetPlayerPed(GetPlayerFromServerId(CopPed))
        local myped = GetPlayerPed(-1)
        AttachEntityToEntity(myped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
      else
        DetachEntity(GetPlayerPed(-1), true, false)
      end
    end
  end
end)

RegisterNetEvent('esx_voltamafia:putInVehicle')
AddEventHandler('esx_voltamafia:putInVehicle', function()

  local playerPed = GetPlayerPed(-1)
  local coords    = GetEntityCoords(playerPed)

  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

    local vehicle = GetClosestVehicle(coords.x,  coords.y,  coords.z,  5.0,  0,  71)

    if DoesEntityExist(vehicle) then

      local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
      local freeSeat = nil

      for i=maxSeats - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle,  i) then
          freeSeat = i
          break
        end
      end

      if freeSeat ~= nil then
        TaskWarpPedIntoVehicle(playerPed,  vehicle,  freeSeat)
      end

    end

  end

end)

RegisterNetEvent('esx_voltamafia:OutVehicle')
AddEventHandler('esx_voltamafia:OutVehicle', function(t)
  local ped = GetPlayerPed(t)
  ClearPedTasksImmediately(ped)
  plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
  local xnew = plyPos.x+2
  local ynew = plyPos.y+2

  SetEntityCoords(GetPlayerPed(-1), xnew, ynew, plyPos.z)
end)

-- Handcuff
Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 30,  true) -- MoveLeftRight
      DisableControlAction(0, 31,  true) -- MoveUpDown
    end
  end
end)

-- Display markers
Citizen.CreateThread(function()
  while true do

    Wait(0)

    if PlayerData.job ~= nil and PlayerData.job.name == 'mafia' then

      local playerPed = GetPlayerPed(-1)
      local coords    = GetEntityCoords(playerPed)

      for k,v in pairs(Config.mafiaStations) do

        for i=1, #v.Armories, 1 do
          if GetDistanceBetweenCoords(coords,  v.Armories[i].x,  v.Armories[i].y,  v.Armories[i].z,  true) < Config.DrawDistance then
            DrawMarker(Config.MarkerType, v.Armories[i].x, v.Armories[i].y, v.Armories[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
          end
        end

        for i=1, #v.Vehicles, 1 do
          if GetDistanceBetweenCoords(coords,  v.Vehicles[i].Spawner.x,  v.Vehicles[i].Spawner.y,  v.Vehicles[i].Spawner.z,  true) < Config.DrawDistance then
            DrawMarker(Config.MarkerType, v.Vehicles[i].Spawner.x, v.Vehicles[i].Spawner.y, v.Vehicles[i].Spawner.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
          end
        end

        for i=1, #v.VehicleDeleters, 1 do
          if GetDistanceBetweenCoords(coords,  v.VehicleDeleters[i].x,  v.VehicleDeleters[i].y,  v.VehicleDeleters[i].z,  true) < Config.DrawDistance then
            DrawMarker(Config.MarkerType, v.VehicleDeleters[i].x, v.VehicleDeleters[i].y, v.VehicleDeleters[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
          end
        end

        if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.name == 'mafia' and PlayerData.job.grade_name == 'boss' then

          for i=1, #v.BossActions, 1 do
            if not v.BossActions[i].disabled and GetDistanceBetweenCoords(coords,  v.BossActions[i].x,  v.BossActions[i].y,  v.BossActions[i].z,  true) < Config.DrawDistance then
              DrawMarker(Config.MarkerType, v.BossActions[i].x, v.BossActions[i].y, v.BossActions[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
            end
          end

        end

      end

    end

  end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()

  while true do

    Wait(0)

    if PlayerData.job ~= nil and PlayerData.job.name == 'mafia' then

      local playerPed      = GetPlayerPed(-1)
      local coords         = GetEntityCoords(playerPed)
      local isInMarker     = false
      local currentStation = nil
      local currentPart    = nil
      local currentPartNum = nil

      for k,v in pairs(Config.mafiaStations) do

        for i=1, #v.Armories, 1 do
          if GetDistanceBetweenCoords(coords,  v.Armories[i].x,  v.Armories[i].y,  v.Armories[i].z,  true) < Config.MarkerSize.x then
            isInMarker     = true
            currentStation = k
            currentPart    = 'Armory'
            currentPartNum = i
          end
        end

        for i=1, #v.Vehicles, 1 do

          if GetDistanceBetweenCoords(coords,  v.Vehicles[i].Spawner.x,  v.Vehicles[i].Spawner.y,  v.Vehicles[i].Spawner.z,  true) < Config.MarkerSize.x then
            isInMarker     = true
            currentStation = k
            currentPart    = 'VehicleSpawner'
            currentPartNum = i
          end

          if GetDistanceBetweenCoords(coords,  v.Vehicles[i].SpawnPoint.x,  v.Vehicles[i].SpawnPoint.y,  v.Vehicles[i].SpawnPoint.z,  true) < Config.MarkerSize.x then
            isInMarker     = true
            currentStation = k
            currentPart    = 'VehicleSpawnPoint'
            currentPartNum = i
          end

        end

        for i=1, #v.VehicleDeleters, 1 do
          if GetDistanceBetweenCoords(coords,  v.VehicleDeleters[i].x,  v.VehicleDeleters[i].y,  v.VehicleDeleters[i].z,  true) < Config.MarkerSize.x then
            isInMarker     = true
            currentStation = k
            currentPart    = 'VehicleDeleter'
            currentPartNum = i
          end
        end

        if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.name == 'mafia' and PlayerData.job.grade_name == 'boss' then

          for i=1, #v.BossActions, 1 do
            if GetDistanceBetweenCoords(coords,  v.BossActions[i].x,  v.BossActions[i].y,  v.BossActions[i].z,  true) < Config.MarkerSize.x then
              isInMarker     = true
              currentStation = k
              currentPart    = 'BossActions'
              currentPartNum = i
            end
          end

        end

      end

      local hasExited = false

      if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum) ) then

        if
          (LastStation ~= nil and LastPart ~= nil and LastPartNum ~= nil) and
          (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
        then
          TriggerEvent('esx_voltamafia:hasExitedMarker', LastStation, LastPart, LastPartNum)
          hasExited = true
        end

        HasAlreadyEnteredMarker = true
        LastStation             = currentStation
        LastPart                = currentPart
        LastPartNum             = currentPartNum

        TriggerEvent('esx_voltamafia:hasEnteredMarker', currentStation, currentPart, currentPartNum)
      end

      if not hasExited and not isInMarker and HasAlreadyEnteredMarker then

        HasAlreadyEnteredMarker = false

        TriggerEvent('esx_voltamafia:hasExitedMarker', LastStation, LastPart, LastPartNum)
      end

    end

  end
end)

Citizen.CreateThread(function()
  while true do

    Citizen.Wait(0)

    if CurrentAction ~= nil then

      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlJustPressed(0, 38) and PlayerData.job ~= nil and PlayerData.job.name == 'mafia' and (GetGameTimer() - GUI.Time) > 150 then

        if CurrentAction == 'menu_armory' then
          OpenArmoryMenu(CurrentActionData.station)
        end

        if CurrentAction == 'menu_vehicle_spawner' then
          OpenVehicleSpawnerMenu(CurrentActionData.station, CurrentActionData.partNum)
        end

        if CurrentAction == 'delete_vehicle' then

          if Config.EnableSocietyOwnedVehicles then

            local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
            TriggerServerEvent('esx_society:putVehicleInGarage', 'mafia', vehicleProps)

          else

            if
              GetEntityModel(vehicle) == GetHashKey('schafter3')  or
              GetEntityModel(vehicle) == GetHashKey('kuruma2') or
              GetEntityModel(vehicle) == GetHashKey('sandking') or
              GetEntityModel(vehicle) == GetHashKey('mule3') or
              GetEntityModel(vehicle) == GetHashKey('guardian') or
              GetEntityModel(vehicle) == GetHashKey('burrito3') or
              GetEntityModel(vehicle) == GetHashKey('mesa')
            then
              TriggerServerEvent('esx_service:disableService', 'mafia')
            end

          end

          ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
        end

        if CurrentAction == 'menu_boss_actions' then
          ESX.UI.Menu.CloseAll()
		  TriggerEvent('esx_society:openBossMenu', 'mafia', function(data, menu)
			menu.close()

			CurrentAction     = 'menu_boss_actions'
			CurrentActionMsg  = _U('open_bossmenu')
			CurrentActionData = {}
			end, { wash = false })
        end

        CurrentAction = nil
        GUI.Time      = GetGameTimer()

      end

    end

   if IsControlJustPressed(0, 167) and PlayerData.job ~= nil and PlayerData.job.name == 'mafia' and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'ballas_actions') and (GetGameTimer() - GUI.Time) > 150 then
     OpenBallasActionsMenu()
     GUI.Time = GetGameTimer()
    end

  end
end)

---------------------------------------------------------------------------------------------------------
--NB : gestion des menu
---------------------------------------------------------------------------------------------------------

RegisterNetEvent('NB:openMenuBallas')
AddEventHandler('NB:openMenuBallas', function()
	OpenBallasActionsMenu()
end)
