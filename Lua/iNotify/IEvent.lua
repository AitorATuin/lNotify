local alien = require "alien"
local IEvent = require "iNotify.Constants".forPackage({})
local struct = require "iNotify.struct"

-- s_inotifyev struct
local s_inotifyev = struct.defStruct {
   {"WD", "int"},
   {"Mask", "int"},
   {"Cookie", "int"},
   {"Length", "int"},
   {"Name", "pointer"}
}

-- IEvent metatable
local IEvent_mt = {}

-- Populate IEvent metatable with flag method checkers
local ievent_flags = {
   "IN_ACCESS",
   "IN_ATTRIB",
   "IN_CLOSE_WRITE",
   "IN_CLOSE_NOWRITE",
   "IN_CREATE",
   "IN_DELETE",
   "IN_DELETE_SELF",
   "IN_MODIFY",
   "IN_MOVE_SELF",
   "IN_MOVED_FROM",
   "IN_MOVED_TO",
   "IN_OPEN",
   "IN_ALL_EVENTS",
   "IN_MOVE",
   "IN_CLOSE",
   "IN_IGNORED",
   "IN_ISDIR",
   "IN_Q_OVERFLOW",
   "IN_UNMOUNT"
}
for _, name in pairs(ievent_flags) do
   local is_flag_set = function (event, flag)
      if bit32.band(event.Mask, flag) ~= 0 then return true end
      return false
   end
   IEvent_mt[name] = function (event)
      return is_flag_set(event, IEvent[name])
   end
end

-- IEvent.new :: Pointer -> IEvent
--   Creates a new IEvent
--   It uses a quick and dirty hack to access the "Name" field which is a char *
-- TODO: Improve (maybe memoizing the result) the Name field getter.
IEvent.new = function (ptr)
   local inotifyev = s_inotifyev:new(ptr)
   local mt = getmetatable(inotifyev)
   local old_mt_index = mt.__index
   mt.__index = function(ievent, k)
      if (k == "Name") then -- Access (char *) field "Name"
         local str = ""
         if (ievent.Length > 0) then
            for i=0, ievent.Length-1 do
               str = string.format(
                  "%s%c",
                  str,
                  ievent():get(inotifyev.offset("Name")+ i, "char"))
            end
         end
        return str
      elseif IEvent_mt[k] then
         if type(IEvent_mt[k] == "function") then
            return IEvent_mt[k](ievent)
         end
         return IEvent_mt[k]
      else
         return old_mt_index(ievent, k)
      end
   end
   return inotifyev
end

-- Return module
return IEvent
