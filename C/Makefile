PDIR = ..
PREFIX := $(HOME)/.lua
DATADIR = $(PDIR)/Data
BUILDLIBDIR = $(PDIR)/Build/Library
CC := gcc
DEBUG := 0
CCOPTS := -g

LIBNOTIFYVER = 0.1
LIBNOTIFYNAME = liblnotify
LIBNOTIFYSO = $(LIBNOTIFYNAME).$(LIBNOTIFYVER).so

all: liblnotify

liblnotify: lnotify.o
	@echo " ==== Building Signal Library ===="
	@echo "  --> $(LIBNOTIFYSO) [LD]"
	@$(CC) -g $(CCOPTS) -shared -Wl,-soname,$(LIBNOTIFYSO) -o $(BUILDLIBDIR)/$(LIBNOTIFYSO) lnotify.o

lnotify.o:
	@echo "  --> lnotify.o [CC]"
	@$(CC) $(CCOPTS) -D_DEBUG=$(DEBUG) -c lnotify.c

install: all
	@echo " === Installing $(LIBNOTIFYSO) === "
	@mkdir -p $(PREFIX)/lib/
	@cp $(BUILDLIBDIR)/$(LIBNOTIFYSO) $(PREFIX)/lib

uninstall:
	@echo " === Uninstalling $(LIBNOTIFYSO) === "
	@rm -rf $(PREFIX)/lib/$(LIBNOTIFYSO)

clean:
	@echo " ==== Cleaning C module ==== "
	@rm lnotify.o 2>/dev/null || true
	@rm $(LIBNOTIFYSO).0.1  2>/dev/null || true
	@rm $(BUILDLIBDIR)/$(LIBNOTIFYSO) 2>/dev/null || true


