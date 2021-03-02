Note: Due to commas existing in the source data, all CSV files in `sources` are
not actually csv files, except `music-cleaned-2.csv`, which is tab-delimmited to
handle this. It also was abandoned because of handling issues with the `csv`
library on LuaRocks.

## music.json

An object of objects, each track indexed by a normalized form of its name, which
is all lowercase alphanumeric characters only.

- `names`: A list of names equivalent to this track (some tracks have duplicate
  names due to formatting differences)
- `downloaded`: (TRUE or NULL) whether or not I have downloaded it
- `url`: (String or NULL) representing where I downloaded it
- `note`: (String or NULL) misc. note
- `buy`: (String or NULL) a URL where it can be bought (or where I bought it)
- `favorite`: (TRUE or NULL) a favorite track
- `genre`: (String or NULL) primary genre

(Note: I'm sure I've downloaded many tracks that aren't marked as downloaded.)

## music.lua

A simple interface library to use in a Lua REPL.

- `load(force)` (called immediately) loads `music.json`
- `save()` saves to `music.json`
- `add(str)` adds a new track (checks for duplicates)
- `find(str)` finds possible track matches by normalizing the input string,
  returns them in a list
- `set(match, info)` match can be a list (as is returned by find) or a
  normalized track name, info must be a table of key-value pairs, these will be
  set on the matched tracks, overwriting existing values if a key is already in
  use
- `normalize(str)` returns a normalized form of the input string
