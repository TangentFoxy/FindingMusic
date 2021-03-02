#!/usr/bin/env lua

-- csv library appears to not function correctly here, so a different script was used

local csv = require("csv")
local cjson = require("cjson")

local input = csv.open("music-cleaned-2.csv", { separator = "\t" })

local music = {}
for fields in input:lines() do
  music[fields[1]] = {}
  if fields[2] and #fields[2] > 0 then
    local alternate_names = fields[2]
    local names = {}
    local index = alternate_names:find("|")
    while index do
      local name = alternate_names:sub(1, index - 1)
      if name and #name > 0 then
        table.insert(names, name)
      end
      alternate_names = alternate_names:sub(index + 1)
    end
    if alternate_names and #alternate_names > 0 then
      table.insert(names, alternate_names)
    end
    if #names > 0 then
      music[fields[1]].alternate_names = names
    end
  end
end

local data = cjson.encode(music)

local output = io.open("music.json", "w")
output:write(data)
output:close()
