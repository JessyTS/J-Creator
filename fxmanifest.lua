fx_version 'cerulean'
games { 'gta5' };
lua54 'on'

client_scripts {
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
}

client_scripts {
    '@es_extended/locale.lua',

    "Client.lua",
}

server_script {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',

    "Server.lua",
}


shared_scripts {
    "Config.lua",

    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
}