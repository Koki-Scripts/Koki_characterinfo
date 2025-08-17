ESX = exports["es_extended"]:getSharedObject()

-- Event to get player's licenses
RegisterNetEvent('koki_characterinfo:getLicenses')
AddEventHandler('koki_characterinfo:getLicenses', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchAll('SELECT * FROM user_licenses WHERE owner = ?', {xPlayer.identifier}, function(licenses)
        local licenseData = {}
        if licenses then
            for i=1, #licenses do
                local license = licenses[i]
                licenseData[license.type] = true
            end
        end
        TriggerClientEvent('koki_info:receiveLicenses', source, licenseData)
    end)
end)