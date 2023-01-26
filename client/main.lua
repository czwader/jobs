local handcuffTimer, dragStatus = {}, {}
local isHandcuffed = false
local markers = {}
local rcore = exports.rcore

RegisterNetEvent('esx:playerLoaded') 
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
	createMarker()
end)

RegisterNetEvent('esx:playerLogout') 
AddEventHandler('esx:playerLogout', function(xPlayer)
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
	destroyAllMarkers()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	destroyAllMarkers()
	if ESX.PlayerData.job.grade_name == "boss" then
		Wait(1000)
		createMarker()
	end
end)

RegisterCommand("jobmenu", function()
	OpenJobsActionsMenu()
end)

function createMarker()
    for k,v in pairs(Config.bossMenu) do 
		if k == ESX.PlayerData.job.name and ESX.PlayerData.job.grade_name == "boss" then
			if markers[k] ~= nil then
				pcall(markers[k].destroy)
			end
			local marker = rcore:createMarker(GetCurrentResourceName())
			marker.render()
			marker.setPosition(v.marker.pos)
			marker.setType(v.marker.type)
			marker.setColor(v.marker.color)
			marker.setScale(v.marker.scale)
			marker.setRotation(v.marker.rotation)
			marker.setRenderDistance(v.marker.renderDist)
			marker.setKeys({38,})
			marker.setInRadius(v.marker.inRadius)
			marker.on('enter',function()
				ESX.ShowHelpNotification(v.marker.text)
			end)

			marker.on('key', function(pressed)
				if pressed == 38 then
					TriggerEvent('esx_society:openBossMenu', ESX.PlayerData.job.name, function(data, menu)
						ESX.UI.Menu.CloseAll()	
					end, { 
						wash = v.allowedActions.canWash,
						deposit = v.allowedActions.deposit,
						grades = v.allowedActions.grades,
						withdraw = v.allowedActions.withdraw,
						employees = v.allowedActions.employees,
					})
				end
			end)

			markers[k] = marker
		end
    end
end

function destroyAllMarkers()
    for k, marker in pairs(markers) do
        marker.destroy()
    end
end

