-- require this and use it in a REPL to modify the JSON database

local cjson = require("cjson")

local music = {}

function music.normalize(str)
  return str:gsub("%W", ""):lower()
end

function music.load(force)
  if music.data and not force then
    print("Music library was already loaded, use 'music.load(true)' to force load.")
    return
  end
  local file = io.open("music.json", "r")
  music.data = cjson.decode(file:read("*a"))
  file:close()
  print("Music library loaded.")
end

function music.save()
  local str = cjson.encode(music.data)
  local file = io.open("music.json", "w")
  file:write(str)
  file:close()
  print("Music library saved.")
end

function music.find(str)
  str = music.normalize(str)
  local matches = {}
  for key in pairs(music.data) do
    if key:find(str) then
      table.insert(matches, key)
    end
  end
  print(#matches .. " matches returned.")
  return matches
end

function music.add(name)
  local normalized = music.normalize(name)
  if music.data[normalized] then
    local duplicate = false
    for _, existing_name in ipairs(music.data[normalized].names) do
      if existing_name == name then
        duplicate = true
        print("Already in library.")
        break
      end
    end
    if not duplicate then
      table.insert(music.data[normalized].names, name)
      print("Already in library. Added as alternate name of '" .. musoc.data[normalized].names[1] .. "'")
    end
  else
    music.data[normalized] = { names = { name } }
    print("Track added (normalized to: '" .. normalized .. "')")
  end
end

-- match is a normalized name or a list of normalized names, info is a table of key-value pairs to be set
function music.set(match, info)
  if type(match) == "table" then
    for _, value in ipairs(match) do
      music.set(value, info)
    end
    return
  end

  tab = music.data[match]
  if not tab then
    print("'" .. tab .. "' does not exist!")
  end
  for key, value in pairs(info) do
    tab[key] = value
  end
end

-- returns a list of all tracks with a `url` key but no `downloaded` key.
-- function music.generate_needed_downloads()
--   print("To be written.")
-- end

music.load()

return music
