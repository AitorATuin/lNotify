local IEventsBuffer = {}
local M = {}
local M_mt = {}

require "luarocks.require"
local alien = require "alien"
local IEvent = require "iNotify.IEvent"

local IEventsBuffer = function (libiNotify)
   M.init(libiNotify)
   M.init = nil
   M.new = M.new(libiNotify)
   return M
end

-- Metatable methods
M_mt.EVENT_SIZE = function (libiNotify)
   return libiNotify._event_size()
end

M_mt.events = function (libiNotify)
   return function (iEventsBuffer)
      local offset = 0
      return function ()
         if (offset < (iEventsBuffer.Read or 0)) then
            -- needed offset + 1 as alien offsets are lua based (starts in 1)
            local ev = IEvent.new(iEventsBuffer.Buffer:topointer(offset+1))
            offset = offset + ev.Length + iEventsBuffer.EVENT_SIZE
            return ev
         else
            return nil
         end
      end
   end
end

M.init = function (libiNotify)
   libiNotify._event_size:types {
      ret = "int"
   }
   local mt_methods = {
      "events"
   }
   for _, m in pairs(mt_methods) do
      M_mt[m] = M_mt[m](libiNotify)
   end
end

M.new = function (libiNotify)
   local EVENT_SIZE = libiNotify._event_size()
   M_mt.EVENT_SIZE = EVENT_SIZE
   return function (n)
      local t = {}
      local size = (EVENT_SIZE + 16) * (n or 1024)
      t.Buffer = alien.buffer(size)
      t.Size = size
      t.Read = 0
      return setmetatable(t, {
                             __index = M_mt
      })
   end
end

return IEventsBuffer