function OpenJobsActionsMenu()
	for k,v in pairs(Config.jobs) do 
		
		if v.allowJobs[ESX.PlayerData.job.name] then
			ESX.UI.Menu.CloseAll()
			local elements = {}

			if v.citizenActions then 
				table.insert(elements, {label = _U('citizen_interaction'), value = 'citizen_interaction'})
			end

			if v.vehicleActions then 
				table.insert(elements, {label = _U('vehicle_interaction'), value = 'vehicle_interaction'})
			end

			if v.objectActions then 
				table.insert(elements, {label = _U('object_spawner'), value = 'object_spawner'})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'police_actions', {
				title    = ESX.PlayerData.job.name.. " menu",
				align    = 'top-right',
				elements = elements
				}, function(data, menu)
				if data.current.value == 'citizen_interaction' then
					
					local elements = {}

					if v.citizenActions.idCard then 
						table.insert(elements, {label = _U('id_card'), value = 'identity_card'})
					end

					if v.citizenActions.search then 
						table.insert(elements, {label = _U('search'), value = 'search'})
					end

					if v.citizenActions.handcuff then 
						table.insert(elements, {label = _U('handcuff'), value = 'handcuff'})
					end

					if v.citizenActions.drag then 
						table.insert(elements, {label = _U('drag'), value = 'drag'})
					end

					if v.citizenActions.putInVehicle then 
						table.insert(elements, {label = _U('put_in_vehicle'), value = 'put_in_vehicle'})
					end

					if v.citizenActions.outTheVehicle then 
						table.insert(elements, {label = _U('out_the_vehicle'), value = 'out_the_vehicle'})
					end

					if v.citizenActions.bills then 
						table.insert(elements, {label = _U('bills'), value = 'bills'})
					end

					if v.citizenActions.unpaidBills then 
						table.insert(elements, {label = _U('unpaid_bills'), value = 'unpaid_bills'})
					end

					if Config.EnableLicenses and v.citizenActions.licenses  then
						table.insert(elements, {label = _U('license_check'), value = 'license'})
					end

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
						title    = _U('citizen_interaction'),
						align    = 'top-right',
						elements = elements
					}, function(data2, menu2)
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer ~= -1 and closestDistance <= 3.0 then
							local action = data2.current.value
							local closestPlayerSwId = GetPlayerServerId(closestPlayer)
							if action == 'identity_card' then
								
								OpenIdentityCardMenu(closestPlayer)
							elseif action == 'search' then
								OpenBodySearchMenu(closestPlayer)
							elseif action == 'handcuff' then
								TriggerServerEvent('jobs:handcuff', closestPlayerSwId)
							elseif action == 'drag' then
								TriggerServerEvent('jobs:drag', closestPlayerSwId)
							elseif action == 'put_in_vehicle' then
								TriggerServerEvent('jobs:putInVehicle', closestPlayerSwId)
							elseif action == 'out_the_vehicle' then
								TriggerServerEvent('jobs:OutVehicle', closestPlayerSwId)
							elseif action == 'bills' then
								OpenBillingMenu(closestPlayer)
							elseif action == 'license' then
								ShowPlayerLicense(closestPlayer)
							elseif action == 'unpaid_bills' then
								OpenUnpaidBillsMenu(closestPlayer)
							end
						else
							ESX.ShowNotification(_U('no_players_nearby'))
						end
					end, function(data2, menu2)
						menu2.close()
					end)
				elseif data.current.value == 'vehicle_interaction' then
					local elements  = {}
					local playerPed = PlayerPedId()
					local vehicle = ESX.Game.GetVehicleInDirection()

						if v.vehicleActions.vehicleInfo then
							table.insert(elements, {label = _U('vehicle_info'), value = 'vehicle_infos'})
						end

						if v.vehicleActions.pickLock then
							table.insert(elements, {label = _U('pick_lock'), value = 'hijack_vehicle'})
						end

						if v.vehicleActions.impound then
							table.insert(elements, {label = _U('impound'), value = 'impound'})
						end

						if v.vehicleActions.repair then
							table.insert(elements, {label = _U('repair'), value = 'fix_vehicle'})
						end

						if v.vehicleActions.clean then
							table.insert(elements, {label = _U('clean'), value = 'clean_vehicle'})
						end
						
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_interaction', {
						title    = _U('vehicle_interaction'),
						align    = 'top-right',
						elements = elements
					}, function(data2, menu2)
						local coords  = GetEntityCoords(playerPed)
						vehicle = ESX.Game.GetVehicleInDirection()
						action  = data2.current.value

						if action == 'search_database' then
							LookupVehicle()
						elseif DoesEntityExist(vehicle) then
							if action == 'vehicle_infos' then
								local vehicleData = ESX.Game.GetVehicleProperties(vehicle)
								OpenVehicleInfosMenu(vehicleData)
							elseif action == 'hijack_vehicle' then
								if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
									TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
									Citizen.Wait(20000)
									ClearPedTasksImmediately(playerPed)

									SetVehicleDoorsLocked(vehicle, 1)
									SetVehicleDoorsLockedForAllPlayers(vehicle, false)
									ESX.ShowNotification(_U('vehicle_unlocked'))
								end
							elseif action == 'impound' then
								TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
								CreateThread(function()
									Wait(5000)
									ClearPedTasksImmediately(playerPed)
									ImpoundVehicle(vehicle)
								end)
								
							elseif action == "fix_vehicle" then 

								if IsPedSittingInAnyVehicle(playerPed) then
									ESX.ShowNotification(_U('inside_vehicle'))
									return
								end
					
								
								TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
								CreateThread(function()
									Wait(5000)
				
									SetVehicleFixed(vehicle)
									SetVehicleDeformationFixed(vehicle)
									SetVehicleUndriveable(vehicle, false)
									SetVehicleEngineOn(vehicle, true, true)
									ClearPedTasksImmediately(playerPed)
				
									ESX.ShowNotification(_U('vehicle_repaired'))
								end)
								
							elseif action == "clean_vehicle" then 
								TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
								CreateThread(function()
									Wait(5000)
				
									SetVehicleDirtLevel(vehicle, 0)
									ClearPedTasksImmediately(playerPed)
				
									ESX.ShowNotification(_U('vehicle_cleaned'))
								end)
							end
						else
							ESX.ShowNotification(_U('no_vehicles_nearby'))
						end

					end, function(data2, menu2)
						menu2.close()
					end)
				elseif data.current.value == 'object_spawner' then
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
						title    = _U('traffic_interaction'),
						align    = 'top-right',
						elements = {
							{label = _U('cone'), model = 'prop_roadcone02a'},
							{label = _U('barrier'), model = 'prop_barrier_work05'},
							{label = _U('spikestrips'), model = 'p_ld_stinger_s'},
							{label = _U('box'), model = 'prop_boxpile_07d'},
							{label = _U('cash'), model = 'hei_prop_cash_crate_half_full'}
					}}, function(data2, menu2)
						local playerPed = PlayerPedId()
						local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
						local objectCoords = (coords + forward * 1.0)

						ESX.Game.SpawnObject(data2.current.model, objectCoords, function(obj)
							SetEntityHeading(obj, GetEntityHeading(playerPed))
							PlaceObjectOnGroundProperly(obj)
						end)
					end, function(data2, menu2)
						menu2.close()
					end)
				end
			end, function(data, menu)
				menu.close()
			end)
		end		
	end
