#!/usr/bin/env luajit

local urlencode = require "lib.urlencode"
local music = require "music"

local help = [[Usage:

    ./search.lua <count> [funkwhale?]

  <count>: How many tracks to search for. Defaults to 5.
           (Opens a new tab per track in your default browser searching Google.)
  [funkwhale?]: true: Also search my FunkWhale instance for the track.

  Currently only tested on MacOS 11.4 to 12.1.
]]

-- count has to be a number, so this having 'h' or '?' is definitely a cry for help
if arg[1] and (arg[1]:find("h") or arg[1]:find("%?")) then
  print(help)
  return false
end

local count = tonumber(arg[1]) or 5
local search_funkwhale = arg[2] == "true"

local results = music.random(count, nil, nil, {downloaded = true, searched = true})
local errors_occurred = false

for _, normalized_name in ipairs(results) do
  local track_name = music.name(normalized_name) -- music.data[normalized_name].names[1]
  if not track_name then
    print("Track '" .. normalized_name .. "' does not exist?")
    errors_occurred = true
    break
  end

  -- only searches track names !
  if search_funkwhale then
    local encoded_track_name
    local separator = track_name:find(" %- ")
    if separator then
      encoded_track_name = urlencode.encode(track_name:sub(separator + 3))
    else
      encoded_track_name = urlencode.encode(track_name)
    end

    os.execute("open \"https://funkwhale.tangentfox.com/search?q=" .. encoded_track_name .. "&type=tracks\"")
  end

  os.execute("open \"https://google.com/search?q=" .. urlencode.encode(track_name) .. "\"")
end

if errors_occurred then
  print("Database not saved because errors occurred.")
else
  music.set(results, {searched = true})
  music.save()
end
