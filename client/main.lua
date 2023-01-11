RegisterNetEvent('esx:playerLoaded') 
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:playerLogout') 
AddEventHandler('esx:playerLogout', function(xPlayer)
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterCommand("jobmenu", function()
	OpenJobsActionsMenu()
end)

function OpenJobsActionsMenu()
	ESX.UI.Menu.CloseAll()
		local elements = {}
		if Config.jobs[ESX.PlayerData.job.name].citizenActions then 
			table.insert(elements, {label = _U('citizen_interaction'), value = 'citizen_interaction'})
		end

		if Config.jobs[ESX.PlayerData.job.name].vehicleActions then 
			table.insert(elements, {label = _U('vehicle_interaction'), value = 'vehicle_interaction'})
		end

		if Config.jobs[ESX.PlayerData.job.name].objectActions then 
			table.insert(elements, {label = _U('object_spawner'), value = 'object_spawner'})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'police_actions', {
			title    = ESX.PlayerData.job.name.. " menu",
			align    = 'top-right',
			elements = elements
			

			}, function(data, menu)
			if data.current.value == 'citizen_interaction' then
				
				local elements = {}

				if Config.jobs[ESX.PlayerData.job.name].citizenActions.idCard then 
					table.insert(elements, {label = _U('id_card'), value = 'identity_card'})
				end

				if Config.jobs[ESX.PlayerData.job.name].citizenActions.search then 
					table.insert(elements, {label = _U('search'), value = 'search'})
				end

				if Config.jobs[ESX.PlayerData.job.name].citizenActions.handcuff then 
					table.insert(elements, {label = _U('handcuff'), value = 'handcuff'})
				end

				if Config.jobs[ESX.PlayerData.job.name].citizenActions.drag then 
					table.insert(elements, {label = _U('drag'), value = 'drag'})
				end

				if Config.jobs[ESX.PlayerData.job.name].citizenActions.putInVehicle then 
					table.insert(elements, {label = _U('put_in_vehicle'), value = 'put_in_vehicle'})
				end

				if Config.jobs[ESX.PlayerData.job.name].citizenActions.outTheVehicle then 
					table.insert(elements, {label = _U('out_the_vehicle'), value = 'out_the_vehicle'})
				end

				if Config.jobs[ESX.PlayerData.job.name].citizenActions.bills then 
					table.insert(elements, {label = _U('bills'), value = 'bills'})
				end

				if Config.jobs[ESX.PlayerData.job.name].citizenActions.unpaidBills then 
					table.insert(elements, {label = _U('unpaid_bills'), value = 'unpaid_bills'})
				end

				if Config.EnableLicenses and Config.jobs[ESX.PlayerData.job.name].citizenActions.licenses  then
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

						if action == 'identity_card' then
							OpenIdentityCardMenu(closestPlayer)
						elseif action == 'search' then
							OpenBodySearchMenu(closestPlayer)
						elseif action == 'handcuff' then
							TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(closestPlayer))
						elseif action == 'drag' then
							TriggerServerEvent('esx_policejob:drag', GetPlayerServerId(closestPlayer))
						elseif action == 'put_in_vehicle' then
							TriggerServerEvent('esx_policejob:putInVehicle', GetPlayerServerId(closestPlayer))
						elseif action == 'out_the_vehicle' then
							TriggerServerEvent('esx_policejob:OutVehicle', GetPlayerServerId(closestPlayer))
						elseif action == 'fine' then
							OpenFineMenu(closestPlayer)
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

				if DoesEntityExist(vehicle) then
					if Config.jobs[ESX.PlayerData.job.name].vehicleActions.vehicleInfo then
						table.insert(elements, {label = _U('vehicle_info'), value = 'vehicle_infos'})
					end

					if Config.jobs[ESX.PlayerData.job.name].vehicleActions.pickLock then
						table.insert(elements, {label = _U('pick_lock'), value = 'hijack_vehicle'})
					end

					if Config.jobs[ESX.PlayerData.job.name].vehicleActions.impound then
						table.insert(elements, {label = _U('impound'), value = 'impound'})
					end
				end

				table.insert(elements, {label = _U('search_database'), value = 'search_database'})

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
							-- is the script busy?
							if currentTask.busy then
								return
							end

							ESX.ShowHelpNotification(_U('impound_prompt'))
							TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)

							currentTask.busy = true
							currentTask.task = ESX.SetTimeout(10000, function()
								ClearPedTasks(playerPed)
								ImpoundVehicle(vehicle)
								Citizen.Wait(100) -- sleep the entire script to let stuff sink back to reality
							end)

							-- keep track of that vehicle!
							Citizen.CreateThread(function()
								while currentTask.busy do
									Citizen.Wait(1000)

									vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
									if not DoesEntityExist(vehicle) and currentTask.busy then
										ESX.ShowNotification(_U('impound_canceled_moved'))
										ESX.ClearTimeout(currentTask.task)
										ClearPedTasks(playerPed)
										currentTask.busy = false
										break
									end
								end
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