end

function OpenIdentityCardMenu(player)
	ESX.TriggerServerCallback('jobs:getOtherPlayerData', function(data)
		
		local elements = {
			{label = _U('name', data.name)},
			{label = _U('job', ('%s - %s'):format(data.job, data.grade))}
		}
		if Config.EnableESXIdentity then
			table.insert(elements, {label = _U('sex', _U(data.sex))})
			table.insert(elements, {label = _U('dob', data.dob)})
			table.insert(elements, {label = _U('height', data.height)})
		end

		if Config.EnableESXOptionalneeds and data.drunk then
			table.insert(elements, {label = _U('bac', data.drunk)})
		end

		if data.licenses then
			table.insert(elements, {label = _U('license_label')})

			for i=1, #data.licenses, 1 do
				table.insert(elements, {label = data.licenses[i].label})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
			title    = _U('citizen_interaction'),
			align    = 'top-right',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

function OpenBodySearchMenu(player)
	if Config.inventory then
		exports['inventory']:OpenTargetInventory() --TODO export pro inv
		return ESX.UI.Menu.CloseAll()
	end

	ESX.TriggerServerCallback('jobs:getOtherPlayerData', function(data)
		local elements = {}

		for i=1, #data.accounts, 1 do
			if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
				table.insert(elements, {
					label    = _U('confiscate_dirty', ESX.Math.Round(data.accounts[i].money)),
					value    = 'black_money',
					itemType = 'item_account',
					amount   = data.accounts[i].money
				})

				break
			end
		end

		table.insert(elements, {label = _U('guns_label')})

		for i=1, #data.weapons, 1 do
			table.insert(elements, {
				label    = _U('confiscate_weapon', ESX.GetWeaponLabel(data.weapons[i].name), data.weapons[i].ammo),
				value    = data.weapons[i].name,
				itemType = 'item_weapon',
				amount   = data.weapons[i].ammo
			})
		end

		table.insert(elements, {label = _U('inventory_label')})

		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				table.insert(elements, {
					label    = _U('confiscate_inv', data.inventory[i].count, data.inventory[i].label),
					value    = data.inventory[i].name,
					itemType = 'item_standard',
					amount   = data.inventory[i].count
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
			title    = _U('search'),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value then
				TriggerServerEvent('jobs:confiscatePlayerItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
				OpenBodySearchMenu(player)
			end
		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

RegisterNetEvent('jobs:handcuff')
AddEventHandler('jobs:handcuff', function()
	isHandcuffed = not isHandcuffed
	local playerPed = PlayerPedId()

	if isHandcuffed then
		RequestAnimDict('mp_arresting')
		while not HasAnimDictLoaded('mp_arresting') do
			Wait(100)
		end

		TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
		RemoveAnimDict('mp_arresting')

		SetEnableHandcuffs(playerPed, true)
		DisablePlayerFiring(playerPed, true)
		SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true) -- unarm player
		SetPedCanPlayGestureAnims(playerPed, false)
		FreezeEntityPosition(playerPed, true)
		DisplayRadar(false)

		if Config.EnableHandcuffTimer then
			if handcuffTimer.active then
				ESX.ClearTimeout(handcuffTimer.task)
			end

			StartHandcuffTimer()
		end
	else
		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)
	end
end)

RegisterNetEvent('jobs:drag')
AddEventHandler('jobs:drag', function(copId)
	if isHandcuffed then
		dragStatus.isDragged = not dragStatus.isDragged
		dragStatus.CopId = copId
	end
end)

CreateThread(function() --TODO Tohle je potřeba optimalizovat
	local wasDragged

	while true do
		local Sleep = 1500

		if isHandcuffed and dragStatus.isDragged then
			Sleep = 50
			local targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.CopId))

			if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
				if not wasDragged then
					AttachEntityToEntity(ESX.PlayerData.ped, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
					wasDragged = true
				else
					Wait(1000)
				end
			else
				wasDragged = false
				dragStatus.isDragged = false
				DetachEntity(ESX.PlayerData.ped, true, false)
			end
		elseif wasDragged then
			wasDragged = false
			DetachEntity(ESX.PlayerData.ped, true, false)
		end
	Wait(Sleep)
	end
end)

RegisterNetEvent('jobs:putInVehicle')
AddEventHandler('jobs:putInVehicle', function()
	if isHandcuffed then
		local playerPed = PlayerPedId()
		local vehicle, distance = ESX.Game.GetClosestVehicle()

		if vehicle and distance < 5 then
			local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

			for i=maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle, i) then
					freeSeat = i
					break
				end
			end

			if freeSeat then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
				dragStatus.isDragged = false
			end
		end
	end
end)

RegisterNetEvent('jobs:OutVehicle')
AddEventHandler('jobs:OutVehicle', function()
	local GetVehiclePedIsIn = GetVehiclePedIsIn
	local IsPedSittingInAnyVehicle = IsPedSittingInAnyVehicle
	local TaskLeaveVehicle = TaskLeaveVehicle
	if IsPedSittingInAnyVehicle(ESX.PlayerData.ped) then
		local vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
		TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 64)
	end
end)

