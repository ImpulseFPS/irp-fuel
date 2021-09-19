fx_version 'bodacious'
game 'gta5'

author 'ImpulseFPS'
description 'Fuel system used with QBCore Framework'
version '1.0'


shared_script '@qb-core/import.lua'

client_scripts {
	'config.lua',
	'functions/functions_client.lua',
	'source/fuel_client.lua'
}

server_scripts {
	'config.lua',
	'source/fuel_server.lua'
}

exports {
	'GetFuel',
	'SetFuel'
}
