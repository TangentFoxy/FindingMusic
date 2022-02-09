#!/usr/bin/env luajit

local files = {
  io.open("tracklist (12-150).txt", "r"),
  io.open("tracklist (150-234).txt", "r"),
}

local unique = {}
for _, file in ipairs(files) do
  for line in file:lines() do
    if not unique[line] then
      unique[line] = line
    end
  end
  file:close()
end

local output = io.open("complete tracklist.txt", "w")
for line in pairs(unique) do
  output:write(line .. "\n")
end
output:close()