function OpenBillingMenu(closestPlayer)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
		title = _U('invoice_amount')
	}, function(data, menu)
		ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing2', {
			title = _U('billing_label')
			}, function(data2, menu2)
			local amount = tonumber(data.value)
			local billinglabel = data2.value
			if billinglabel == nil then
				ESX.ShowNotification(_U('billing_label_invalid'), "error")
			elseif amount == nil or amount < 0 then
				ESX.ShowNotification(_U('amount_invalid'), "error")
			else
				menu2.close()
				menu.close()
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_'..ESX.PlayerData.job.name, billinglabel, amount)
			end
		end, function(data2, menu2)
			menu2.close()
		end)
	end, function(data, menu)
		menu.close()
	end)
end

function ShowPlayerLicense(player)
	local elements = {}

	ESX.TriggerServerCallback('jobs:getOtherPlayerData', function(playerData)
		if playerData.licenses then
			for i=1, #playerData.licenses, 1 do
				if playerData.licenses[i].label and playerData.licenses[i].type then
					table.insert(elements, {
						label = playerData.licenses[i].label,
						type = playerData.licenses[i].type
					})
				end
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_license', {
			title    = _U('license_revoke'),
			align    = 'top-right',
			elements = elements,
		}, function(data, menu)
			ESX.ShowNotification(_U('licence_you_revoked', data.current.label, playerData.name))
			TriggerServerEvent('jobs:message', GetPlayerServerId(player), _U('license_revoked', data.current.label))

			TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(player), data.current.type)

			ESX.SetTimeout(300, function()
				ShowPlayerLicense(player)
			end)
		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

function OpenUnpaidBillsMenu(player)
	local elements = {}

	ESX.TriggerServerCallback('esx_billing:getTargetBills', function(bills)
		for k,bill in ipairs(bills) do
			table.insert(elements, {
				label = ('%s - <span style="color:red;">%s</span>'):format(bill.label, _U('armory_item', ESX.Math.GroupDigits(bill.amount))),
				billId = bill.id
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing', {
			title    = _U('unpaid_bills'),
			align    = 'top-right',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

function OpenVehicleInfosMenu(vehicleData)
	ESX.TriggerServerCallback('jobs:getVehicleInfos', function(retrivedInfo)
		local elements = {{label = _U('plate', retrivedInfo.plate)}}

		if not retrivedInfo.owner then
			table.insert(elements, {label = _U('owner_unknown')})
		else
			table.insert(elements, {label = _U('owner', retrivedInfo.owner)})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_infos', {
			title    = _U('vehicle_info'),
			align    = 'top-right',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, vehicleData.plate)
end

function ImpoundVehicle(vehicle)
	--local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
	ESX.Game.DeleteVehicle(vehicle)
	ESX.ShowNotification(_U('impound_successful'))
end