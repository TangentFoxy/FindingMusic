#!/usr/bin/env lua

local success, urlencode = pcall(function() return require("urlencode") end)
if not success then
  urlencode = nil
  print("Install 'urlencode' through LuaRocks for this script to function optimally.")
end
local success, music = pcall(function() return require("music") end)
if not success then
  print("music.lua library (and its adjacent music.json database) must be installed.")
  return
end

local help = [[Usage:

  search <count> <funkwhale>

<count>: How many tracks to search for. Defaults to 10
         (Opens a new tab per track in your default browser searching Google.)
<funkwhale>: Whether or not to search my FunkWhale instance for the track also.

Optionally requires urlencode to be installed from LuaRocks.
Currently only tested on MacOS 11.4 (Big Sur).
]]
if arg[1]:find("h") then
  print(help)
  return false
end

local count = tonumber(arg[1]) or 10
local funkwhale = arg[2]

local results = music.random(count, nil, nil, {downloaded = true, searched = true})
local errors_occurred, name, encoded = false
for _,v in ipairs(results) do
  name = music.name(v) -- music.data[v].names[1]
  if not name then
    print("Track '" .. v .. "' does not exist?")
    errors_occurred = true
    break
  end
  if urlencode then
    encoded = urlencode.encode_url(name)
  else
    encoded = name:gsub("%s", "+"):gsub("&", "&amp;")
  end
  if funkwhale then
    local separator = name:find(" %- ")
    if separator then name = name:sub(separator + 3) end
    if urlencode then
      name = urlencode.encode_url(name)
    else
      name = name:gsub("%s", "+"):gsub("&", "&amp;")
    end
    os.execute("open \"https://funkwhale.tangentfox.com/search?q=" .. name .. "&type=tracks\"")
  end
  os.execute("open \"https://google.com/search?q=" .. encoded .. "\"")
end
if errors_occurred then
  print("Database not saved because errors occurred.")
else
  music.set(results, {searched = true})
  music.save()
end
