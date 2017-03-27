#WeatherSensor
##BME280 weather sensor hooked up to an ESP8266 (AdaFruit Feather HUZZAH) with wifi running NodeMCU/Lua
GPIO pins and LEDs are mapped from PCB/Arduino to NodeMCU/Lua

##How to Run
--connect via USB, then terminal in using "screen /dev/cu.SLAB_USBtoUART"
--once at a prompt...
dofile("main.lua")
Main() -- connect to wifi, synchronize system time and start printing weather every second
quit() -- stop all timer jobs

--to kill screen press Ctrl+A k
