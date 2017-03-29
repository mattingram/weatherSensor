# WeatherSensor

## BME280 weather sensor hooked up to an ESP8266 (AdaFruit Feather HUZZAH) with wifi running NodeMCU/Lua that sends JSON weather data with current time to a web service

> Note: GPIO pins and LEDs are mapped from PCB/Arduino to NodeMCU/Lua

## Pre-requisites

1. Python
2. [NodeMCU Firmware](https://nodemcu-build.com/)
  *  with the following modules: bme280, cjson, dht, file, gpio, http, net, node, rtctime, sntp, tmr, uart, wifi, tls
3. [esptool.py](https://github.com/espressif/esptool) for loading Firmware
  * esptool.py --port /dev/tty.SLAB_USBtoUART write_flash -fm dio 0x00000 nodemcu-master-14-modules-2017-03-27-01-59-25-float.bin

## How to load files

1. Install [luatool.py](https://github.com/4refr0nt/luatool)
2. Copy files to ESP8266
  * luatool.py --port /dev/cu.SLAB_USBtoUART -f settings.lua
  * luatool.py --port /dev/cu.SLAB_USBtoUART -f init.lua
  * luatool.py --port /dev/cu.SLAB_USBtoUART -f main.lua

## How to connect using terminal:

  * screen /dev/cu.SLAB_USBtoUART"
