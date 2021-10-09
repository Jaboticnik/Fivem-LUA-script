fx_version 'adamant'

game 'gta5'

description 'Advanced Premium Mafia Job by VOLTA MEDIA'

version '1.0'

server_scripts {
  '@es_extended/locale.lua',
  '@mysql-async/lib/MySQL.lua',
  'locales/de.lua',
  'locales/en.lua',
  'locales/sl.lua',
  'config.lua',
  'server/main.lua'
}

client_scripts {
  '@es_extended/locale.lua',
  'locales/de.lua',
  'locales/en.lua',
  'locales/sl.lua',
  'config.lua',
  'client/main.lua'
}
