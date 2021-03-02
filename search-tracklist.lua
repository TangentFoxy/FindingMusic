#!/usr/bin/env lua

local success, urlencode = pcall(function() return require("urlencode") end)
if not success then
  urlencode = nil
  print("Install 'urlencode' through LuaRocks for this script to function optimally.")
end

local help == [[Usages:

  search-tracklist <file>

<file>: A newline-delimmited list of tracks to search for.
(Opens a new tab in your default browser searching Google for each line.)

Optionally requires urlencode to be installed from LuaRocks.
Currently only tested on MacOS 11.2.1 (Big Sur).
]]

local filename = arg[1]

if #filename < 1 then
  print(help)
end

local file, err = io.open(filename, 'r')
if not file then
  error(err)
end

for line in file:lines() do
  if #line > 0 then
    if urlencode then
      line = urlencode.encode_url(line)
    else
      line = line:gsub("%s", "+"):gsub("&", "&amp;")
    end
    os.execute("open \"https://google.com/search?q=" .. line .. "\"")
    -- appeared to overstress my server opening so many tabs at once, so I removed this
    -- os.execute("open \"https://funkwhale.tangentfox.com/search?q=" .. line .. "&type=tracks\"")
  end
end
