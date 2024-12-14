local QBCore = exports['qb-core']:GetCoreObject()

local carList = {
    "adder",   -- Car 1
    "zentorno", -- Car 2
    "t20"      -- Car 3
}

local currentIndex = 1
local whitelistEnabled = true -- Toggle this to enable/disable whitelist

-- Function to check if a player is whitelisted
local function isWhitelisted(callback)
    if not whitelistEnabled then
        callback(true) -- If whitelist is disabled, allow everyone
        return
    end

    -- Request whitelist status from the server
    TriggerServerEvent('shapeshifting_car:checkWhitelist', function(isAllowed)
        callback(isAllowed)
    end)
end

-- Function to spawn a new vehicle
local function spawnCar(carModel)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    -- Request model
    RequestModel(carModel)
    while not HasModelLoaded(carModel) do
        Wait(0)
    end

    -- Delete current vehicle
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)
    if currentVehicle ~= 0 then
        DeleteEntity(currentVehicle)
    end

    -- Create new vehicle
    local vehicle = CreateVehicle(carModel, coords.x, coords.y, coords.z, heading, true, false)
    if DoesEntityExist(vehicle) then
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        print("[DEBUG] Vehicle spawned successfully.")

        -- Force the engine to stay on
        Citizen.Wait(100) -- Small delay to ensure the vehicle is fully initialized
        SetVehicleEngineOn(vehicle, true, true, false) -- Set engine on
        SetVehicleUndriveable(vehicle, false) -- Ensure vehicle can be driven
        Citizen.Wait(100)
        if not GetIsVehicleEngineRunning(vehicle) then
            print("[DEBUG] Engine was not running. Forcing engine on again.")
            SetVehicleEngineOn(vehicle, true, true, false)
        end

        -- Turn off the radio
        SetVehicleRadioEnabled(vehicle, false)
        print("[DEBUG] Radio turned off.")

        -- Set as mission entity
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetEntityAsMissionEntity(vehicle, true, true)

        -- Grant keys to the vehicle
        TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(vehicle))
        print("[DEBUG] Keys granted for the vehicle.")
    else
        print("[DEBUG] Error: Vehicle could not be created.")
    end

    -- Clean up
    SetModelAsNoLongerNeeded(carModel)
end

-- Detect F5 key press
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 166) then -- F5 key
            isWhitelisted(function(isAllowed)
                if not isAllowed then
                    QBCore.Functions.Notify("You are not whitelisted to use this feature!", "error")
                    return
                end

                currentIndex = currentIndex + 1
                if currentIndex > #carList then
                    currentIndex = 1
                end
                print("[DEBUG] Attempting to spawn: " .. carList[currentIndex])
                spawnCar(carList[currentIndex])
            end)
        end
    end
end)
