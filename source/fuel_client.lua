local fuelSynced = false
local inBlacklisted = false
local inGasStation = false

function ManageFuelUsage(vehicle)
	if not DecorExistOn(vehicle, Config.FuelDecor) then
		SetFuel(vehicle, math.random(200, 800) / 10)
	elseif not fuelSynced then
		SetFuel(vehicle, GetFuel(vehicle))

		fuelSynced = true
	end

	if IsVehicleEngineOn(vehicle) then
		SetFuel(vehicle, GetVehicleFuelLevel(vehicle) - Config.FuelUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Config.Classes[GetVehicleClass(vehicle)] or 1.0) / 10)
	end
end

Citizen.CreateThread(function()
	DecorRegister(Config.FuelDecor, 1)

	for index = 1, #Config.Blacklist do
		if type(Config.Blacklist[index]) == 'string' then
			Config.Blacklist[GetHashKey(Config.Blacklist[index])] = true
		else
			Config.Blacklist[Config.Blacklist[index]] = true
		end
	end

	for index = #Config.Blacklist, 1, -1 do
		table.remove(Config.Blacklist, index)
	end

	while true do
		Citizen.Wait(1000)

		local ped = PlayerPedId()

		if IsPedInAnyVehicle(ped) then
			local vehicle = GetVehiclePedIsIn(ped)

			if Config.Blacklist[GetEntityModel(vehicle)] then
				inBlacklisted = true
			else
				inBlacklisted = false
			end

			if not inBlacklisted and GetPedInVehicleSeat(vehicle, -1) == ped then
				ManageFuelUsage(vehicle)
			end
		else
			if fuelSynced then
				fuelSynced = false
			end

			if inBlacklisted then
				inBlacklisted = false
			end
		end
	end
end)


RegisterNetEvent('irp-fule:client:SendMenuToServer', function() -- RELAY FROM CLIENT TO SERVER FOR MENU
	local vehicle = QBCore.Functions.GetClosestVehicle()
	local CurFuel = GetVehicleFuelLevel(vehicle)
	local refillCost = Round(Config.RefillCost - CurFuel) * Config.CostMultiplier

	if CurFuel < 95 then
		TriggerServerEvent('irp-fuel:server:OpenMenu', refillCost)
	else
		QBCore.Functions.Notify('This vehicle is already full.', 'error')
	end
end)


RegisterNetEvent('irp-fuel:client:RefuelVehicle', function(refillCost)
	local vehicle = QBCore.Functions.GetClosestVehicle()
	local ped = PlayerPedId()
	local CurFuel = GetVehicleFuelLevel(vehicle)
	local time = (100 - CurFuel) * 400
	------------------------------------------------------
	RequestAnimDict("weapon@w_sp_jerrycan")
    while not HasAnimDictLoaded('weapon@w_sp_jerrycan') do Citizen.Wait(100) end
    TaskPlayAnim(ped, "weapon@w_sp_jerrycan", "fire", 8.0, 1.0, -1, 1, 0, 0, 0, 0 )

    QBCore.Functions.Progressbar("refuel-car", "Refueling", time, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
		TriggerServerEvent('irp-fuel:server:PayForFuel', refillCost)
        SetFuel(vehicle, 100)
        PlaySound(-1, "5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
        StopAnimTask(ped, "weapon@w_sp_jerrycan", "fire", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
    end, function() -- Cancel
		QBCore.Functions.Notify('Refueling Canceld', 'error')
        StopAnimTask(ped, "weapon@w_sp_jerrycan", "fire", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
	end)
end)

RegisterNetEvent('polyzonehelper:enter')
AddEventHandler('polyzonehelper:enter', function(name)
	if name == "GasStations" then
		inGasStation = true
	end
end)

RegisterNetEvent('polyzonehelper:exit')
AddEventHandler('polyzonehelper:exit', function(name)
	if name == "GasStations" then
		inGasStation = false
	end
end)


Citizen.CreateThread(function() -- over here we add polyzones with polyzonehelper
    for k, v in pairs(Config.GasStations) do --shared lua from qb-garages
        exports["polyzonehelper"]:AddBoxZone('GasStations', vector3(Config.GasStations[k].polyzone.x, Config.GasStations[k].polyzone.y, Config.GasStations[k].polyzone.z), Config.GasStations[k].polyzone1, Config.GasStations[k].polyzone2, {
            name='GasStations', -- polyzone name
            heading = Config.GasStations[k].polyzoneHeading,
            debugPoly=false
        })
    end
end)


Citizen.CreateThread(function()
    local alreadyEnteredZone = false
    local text = nil
    while true do
        wait = 2000
        local ped = PlayerPedId()
		local inZone = false
		if inGasStation then
			if isCloseVeh() then
            	wait = 7
            	inZone  = true
            	text = '[E] To refuel the vehicle'

            	if IsControlJustReleased(0, 38) then
                	TriggerEvent('irp-fule:client:SendMenuToServer')
					TriggerEvent('cd_drawtextui:HideUI')
            	end
			end
        else
            wait = 2000
        end
        
        if inZone and not alreadyEnteredZone then
            alreadyEnteredZone = true
            TriggerEvent('cd_drawtextui:ShowUI', 'show', text)
        end

        if not inZone and alreadyEnteredZone then
            alreadyEnteredZone = false
            TriggerEvent('cd_drawtextui:HideUI')
        end
        Citizen.Wait(wait)
    end
end)

Citizen.CreateThread(function()
	for k, v in pairs(Config.GasStations) do
		local blip = AddBlipForCoord(Config.GasStations[k].polyzone.x, Config.GasStations[k].polyzone.y, Config.GasStations[k].polyzone.z)
		SetBlipSprite(blip, 415)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.7)
		SetBlipColour (blip, 1)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Gas Station')
		EndTextCommandSetBlipName(blip)
	end
end)