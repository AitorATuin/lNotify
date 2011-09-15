PDIR = 
VER = 0.1
DEBUG := 0
all:
	@echo "====================="
	@echo "= Building C module ="
	@echo "====================="
	@mkdir -p Build/Library
	@cd C && make DEBUG=$(DEBUG)
	@echo "======================="
	@echo "= Building Lua module ="
	@echo "======================="
	@mkdir -p Build/Shared/lNotify
	@cd Lua && make

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
	
