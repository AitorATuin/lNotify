local HOME = os.getenv("HOME")
local LOCALLUAPATH = HOME .. "/.lua/share/?.lua;" .. HOME ..  "/.lua/share/?/?.lua"

package.path = package.path .. ";" .. LOCALLUAPATH

require "luarocks.require"
local iNotify = require "iNotify".configure()
local fmt = string.format

local myNotify = iNotify.new()
local wd = myNotify:addWatch("/tmp/", bit32.bor(
                     iNotify.IN_CREATE,
                     iNotify.IN_DELETE))

local events = myNotify:read()
for ev in myNotify:events() do
   if (ev.IN_CREATE) then
      if (ev.IN_ISDIR) then
         print(fmt("New Directory was created %s\n", ev.Name))
      else
         print(fmt("New File was created %s\n", ev.Name))
      end
   elseif (ev.IN_DELETE) then
      if (ev.IN_ISDIR) then
         print(fmt("Directory %s was deleted\n", ev.Name))
      else
         print(fmt("File %s was deleted\n", ev.Name))
      end
   else
      print("Unknow event!")
   end
end

myNotify:kill()
