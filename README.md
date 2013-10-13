luaiNotify
=======

Lua binding (using alien) to the [inotify linux kernel subsystem] (http://man7.org/linux/man-pages/man7/inotify.7.html).

Instalation
===========

luaiNotify can be installed directly into your $HOME directory just by typing:

    make install

This will install the library under $HOME/.lua/ so you can use luaiNotify by adding that directory to *package.path* as follows:

```lua
local HOME = os.getenv("HOME")
local LOCALLUAPATH = HOME .. "/.lua/share/?.lua;" .. HOME ..  "/.lua/share/?/?.lua"
package.path = package.path .. ";" .. LOCALLUAPATH
```

Now, you are ready to use it!.

Usage
=====

When requiring the "iNotify" module, it gives you just one function called *configure*, this functions doesnt take any parameter and (as its name says) configure the module to be used properly.
```lua
local iNotify = require "iNotify".configure()
```

Examples
========

This is just a lua implementation of this [example] (http://www.thegeekstuff.com/2010/04/inotify-c-program-example/)

```lua
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
```

TODO
====
- [ ] Add luarocks support
- [ ] Implement loop dispatcher
