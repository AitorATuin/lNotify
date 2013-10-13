PDIR =
VER = 0.1
DEBUG := 0
PREFIX := $(HOME)/.lua/
all: build

build:
	@echo "====================="
	@echo "= Building C module ="
	@echo "====================="
	@mkdir -p Build/Library
	@cd C && make DEBUG=$(DEBUG)
	@echo "======================="
	@echo "= Building Lua module ="
	@echo "======================="
	@mkdir -p Build/Shared/iNotify
	@cd Lua && make


install: build
	@echo "====================="
	@echo "= Instaling iNotify ="
	@echo "====================="
	@cd C && make install PREFIX=$(PREFIX)
	@cd Lua && make install PREFIX=$(PREFIX)

uninstall:
	@echo "====================="
	@echo "= Uninstalling iNotify ="
	@echo "====================="
	@cd C && make uninstall PREFIX=$(PREFIX)
	@cd Lua && make uninstall PREFIX=$(PREFIX)

clean:
	@echo "======================="
	@echo "= Cleaning Lua module ="
	@echo "======================="
	@cd Lua && make clean
	@echo "====================="
	@echo "= Cleaning C module ="
	@echo "====================="
	@cd C && make clean
	@rm -rf Build
