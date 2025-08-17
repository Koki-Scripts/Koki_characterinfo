fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Koki-Scripts'
description 'FiveM script, který po stisknutí nastaveného bindu zobrazí hráči informace o jeho postavě.'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
} 