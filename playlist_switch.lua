
local function on_next_track()
  local file = mp.get_property("path")
  os.execute(string.format("emacsclient -e '(ytmusic-song \"%s\")'", file))
end

mp.register_event("file-loaded",  on_next_track)
