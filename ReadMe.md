This database contains tracks played on Friday Night Tracks episodes 12 through
240. It may contain other tracks because I haven't kept track of whether or not
I included other sources.

## music.json

An object of objects, each track indexed by a normalized form of its name, which
is all lowercase alphanumeric characters only. Note that only `names` is
enforced by the library.

- `names`: A list of names equivalent to this track (some tracks have duplicate
  names due to formatting differences)
- `downloaded`: (TRUE or NULL) whether or not I have downloaded it
- `url`: (String or NULL) representing where I downloaded it
- `note`: (String or NULL) misc. note
- `buy`: (String or NULL) a URL where it can be bought (or where I bought it)
- `favorite`: (TRUE or NULL) a favorite track
- `genre`: (String or NULL) primary genre
- `invalid`: (TRUE or NULL) whether or not this is actually a track (whoops!)
- `searched`: (TRUE or NULL) whether or not a track has been searched for using
  `search.lua` (I'm being lazy, and obtaining music this way without fully
  updating the database, sue me) (note: this script has an issue with tracks
  with special characters in their names, I am not sure of the cause)

(I'm also sure I've downloaded many tracks that aren't marked as downloaded.)

## music.lua

A simple interface library.

- `load(force, file_name)` loads from specified file or `music.json` (called
  immediately by default, but exposed so you can force a reload or a different
  file)
- `save(file_name)` saves to `file_name` or `music.json`
- `add(str)` adds a new track (checks for duplicates)
- `add_file(file_name)` adds new tracks from the specified file (file must have
  one track per line, ignores empty lines)
- `remove(name)` removes a track, if it exists (input is normalized)
- `find(str)` finds possible track matches by normalizing the input string,
  returns them as a list of normalized names (cannot handle already normalized
  input in my db because of a bug)
- `set(match, info)` match can be a list (as is returned by find) or a track
  name (either will be normalized), info must be a table of key-value pairs,
  these will be set on the matched tracks, overwriting existing values if a key
  is already in use
- `normalize(str)` returns a normalized form of the input string
- `name(name)` returns the first name of a track (input is normalized)

`music.random(count, match, include, exclude)` is a little more complicated.
- `count` is the maximum number of returned names, and defaults to 1
- `match` can be nil, a name, or a list of names (names and lists will have
  their values normalized)
- `include` and `exclude` are tables of key-value pairs that must exist or not
  exist, `true` values mean non-false keys, but other values must match exactly

Example: `music.random(5, nil, {url = true}, {downloaded = true})` will return
5 random tracks from the whole database that have a url, but do not have
`downloaded` set.

---

The [export from grand tracklist](https://github.com/TangentFoxy/FindingMusic/blob/d4b672d9e049736606797781f84d21d2b12e4d90/sources/export-grand-tracklist.lua) script has potential future list, but was removed in a previous commit.
