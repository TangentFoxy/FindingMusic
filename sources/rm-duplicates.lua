#!/usr/bin/env lua

local music = io.open("music.csv", "r")

local unique = {}
for line in music:lines() do
  if not unique[line] then
    unique[line] = line
  end
end

music:close()

local output_file = io.open("music-cleaned.csv", "w")
for line in pairs(unique) do
  output_file:write(line .. "\n")
end

output_file:close()
