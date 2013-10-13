local iNotify = {}
local M = require "iNotify.Constants".forPackage({})
local IEventsBuffer = require "iNotify.IEventsBuffer"
local IEvent = require "iNotify.IEvent"
local M_mt = {}
local alien = require "alien"
local bit = require "bit"

-- Exported interface to outside world!
--   Usage: require("iNotify").configure()
iNotify.configure = function ()
   local SOPATH = os.getenv("INOTIFYSO_DIR") or "/usr/lib/lua"
   local PATHS = {
      os.getenv("INOTIFYSODIR") or "./",
      os.getenv("HOME") .. "/.lua/lib/",
   }
   for p in package.cpath:gmatch("[^;]+") do
      PATHS[#PATHS+1] = p:match("(.+)/+[^/]+$")
   end

   local libinotify, success
   for _, p in ipairs(PATHS) do
      success, libinotify = pcall(alien.load,
                                  p.."/libinotify.0.1.so")
      if success then
         break
      end
   end

   if not success then
      return nil, "Could not load libinotify.0.1.so"
   else
     local libc = alien.default
     M.init(libc, libinotify)
     M.init = nil
     M.new = M.new(libc, libiNotify)
     return M
   end
end

local band = bit.band

-- Module Metatable functions
M_mt.addWatch = function (libc, libiNotify)
   return function (notify, file, mask)
      local wd = libc.inotify_add_watch(notify.fd, file, mask)
      if wd < 0 then
         return nil
      end
      if not notify.Watchs[wd] then
         notify.Watchs[#notify.Watchs+1] = {
            Path = file,
            Wd = wd,
            Mask = mask,
         }
      end
      return wd
   end
end

M_mt.removeWatch = function (libc, libiNotify)
   return function (notify, wd)
      if libc.inotify_rm_watch(notify.fd, wd) < 0 then
         return false
      end
      notify.Watchs[wd] = nil
      return true
   end
end

M_mt.pathForWatch = function (libc, libiNotify)
   return function (notify, wd)
      return notify.Watchs[wd].Path
   end
end

-- TODO, add signature to read
M_mt.read = function (libc, libiNotify)
   return function (notify)
      local read = libc.read(notify.fd, notify.EventsBuffer.Buffer, notify.EventsBuffer.Size)
      notify.EventsBuffer.Read = read
      return read
   end
end

M_mt.events = function (libc, libiNotify)
   return function (notify)
      return notify.EventsBuffer:events()
   end
end

M_mt.kill = function (libc, libiNotify)
   return function (notify)
      for wd in ipairs(notify.Watchs) do
         notify:removeWatch(wd)
      end
   end
end

-- Module Methods
M.init = function (libc, libiNotify)
   libc.inotify_init:types {
      ret = "int",
   }
   libc.inotify_add_watch:types {
      ret = "int",
      "int",
      "pointer",
      "int"
   }
   libc.inotify_rm_watch:types{
      ret = "int",
      "int",
      "int"
   }

   libc.read:types{
      ret = "int",
      "int",
      "pointer",
      "int"
   }

   libiNotify._event_size:types{
      ret = "int"
   }
   libiNotify._read:types{
      ret = "int",
      "int", "pointer",
   }
   local mt_methods = {
      "read", "kill", "events", "pathForWatch", "removeWatch", "addWatch"
   }
   for _, m in pairs(mt_methods) do
      M_mt[m] = M_mt[m](libc, libiNotify)
   end

   IEventsBuffer = IEventsBuffer(libiNotify)
end

M.new = function (libc, libiNotify)
   return function (n)
      local t = {}
      t.fd = libc.inotify_init()
      t.EventsBuffer = IEventsBuffer.new(n)
      t.Watchs = {}

      return setmetatable(t, {
                             __index = M_mt
      })
   end
end

-- Needed to bypass memory restrictions when using in multithreading envs
--[[NewNotifyFromMemory = function(notify, n)
   local t = {
   }
   t.fd = notify.fd
   t.Watchs = {}
   for w, wv in pairs(notify.Watchs) do
      t.Watchs[1] = {}
      for j,k in pairs(wv) do
         t.Watchs[w][j] = k
      end
   end
   t.EventsBuffer = IEventsBuffer.new(notify.EventsBuffer.N)
   return setmetatable(t, {
                          __index = notify_mt
   })
   end--]]

return iNotify
