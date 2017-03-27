# WeatherSensor

## BME280 weather sensor hooked up to an ESP8266 (AdaFruit Feather HUZZAH) with wifi running NodeMCU/Lua

> Note: GPIO pins and LEDs are mapped from PCB/Arduino to NodeMCU/Lua

## How to Run

1. connect via USB, then terminal in using "screen /dev/cu.SLAB_USBtoUART"
2. dofile("main.lua")
3. Main() -- connect to wifi, synchronize system time and start printing weather every second
4. quit() -- stop all timer jobs
