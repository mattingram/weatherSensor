-- Require modules
bme280=require("bme280")
dht=require("dht")

-- Init hardware
bme280.init(SDA,SCL)

function GetDateTime()
  tm = rtctime.epoch2cal(rtctime.get())
  return string.format("%04d-%02d-%02dT%02d:%02d:%02dZ", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
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

function GetTimeAndWeatherString()
  tf, h, p = GetWeather()
  return string.format("%s T=%.2f H=%.2f P=%.2f", GetDateTime(), tf, h, p)
end

function GetTimeAndWeatherJSON()
  tf, h, p = GetWeather()
  results = {}
  results["time"] = GetDateTime()
  results["temp"] = tf
  results["humid"] = h
  results["press"] = p
  return cjson.encode(results)
end

function SendToCloud(weatherData)
  http.post(URL,
    'Content-Type: application/json\r\nContent-Length: ' .. string.len(weatherData),
    weatherData,
    function(code, data)
      if (code < 0) then
        print("HTTP request failed")
      else
        print(code, data)
      end
    end)
end

function StartWeatherTimer()
  sensorTimer=tmr.create()
  tmr.alarm(sensorTimer, READING_INTERVAL_IN_SECONDS*1000, 1, function()
    weatherData = GetTimeAndWeatherJSON()
    print(weatherData)
    SendToCloud(weatherData)
    BlinkLED(BLUELED)
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
