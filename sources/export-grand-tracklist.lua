#!/usr/bin/env lua

local htmlparser = require("htmlparser")

local input_file, err = io.open("grand-tracklist-150-to-225.html", "r")
if not input_file then error(err) end

local root = htmlparser.parse(input_file:read("*a"), 10000)

input_file:close()

local list = root:select("li")

local output_file = io.open("music.csv", "a")

for _, item in ipairs(list) do
  local content = item:getcontent()
  if #content < 200 then
    output_file:write(content .. "\n")
  else
    print("Item of length " .. #content .. " ignored.")
  end
end

output_file:close()
