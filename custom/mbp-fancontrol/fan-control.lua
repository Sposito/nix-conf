local socket = require("socket")

-- Check for debug flag
local debug_enabled = false
for _, v in ipairs(arg) do
  if v == "--debug" then
    debug_enabled = true
    break
  end
end

local function debug_log(msg)
  if debug_enabled then
    print("[DEBUG] " .. msg)
  end
end

local function read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*all")
  file:close()
  return content
end

local function write_file(path, value)
  local file = io.open(path, "w")
  if not file then return false end
  file:write(value)
  file:close()
  return true
end

local function get_temp()
  local temp_str = read_file("/sys/class/thermal/thermal_zone0/temp")
  if not temp_str then return nil end
  return tonumber(temp_str) / 1000.0
end

local function set_fan_speed(rpm)
  write_file("/sys/devices/platform/applesmc.768/fan1_manual", "1")
  write_file("/sys/devices/platform/applesmc.768/fan1_output", tostring(math.floor(rpm)))
end

local function fan_curve(temp)
  if temp < 50 then
    return 2000
  elseif temp > 85 then
    return 6000
  else
    local t = (temp - 50) / 35.0
    return 2000 + (t ^ 3) * 4000
  end
end

-- Main loop
while true do
  local temp = get_temp()
  if temp then
    local rpm = fan_curve(temp)
    debug_log(string.format("Temp: %.2f°C -> RPM: %d", temp, rpm))
    set_fan_speed(rpm)
  else
    debug_log("Failed to read temperature.")
  end
  socket.sleep(1) -- replaces os.execute("sleep 1"), allows Ctrl+C
end
