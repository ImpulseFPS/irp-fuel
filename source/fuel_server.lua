RegisterServerEvent('irp-fuel:server:OpenMenu', function(amount)
	local src = source
	if not src then return end
	local player = QBCore.Functions.GetPlayer(src)
	if not player then return end
	local tax = QBCore.Functions.GlobalTax(amount)
	local total = math.ceil(amount + tax)

	if player.PlayerData['money']['cash'] >= total then 

		TriggerClientEvent('nh-context:sendMenu', src, {
			{
				id = 1,
				header = 'Gas Station',
				txt = 'Refule the vehicle for: €'..total..' with tax included',
				params = {
					event = "irp-fuel:client:RefuelVehicle",
					args = total,
				}
			},
		})
	else 
		TriggerClientEvent('QBCore:Notify', src, 'No Money', 'error')
	end
end)

RegisterServerEvent('irp-fuel:server:PayForFuel', function(amount) -- WE ALREADY CHECKED ON CLIENT SIDE IF PLAYER HAS THE MONEY TO PAY FOR FUEL
	local src = source
	if not src then return end
	local player = QBCore.Functions.GetPlayer(src)
	if not player then return end

	player.Functions.RemoveMoney('cash', amount)
end)