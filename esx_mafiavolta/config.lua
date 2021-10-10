Config                            = {}
Config.DrawDistance               = 50.0
Config.MarkerType                 = 21
Config.MarkerSize                 = { x = 1.5, y = 1.5, z = 1.0 }
Config.MarkerColor                = { r = 51, g = 99, b = 255 }
Config.EnablePlayerManagement     = true
Config.EnableArmoryManagement     = true
Config.EnableESXIdentity          = false -- only turn this on if you are using esx_identity
Config.EnableSocietyOwnedVehicles = false
Config.MaxInService               = -1
Config.Locale                     = 'en'
Config.Plate                      = ""
Config.PrimaryRGB = {
      0, 0, 0
    }
Config.SecondaryRGB = {
      0, 0, 0
}
Config.mafiaStations = {



  mafia = {

    

    AuthorizedWeapons = {
   -- { name = 'WEAPON_COMBATPISTOL',     price = 14000 },
   -- { name = 'WEAPON_ASSAULTSMG',       price = 400000 },
   -- { name = 'WEAPON_ASSAULTRIFLE',     price = 600000 },
   -- { name = 'WEAPON_CARBINERIFLE',     price = 600000 },
   --  { name = 'WEAPON_ADVANCEDRIFLE',    price = 500000 },
    --  { name = 'WEAPON_SNIPERRIFLE',      price = 1500000 },
     -- { name = 'WEAPON_APPISTOL',         price = 20000 },
    },
    ---- IF YOU CHANGE VEHICLES, YOU ALSO HAVE TO CHANGE AUTHORIZED VEHICLES FOR VEHICLE DELETER. SEARCH FOR: police_vehicles  in main.lua and replace vehicle spawn codes with new ones.
	AuthorizedVehicles = {
	  { name = 'hexer',          label = 'Motorbike' },
	  { name = 'kamacho',     label = 'Kamacho off road' },
	  { name = 'emerus',         label = 'Emerus Super car' },  
	  },

    Armories = {
      { x = 986.6, y = -92.78, z = 74.85},
    },

    Vehicles = {
      {
        Spawner    = { x = 973.76, y = -113.32, z = 74.35 },
        SpawnPoint = { x = 970.75, y = -114.33, z = 74.35 },
        Heading    = 213.29,
      },
      {
        Spawner    = { x = 2124.75, y = 4785.71, z = 40.97 },
        SpawnPoint = { x = 2109.96, y = 4769.52, z = 41.2 },
        Heading    = 21.16,
      }

    },

		AuthorizedWeapons = {                                      -----This is disabled, you can enable it in the client file
				  { name = 'WEAPON_MINISMG',      price = 45000 },
        },

    VehicleDeleters = {
      { x = 966.09, y = -120.78, z = 74.35 },
      { x = 2124.69, y = 4797.12, z = 41.14 },
    },

    BossActions = {
      { x = 977.09, y = -103.89, z = 74.85 },
    },
	
  },
  
}
