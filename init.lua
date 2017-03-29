dofile('settings.lua')

function SetLED(led, state)
  gpio.write(led, state)
end

function BlinkLED(led)
  SetLED(led, ON)
  SetLED(led, OFF)
end

function startup()
  SetLED(BLUELED, OFF)
  if file.open("init.lua") == nil then
      print("init.lua deleted or renamed")
  else
      print("Running")
      file.close("init.lua")
      dofile("main.lua")
  end
end

gpio.mode(REDLED, gpio.OUTPUT)
gpio.mode(BLUELED, gpio.OUTPUT)

print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.sta.config(SSID, PASSWORD)
tmr.create():alarm(1000, tmr.ALARM_AUTO, function(cb_timer)
  if wifi.sta.getip() == nil then
    print("Waiting for IP address...")
    BlinkLED(REDLED)
  else
    cb_timer:unregister()
    SetLED(BLUELED, ON)
    print("WiFi connection established, IP address: " .. wifi.sta.getip())
    print("You have 3 seconds to abort")
    print("Waiting...")
    tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
  end
end)
