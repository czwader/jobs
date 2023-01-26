fx_version 'adamant'

game 'gta5'

description 'Jobs'

shared_script '@es_extended/imports.lua'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/cs.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/cs.lua',
	'config.lua',
	'client/main.lua'
}
