-- require this and use it in a REPL to modify the JSON database

local cjson = require("cjson")

local music = {}

function music.normalize(str)
  return str:gsub("%W", ""):lower()
end

function music.load(force, file_name)
  if music.data and not force then
    print("Music library was already loaded, use 'music.load(true)' to force load.")
    return false
  end
  local file, err = io.open(file_name or "music.json", "r")
  if not file then error(err) end
  music.data = cjson.decode(file:read("*a"))
  file:close()
  print("Music library loaded.")
  return true
end

function music.save(file_name)
  local str = cjson.encode(music.data)
  local file, err = io.open(file_name or "music.json", "w")
  if not file then error(err) end
  file:write(str)
  file:close()
  print("Music library saved.")
  return true
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
  local entry = music.data[normalized]
  if entry then
    for _, existing_name in ipairs(entry.names) do
      if existing_name == name then
        print("Already in library.")
        return false
      end
    end
    table.insert(entry.names, name)
    print("Already in library (normalized to: '" .. normalized .. "'). Added as alternate name of '" .. entry.names[1] .. "'")
    return true
  else
    music.data[normalized] = { names = { name } }
    print("Track added (normalized to: '" .. normalized .. "')")
    return true
  end
end

function music.add_file(file_name)
  local file, err = io.open(file_name, "r")
  if not file then error(err) end
  for track in file:lines() do
    if #track > 0 then
      music.add(track)
    end
  end
  file:close()
  return true
end

-- match is a normalized name or a list of names, info is a table of key-value pairs to be set
function music.set(match, info)
  if type(match) == "table" then
    for _, value in ipairs(match) do
      music.set(value, info)
    end
    return true
  end

  tab = music.data[music.normalize(match)]
  if not tab then
    print("'" .. tab .. "' does not exist!")
    return false
  end
  for key, value in pairs(info) do
    tab[key] = value
  end
  return true
end

-- returns a list of all tracks with a `url` key but no `downloaded` key.
-- function music.generate_needed_downloads()
--   print("To be written.")
-- end

music.load()

return music
