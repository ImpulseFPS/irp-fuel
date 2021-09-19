# irp-fuel
### Fuel used with QBCore Framework
NoPixel style legacyfuel
### You will have to change exports from LegacyFuel to irp-fuel or more simple way change the folder name from irp-fuel to LegacyFuel
# Dependecis:
- [PolyZoneHelper](https://github.com/bashenga/polyzonehelper)
- [cd_drawtxtui](https://github.com/ImpulseFPS/cd_drawtextui)


[Preview](https://imgur.com/a/zapOyHT)

#Tax:
- Put this in qb-core/server/functions.lua
```lua
QBCore.Functions.GlobalTax = function(value)
	local tax = (value / 100 * QBConfig.Server.GlobalTax)
	return tax
end
```
- Put this in qb-core/Config.lua
```lua
QBConfig.Server.GlobalTax = 15.0
```

#How does it work:
- So basicly the progbar time is calculated by the gas in the vehicle
- if the gas is lower it will take more time to fill up the vehicle
- if the gas is higer it will take less time to fill up the vehicle
- if vehicle has more then 95% fule the player wont be abel to fuel up the vehicle (why? because the price will be 0 so yea)
- price is also calculated with the fuel in the vehicle, price to fuel up the vehicle, and price multiplier witch is in the config
