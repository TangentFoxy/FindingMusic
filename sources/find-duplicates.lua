#!/usr/bin/env lua

-- local csv = require("csv")
-- 
-- local music = csv.open("music-cleaned.csv", {
--   separator = ",",
--   header = true,
--   columns = {
--     track = { name = "Track" },
--     url = { name = "Download URL" },
--     note = { name = "Note" },
--     duplicate = { name = "Duplicate" },
--   }
-- })
local music = io.open("music-cleaned.csv", "r")

local unique_tracks = {}
-- for fields in music:lines() do
--   local track = fields.track
for track in music:lines() do
  local normalized_track = track:gsub("%W", ""):lower()

  if unique_tracks[normalized_track] then
    table.insert(unique_tracks[normalized_track].alternate_names, track)
  else
    unique_tracks[normalized_track] = { name = track, alternate_names = {} }
  end
end

music:close()

local output_file = io.open("music-cleaned-2.csv", "w")

for _, track in pairs(unique_tracks) do
  local alternate_names = ""
  if #track.alternate_names > 0 then
    alternate_names = table.concat(track.alternate_names, "|")
  end
  output_file:write(track.name .. "\t" .. alternate_names .. "\n")
end

output_file:close()
