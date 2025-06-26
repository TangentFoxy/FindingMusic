-- require this and use it in a REPL to modify the JSON database

local json = require "lib.dkjson"

local music = {}

function music.normalize(str)
  return str:gsub("%W", ""):lower()
end

function music.name(name)
  local entry = music.data[music.normalize(name)]
  if not entry then entry = music.data[name] end -- some normalized names have extra characters somehow
  if entry then
    return entry.names[1]
  else
    return nil
  end
end

function music.load(force, file_name)
  if music.data and not force then
    print("Music library was already loaded, use 'music.load(true)' to force load.")
    return false
  end
  local file, err = io.open(file_name or "music.json", "r")
  if not file then error(err) end
  music.data = json.decode(file:read("*a"))
  file:close()
  print("Music library loaded.")
  return true
end

function music.save(file_name)
  local str = json.encode(music.data, { indent = true })
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

-- count is maximum number of returned names, defaults to 1
-- match can be nil, a name, or a list of names
-- include is a table of key-value pairs that must exist
-- exclude is a table of key-value pairs that must not exist
-- 'true' values mean non-false keys, any other value must match exactly
-- example: music.random(5, nil, {url = true}, {downloaded = true}) will return
--  5 random tracks that have a url, but have not been downloaded
function music.random(count, match, include, exclude)
  local matches, results = {}, {}
  if not music.seed then music.seed = os.time() math.randomseed(music.seed) end
  count = math.floor(tonumber(count) or 1)
  local function filter(match, include, exclude)
    local matches = {}
    for _, name in ipairs(match) do
      local valid = true
      local compare = music.data[name]
      for k,v in pairs(include) do
        if v == true then
          if not compare[k] then
            valid = false
            break
          end
        else
          if compare[k] ~= v then
            valid = false
            break
          end
        end
      end
      for k,v in pairs(exclude) do
        if v == true then
          if compare[k] then
            valid = false
            break
          end
        else
          if compare[k] == v then
            valid = false
            break
          end
        end
      end
      if valid then
        table.insert(matches, name)
      end
    end
    return matches
  end
  if type(match) == "table" then
    for _, v in ipairs(match) do
      table.insert(matches, v) -- should be normalized already
    end
  elseif type(match) == "string" then
    -- compensating for db bug...
    if music.data[music.normalize(match)] then
      matches[1] = music.normalize(match)
    else
      matches[1] = match
    end
  else
    for k in pairs(music.data) do
      table.insert(matches, k)
    end
  end
  matches = filter(matches, include or {}, exclude or {})
  while count > 0 and #matches > 0 do
    for i = #matches, 1, -1 do
      if math.random() < 1 / #matches then
        table.insert(results, table.remove(matches, i))
        count = count - 1
      end
      if count < 1 then
        break
      end
    end
  end
  return results
end

function music.add(name) -- input should never be normalized
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

function music.remove(name)
  local normalized = music.normalize(name)
  if not music.data[normalized] then normalized = name end -- handling db bug
  if music.data[normalized] then
    music.data[normalized] = nil
    return true
  end
  return false
end

-- match is a name or a list of names, info is a table of key-value pairs to be set
function music.set(match, info)
  if type(match) == "table" then
    for _, value in ipairs(match) do
      music.set(value, info)
    end
    return true
  end

  tab = music.data[music.normalize(match)]
  if not tab then tab = music.data[match] end -- compensating for database bug
  if not tab then
    print("'" .. match .. "' does not exist!")
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
