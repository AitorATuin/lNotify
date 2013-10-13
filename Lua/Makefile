PDIR = ..
DATADIR = $(PDIR)/Data
PREFIX := $(HOME)/.lua
CDIR = $(PDIR)/C
LUADIR = $(PDIR)/Lua
BINDIR = $(PDIR)/Bin
BUILDLIBRARYDIR = $(PDIR)/Build/Library
BUILDSHAREDDIR = $(PDIR)/Build/Shared
CONSTANTSBIN = $(DATADIR)/constants.lua

CONSTANTSDEF = $(DATADIR)/iNotifyConstants.def
CONSTANTSC = $(CDIR)/iNotifyConstants.c
CONSTANTSLUA = $(LUADIR)/iNotify/Constants.lua
CONSTANTSGEN = $(DATADIR)/iNotifyConstants

NOTIFYMOD = iNotify

all: constants

constants: $(CONSTANTSDEF)
	@echo " ==== Building iNotify Constants [$(CONSTANTSLUA)] ===="
	@$(CONSTANTSBIN) '$(CONSTANTSDEF)' '$(CONSTANTSC)' '$(CONSTANTSLUA)' '$(NOTIFYMOD)'
	@echo "  --> $(CONSTANTSC) [CC]"
	@$(CC) -I$(CDIR) -o $(CONSTANTSGEN) $(CONSTANTSC)
	@echo "  --> $(CONSTANTSLUA) [LUA]"
	@$(CONSTANTSGEN) || true
	@cp $(LUADIR)/iNotify/iNotify.lua $(BUILDSHAREDDIR)/iNotify
	@cp $(LUADIR)/iNotify/Constants.lua $(BUILDSHAREDDIR)/iNotify
	@cp $(LUADIR)/iNotify/IEvent.lua $(BUILDSHAREDDIR)/iNotify
	@cp $(LUADIR)/iNotify/IEventsBuffer.lua $(BUILDSHAREDDIR)/iNotify
	@cp $(LUADIR)/struct.lua $(BUILDSHAREDDIR)

install: all
	@echo " == Installing iNotify.lua == "
	@mkdir -p $(PREFIX)/share/
	@cp -r $(BUILDSHAREDDIR)/iNotify $(PREFIX)/share
	@cp -r $(BUILDSHAREDDIR)/struct.lua $(PREFIX)/share/iNotify

uninstall:
	@echo " == Uninstalling iNotify.lua == "
	@rm -rf $(PREFIX)/share/iNotify

clean:
	@echo " ==== Cleaning Lua files ==== "
	@rm -rf $(CONSTANTSGEN)
	@rm -rf $(CONSTANTSLUA)
	@rm -rf $(CONSTANTSC)
