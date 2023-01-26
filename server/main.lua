ESX.RegisterServerCallback('jobs:getOtherPlayerData', function(source, cb, target, notify)
	local xPlayer = ESX.GetPlayerFromId(target)
   
	if notify then
		xPlayer.showNotification(_U('being_searched'))
	end

	if xPlayer then
		local data = {
			name = xPlayer.getName(),
			job = xPlayer.job.label,
			grade = xPlayer.job.grade_label,
			accounts = xPlayer.getAccounts(),

		}

		if Config.EnableESXIdentity then
			data.dob = xPlayer.get('dateofbirth')
			data.height = xPlayer.get('height')

			if xPlayer.get('sex') == 'm' then data.sex = 'male' else data.sex = 'female' end
		end

		TriggerEvent('esx_status:getStatus', target, 'drunk', function(status)
			if status then
				data.drunk = ESX.Math.Round(status.percent)
			end
		end)
		if Config.EnableLicenses then
			TriggerEvent('esx_license:getLicenses', target, function(licenses)
				data.licenses = licenses
				cb(data)

			end)
		else
			cb(data)

		end
	end
end)

ESX.RegisterServerCallback('jobs:getVehicleInfos', function(source, cb, plate)
	local retrivedInfo = {
		plate = plate
	}
	if Config.EnableESXIdentity then
		MySQL.single('SELECT users.firstname, users.lastname FROM owned_vehicles JOIN users ON owned_vehicles.owner = users.identifier WHERE plate = ?', {plate},
		function(result)
			if result then
				retrivedInfo.owner = ('%s %s'):format(result.firstname, result.lastname)
			end
			cb(retrivedInfo)
		end)
	else
		MySQL.scalar('SELECT owner FROM owned_vehicles WHERE plate = ?', {plate},
		function(owner)
			if owner then
				local xPlayer = ESX.GetPlayerFromIdentifier(owner)
				if xPlayer then
					retrivedInfo.owner = xPlayer.getName()
				end
			end
			cb(retrivedInfo)
		end)
	end
end)

RegisterNetEvent('jobs:handcuff')
AddEventHandler('jobs:handcuff', function(target)
	local src = source
	if twoPlayersDistance(src, target)  then 
		TriggerClientEvent('jobs:handcuff', target) 
	end
end)

RegisterNetEvent('jobs:drag')
AddEventHandler('jobs:drag', function(target)
	local src = source
	if twoPlayersDistance(src, target)  then 
		TriggerClientEvent('jobs:drag', target, source) 
	end
end)

RegisterNetEvent('jobs:putInVehicle')
AddEventHandler('jobs:putInVehicle', function(target)
	local src = source
	if twoPlayersDistance(src, target)  then 
		TriggerClientEvent('jobs:putInVehicle', target)
	end
end)

RegisterNetEvent('jobs:OutVehicle')
AddEventHandler('jobs:OutVehicle', function(target)
	local src = source
	if twoPlayersDistance(src, target)  then 
		TriggerClientEvent('jobs:OutVehicle', target)
	end
end)

function twoPlayersDistance(ped, target)
    local ped = GetPlayerPed(ped) 
	local targetPed = GetPlayerPed(target)
    local coordsPed = GetEntityCoords(ped) 
	local coordsTarget = GetEntityCoords(targetPed)
	local distance = #(coordsPed - coordsTarget) 
	if distance < 10 then
		return true 
	end
    return false
end