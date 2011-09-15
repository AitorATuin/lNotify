PDIR = ..
DATADIR = $(PDIR)/Data
CDIR = $(PDIR)/C
LUADIR = $(PDIR)/Lua
BINDIR = $(PDIR)/Bin
BUILDLIBRARYDIR = $(PDIR)/Build/Library
BUILDSHAREDDIR = $(PDIR)/Build/Shared
CONSTANTSBIN = $(DATADIR)/constants.lua

CONSTANTSDEF = $(DATADIR)/lNotifyConstants.def
CONSTANTSC = $(CDIR)/lNotifyConstants.c
CONSTANTSLUA = $(LUADIR)/lNotify/Constants.lua
CONSTANTSGEN = $(DATADIR)/lNotifyConstants

NOTIFYMOD = lNotify

all: constants

constants: $(CONSTANTSDEF)
	@echo " ==== Building lNotify Constants [$(CONSTANTSLUA)] ===="
	@$(CONSTANTSBIN) '$(CONSTANTSDEF)' '$(CONSTANTSC)' '$(CONSTANTSLUA)' '$(NOTIFYMOD)'
	@echo "  --> $(CONSTANTSC) [CC]"
	@$(CC) -I$(CDIR) -o $(CONSTANTSGEN) $(CONSTANTSC)
	@echo "  --> $(CONSTANTSLUA) [LUA]"
	@$(CONSTANTSGEN) || true
	@cp $(LUADIR)/lNotify/lNotify.lua $(BUILDSHAREDDIR)/lNotify
	@cp $(LUADIR)/lNotify/Constants.lua $(BUILDSHAREDDIR)/lNotify
	@cp $(LUADIR)/struct.lua $(BUILDSHAREDDIR)

clean:
	@echo " ==== Cleaning Lua files ==== "
	@rm -rf $(CONSTANTSGEN)
	@rm -rf $(CONSTANTSLUA)
	@rm -rf $(CONSTANTSC)
