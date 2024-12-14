local whitelistEnabled = false -- Toggle this to enable/disable whitelist
local whitelistedPlayers = { -- Add Steam IDs or player identifiers
    "steam:110000112345678", -- Replace with real Steam IDs
    "steam:110000112345679"
}

RegisterNetEvent('shapeshifting_car:checkWhitelist')
AddEventHandler('shapeshifting_car:checkWhitelist', function(callback)
    local src = source
    if not whitelistEnabled then
        callback(true) -- If whitelist is disabled, allow everyone
        return
    end

    local identifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(identifiers) do
        for _, whitelistedId in ipairs(whitelistedPlayers) do
            if id == whitelistedId then
                callback(true) -- Player is whitelisted
                return
            end
        end
    end

    callback(false) -- Player is not whitelisted
end)
