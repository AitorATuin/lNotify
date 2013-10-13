PDIR = ..
PREFIX := $(HOME)/.lua
DATADIR = $(PDIR)/Data
BUILDLIBDIR = $(PDIR)/Build/Library
CC := gcc
DEBUG := 0
CCOPTS := -g -fPIC

LIBNOTIFYVER = 0.1
LIBNOTIFYNAME = libinotify
LIBNOTIFYSO = $(LIBNOTIFYNAME).$(LIBNOTIFYVER).so

all: libinotify

libinotify: inotify.o
	@echo " ==== Building Signal Library ===="
	@echo "  --> $(LIBNOTIFYSO) [LD]"
	@$(CC) -g $(CCOPTS) -shared -Wl,-soname,$(LIBNOTIFYSO) -o $(BUILDLIBDIR)/$(LIBNOTIFYSO) inotify.o

inotify.o:
	@echo "  --> lnotify.o [CC]"
	@$(CC) $(CCOPTS) -D_DEBUG=$(DEBUG) -c inotify.c

install: all
	@echo " === Installing $(LIBNOTIFYSO) === "
	@mkdir -p $(PREFIX)/lib/
	@cp $(BUILDLIBDIR)/$(LIBNOTIFYSO) $(PREFIX)/lib

uninstall:
	@echo " === Uninstalling $(LIBNOTIFYSO) === "
	@rm -rf $(PREFIX)/lib/$(LIBNOTIFYSO)

clean:
	@echo " ==== Cleaning C module ==== "
	@rm inotify.o 2>/dev/null || true
	@rm $(LIBNOTIFYSO).0.1  2>/dev/null || true
	@rm $(BUILDLIBDIR)/$(LIBNOTIFYSO) 2>/dev/null || true
