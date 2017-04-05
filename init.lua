STARTED = 0

dofile('settings.lua')
if file.open("settings.lua") ~= nil then
    file.close("settings.lua")
end

if (IS_DST) then
  TIMEZONE_OFFSET=TIMEZONE_OFFSET+1
end
rtctime.set(DEFAULT_TIME, 0)

function SetLED(led, state)
  if led ~= nil and (state == 0 or state == 1) then
    gpio.write(led, state)
  end
end

function BlinkLED(led)
  SetLED(led, ON)
  SetLED(led, OFF)
end

function startup()
  if (STARTED == 1) then
    return
  end
  STARTED = 1
  if (wifiTimer ~= nil and tmr.state(wifiTimer) ~= nil) then
    tmr.unregister(wifiTimer)
  end
  if (wifi.sta.getip() == nil) then
    SetLED(REDLED, ON)
    print("No wifi connection")
  else
    SetLED(BLUELED, ON)
    print("WiFi connection established, IP address: " .. wifi.sta.getip())
  end
  print("You have 5 seconds to abort")
  print("Waiting...")
  tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
    SetLED(REDLED, OFF)
    SetLED(BLUELED, OFF)
    if file.open("init.lua") ~= nil then
        file.close("init.lua")
    end
    print("Running")
    dofile("main.lua")
  end)
end

gpio.mode(REDLED, gpio.OUTPUT)
gpio.mode(BLUELED, gpio.OUTPUT)

print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.sta.config(SSID, PASSWORD)
wifiTimer=tmr.create()
tmr.alarm(wifiTimer, 1000, tmr.ALARM_AUTO, function(wifiTimer)
  if wifi.sta.getip() == nil then
    BlinkLED(REDLED)
  else
    startup()
  end
end)

--Set timeout for wifi connection
tmr.create():alarm(WIFI_TIMEOUT_IN_SECONDS*1000, tmr.ALARM_SINGLE, startup)
