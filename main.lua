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

function Time(tm)
  return string.format("%02d:%02d:%02d", tm["hour"], tm["min"], tm["sec"])
end

function DateTime(tm)
  return string.format("%04d-%02d-%02dT%02d:%02d:%02dZ", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
end

function TimeAndWeatherToString(time, tf, h, p)
  return string.format("%s T=%.2f H=%.2f P=%.2f", Time(time), tf, h, p)
end

function TimeAndWeatherToJSON(time, tf, h, p)
  results = {}
  results["time"] = DateTime(time)
  results["temp"] = tf
  results["humid"] = h
  results["press"] = p
  return cjson.encode(results)
end

function CelciusToF(celcius)
  return celcius*(9/5)+32
end

--returns Temp (F), humidity, pressure
function GetWeather()
  tc, p, h = bme280.read()
  tc = tc / 100
  p = p / 1000
  h = h / 1000
  tf = CelciusToF(tc)
  return tf, h, p
end

function SendToCloud(time, tf, h, p)
  if (wifi.sta.getip() ~= nil) then
    weatherData = TimeAndWeatherToJSON(time, tf, h, p)
    print(weatherData)
    http.post(URL,
      'Content-Type: application/json\r\nContent-Length: ' .. string.len(weatherData),
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

function StartWeatherTimer()
  sensorTimer=tmr.create()
  tmr.alarm(sensorTimer, READING_INTERVAL_IN_SECONDS*1000, 1, function()
    SetLED(BLUELED, ON)
    tf, h, p = GetWeather()
    time = Now()
    SendToCloud(time, tf, h, p)
    print(TimeAndWeatherToString(time, tf, h, p))
    SetLED(BLUELED, OFF)
  end)
end

function main()
  -- synchronize time and start reading sensor
  sntp.sync(nil, StartWeatherTimer, StartWeatherTimer)
end

function quit()
  if (sensorTimer ~= nil and tmr.state(sensorTimer) ~= nil) then
    tmr.stop(sensorTimer)
  end
end

-- run it!
main()
