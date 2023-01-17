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

--TODO: NEZABEZPEČENÝ EVENTY!!!!

RegisterNetEvent('jobs:handcuff')
AddEventHandler('jobs:handcuff', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	-- if xPlayer.job.name == 'police' then
		TriggerClientEvent('esx_policejob:handcuff', target) 
	-- else
	-- 	print(('esx_policejob: %s attempted to handcuff a player (not job)!'):format(xPlayer.identifier))
	-- end
end)

RegisterNetEvent('jobs:drag')
AddEventHandler('jobs:drag', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	-- if xPlayer.job.name == 'police' then
		TriggerClientEvent('jobs:drag', target, source) 
	-- else
	-- 	print(('esx_policejob: %s attempted to drag (not cop)!'):format(xPlayer.identifier))
	-- end
end)

RegisterNetEvent('jobs:putInVehicle')
AddEventHandler('jobs:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	-- if xPlayer.job.name == 'police' then
		TriggerClientEvent('jobs:putInVehicle', target)
	-- else
	-- 	print(('esx_policejob: %s attempted to put in vehicle (not cop)!'):format(xPlayer.identifier))
	-- end
end)

RegisterNetEvent('jobs:OutVehicle')
AddEventHandler('jobs:OutVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	-- if xPlayer.job.name == 'police' then
		TriggerClientEvent('jobs:OutVehicle', target)
	-- else
	-- 	print(('esx_policejob: %s attempted to drag out from vehicle (not cop)!'):format(xPlayer.identifier))
	-- end
end)