-- Require modules
bme280=require("bme280")
dht=require("dht")

-- Init hardware
bme280.init(SDA,SCL)

function Now()
  tm = rtctime.epoch2cal(rtctime.get())
  tm["hour"] = tm["hour"] + TIMEZONE_OFFSET
  return tm
end

function FormatTime(tm)
  return string.format("%02d:%02d:%02d", tm["hour"], tm["min"], tm["sec"])
end

function FormatDateTime(tm)
  return string.format("%04d-%02d-%02dT%02d:%02d:%02dZ", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
end

function FormatTimeAndWeatherToString(time, tf, h, p)
  return string.format("%s T=%.2f H=%.2f P=%.2f", FormatTime(time), tf, h, p)
end

function FormatTimeAndWeatherToJSON(time, tf, h, p)
  results = {}
  results["time"] = FormatDateTime(time)
  results["temp"] = tf
  results["humid"] = h
  results["press"] = p
  return cjson.encode(results)
end

--returns Temp (F), humidity, pressure
function GetWeather()
  tc, p, h = bme280.read()
  tc = tc / 100
  p = p / 1000
  h = h / 1000
  tf = tc*(9/5)+32 -- convert celcius to fahrenheit
  return tf, h, p
end

function SendToCloud(time, tf, h, p)
  if (wifi.sta.status() == wifi.STA_GOTIP) then
    weatherData = FormatTimeAndWeatherToJSON(time, tf, h, p)
    print(weatherData)
    http.post(URL,
      'Content-Type: application/json\r\n',
      weatherData,
      function(code, data)
        if (code < 0) then
          print("HTTP request failed")
          BlinkLED(REDLED)
        else
          print(code, data)
        end
      end)
  end
end

function WriteToFile(output)
  if file.open("data.csv", "a+") then
    file.writeline(output)
    file.close()
  end
end

function StartWeatherTimer()
  if (file.exists("data.csv") == false) then
    WriteToFile(FormatDateTime(Now()))
  end
  if (sensorTimer == nil) then
    sensorTimer=tmr.create()
  end
  if (tmr.state(sensorTimer) == nil) then
    tmr.alarm(sensorTimer, READING_INTERVAL_IN_SECONDS*1000, 1, function()
      if (wifi.sta.status() == wifi.STA_GOTIP) then
        SetLED(BLUELED, ON)
      else
        SetLED(REDLED, ON)
      end

      tf, h, p = GetWeather()
      time = Now()

      SendToCloud(time, tf, h, p)
      WriteToFile(FormatTimeAndWeatherToString(time, tf, h, p))

      SetLED(REDLED, OFF)
      SetLED(BLUELED, OFF)
    end)
  end
end

function quit()
  if (sensorTimer ~= nil and tmr.state(sensorTimer) ~= nil) then
    tmr.unregister(sensorTimer)
  end
end

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
  sntp.sync(nil, print(string.format("SNTP synced to %s", FormatDateTime(Now()))))
end)

-- main start. synchronize time (if we have wifi)
-- start reading weather sensor regardless of whether we have wifi or time sync fails
if (wifi.sta.status() == wifi.STA_GOTIP) then
  sntp.sync(nil, StartWeatherTimer, StartWeatherTimer)
else
  StartWeatherTimer()
end
