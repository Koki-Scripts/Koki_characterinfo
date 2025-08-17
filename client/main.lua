ESX = exports["es_extended"]:getSharedObject()

local vehicleData = {}
local licenseData = {}
local personalInvoices = {}
local companyInvoices = {}
local hasJob = false

-- Command to open the menu
RegisterCommand('osoba', function()
    OpenCharacterMenu()
end)

-- Key binding for F4
RegisterKeyMapping('osoba', 'Otevřít menu osoby', 'keyboard', 'F4')

-- Event to receive vehicle data
RegisterNetEvent('koki_characterinfo:receiveVehicles')
AddEventHandler('koki_characterinfo:receiveVehicles', function(vehicles)
    vehicleData = vehicles
end)

-- Event to receive license data
RegisterNetEvent('koki_characterinfo:receiveLicenses')
AddEventHandler('koki_characterinfo:receiveLicenses', function(licenses)
    licenseData = licenses
end)

-- Event to receive invoice data
RegisterNetEvent('koki_characterinfo:receiveInvoices')
AddEventHandler('koki_characterinfo:receiveInvoices', function(personal, company, hasJobStatus)
    personalInvoices = personal
    companyInvoices = company
    hasJob = hasJobStatus
end)

-- Function to get color name from color ID
local function GetColorName(colorId)
    local colors = {
        [0] = "Černá",
        [1] = "Bílá",
        [2] = "Šedá",
        [3] = "Červená",
        [4] = "Oranžová",
        [5] = "Žlutá",
        [6] = "Zelená",
        [7] = "Modrá",
        [8] = "Fialová",
        [9] = "Růžová",
        [10] = "Hnědá",
        [11] = "Stříbrná",
        [12] = "Zlatá"
    }
    return colors[colorId] or "Neznámá"
end

-- Function to get license status emoji
local function GetLicenseStatus(type)
    if licenseData[type] then
        return '🟢'
    else
        return '🔴'
    end
end

-- Function to format invoice date
local function FormatDate(timestamp)
    local date = os.date('%d.%m.%Y %H:%M', timestamp)
    return date
end

-- Function to open the character menu
function OpenCharacterMenu()
    -- Request vehicle and license data
    TriggerServerEvent('koki_characterinfo:getVehicles')
    TriggerServerEvent('koki_characterinfo:getLicenses')
    TriggerServerEvent('koki_characterinfo:getInvoices')
    
    local elements = {
        {
            title = 'Osoba',
            description = 'Informace o vaší postavě',
            icon = 'user',
            onSelect = function()
                local playerData = ESX.GetPlayerData()
                local elements = {
                    {
                        title = 'Jméno příjmení:',
                        description = playerData.firstName .. ' ' .. playerData.lastName,
                        icon = 'id-card'
                    },
                    {
                        title = 'Datum narození:',
                        description = playerData.dateofbirth or 'Není nastaveno',
                        icon = 'calendar'
                    },
                    {
                        title = 'Aktuální práce:',
                        description = playerData.job.label,
                        icon = 'briefcase'
                    }
                }
                
                lib.registerContext({
                    id = 'character_info_menu',
                    title = 'Informace o osobě',
                    menu = 'main_menu',
                    options = elements
                })
                
                lib.showContext('character_info_menu')
            end
        },
        {
            title = 'Vozidla',
            description = 'Seznam vašich vozidel',
            icon = 'car',
            onSelect = function()
                local vehicleElements = {}
                
                if vehicleData and #vehicleData > 0 then
                    for _, vehicle in ipairs(vehicleData) do
                        table.insert(vehicleElements, {
                            title = vehicle.plate,
                            description = vehicle.name or "Neznámé vozidlo",
                            icon = 'car-side'
                        })
                    end
                else
                    table.insert(vehicleElements, {
                        title = 'Momentálne nedostupné',
                        icon = 'car'
                    })
                end
                
                lib.registerContext({
                    id = 'vehicles_menu',
                    title = 'Vaše vozidla',
                    menu = 'main_menu',
                    options = vehicleElements
                })
                
                lib.showContext('vehicles_menu')
            end
        },
        {
            title = 'Licence',
            description = 'Seznam vašich licencí',
            icon = 'id-card',
            onSelect = function()
                local licenseElements = {
                    {
                        title = GetLicenseStatus('weapon') .. ' Zbrojní průkaz',
                        description = 'Oprávnění k nošení zbraně',
                        icon = 'gun'
                    },
                    {
                        title = GetLicenseStatus('drive') .. ' Řidičský průkaz',
                        description = 'Oprávnění k řízení vozidel',
                        icon = 'car'
                    },
                    {
                        title = GetLicenseStatus('pilot') .. ' Pilotní průkaz',
                        description = 'Oprávnění k řízení letadel',
                        icon = 'plane'
                    },
                    {
                        title = GetLicenseStatus('boat') .. ' Námořní průkaz',
                        description = 'Oprávnění k řízení lodí',
                        icon = 'ship'
                    }
                }
                
                lib.registerContext({
                    id = 'licenses_menu',
                    title = 'Vaše licence',
                    menu = 'main_menu',
                    options = licenseElements
                })
                
                lib.showContext('licenses_menu')
            end
        },
        {
            title = 'Faktury',
            description = 'Seznam vašich faktur',
            icon = 'file-invoice',
            onSelect = function()
                local invoiceElements = {
                    {
                        title = 'Osobní faktury',
                        description = 'Vaše osobní faktury',
                        icon = 'user',
                        onSelect = function()
                            TriggerEvent("okokBilling:ToggleMyInvoices")
                        end
                    },
                    {
                        title = 'Vytvořit fakturu',
                        description = 'Vytvořit novou fakturu',
                        icon = 'file-invoice-dollar',
                        onSelect = function()
                            local playerData = ESX.GetPlayerData()
                            if playerData.job.name ~= 'unemployed' then
                                TriggerEvent("okokBilling:ToggleCreateInvoice")
                            else
                                lib.notify({
                                    title = 'Faktury',
                                    description = 'Nemůžete vytvořit fakturu bez zaměstnání',
                                    type = 'error'
                                })
                            end
                        end
                    }
                }
                
                lib.registerContext({
                    id = 'invoices_menu',
                    title = 'Faktury',
                    menu = 'main_menu',
                    options = invoiceElements
                })
                
                lib.showContext('invoices_menu')
            end
        }
    }
    
    lib.registerContext({
        id = 'main_menu',
        title = 'Menu osoby',
        options = elements
    })
    
    lib.showContext('main_menu')
end 