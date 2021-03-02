#!/usr/bin/env lua

local cjson = require("cjson")

local music = io.open("music-cleaned.csv", "r")

local unique_tracks = {}
for track in music:lines() do
  local normalized_track = track:gsub("%W", ""):lower()

  if unique_tracks[normalized_track] then
    table.insert(unique_tracks[normalized_track].names, track)
  else
    unique_tracks[normalized_track] = { names = { track } }
  end
end

music:close()

local output_file = io.open("music.json", "w")
output_file:write(cjson.encode(unique_tracks))
output_file:close()
