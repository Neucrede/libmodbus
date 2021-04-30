OUT = libmodbus.dll
OUTDIR = ./out
OBJDIR = ./obj
DEPDIR = ./deps
SRCDIR = ../src
INCDIRS = -I$(SRCDIR) -I../mingw
SOURCES = $(wildcard $(SRCDIR)/*.c)
OBJS = $(addprefix $(OBJDIR)/, $(patsubst %.c, %.o, $(notdir $(SOURCES))))
DEPS = $(addprefix $(DEPDIR)/, $(patsubst %.c, %.d, $(notdir $(SOURCES))))
CC = gcc
CCFLAGS = -Wall -fPIC $(INCDIRS)
LDFLAGS = --shared -Wl,--kill-at,--output-def,libmodbus.def,--out-implib,libmodbus.a -lwsock32 -lws2_32

INCLUDE_DEPS = 0

ifeq ($(HAVE_MODBUS_TCP_PI),1)
CCFLAGS += -DLIBMODBUS_HAVE_MODBUS_TCP_PI
endif

debug : deps main
debug : INCLUDE_DEPS = 1
debug : CCFLAGS += -g

release : deps main
release : INCLUDE_DEPS = 1
release : CCFLAGS += -O2

main : $(OUT) $(OUTA)
	dlltool -d libmodbus.def --dllname libmodbus.dll --output-lib libmodbus.lib --kill-at

$(OUT) : $(OBJS)
	$(CC) -o $(OUT) $(OBJS) $(LDFLAGS)
	
$(OUTA) : $(OBJS)
	$(AR) $(ARFLAGS) $@ $(OBJS)

$(OBJDIR)/%.o : $(SRCDIR)/%.c
	$(CC) -c $(CCFLAGS) $< -o $@

deps : $(DEPS)

ifeq ($(INCLUDE_DEPS),1)
include $(DEPS)
endif

$(DEPDIR)/%.d : $(SRCDIR)/%.c
	set -e; \
	rm -f $@; \
	$(CC) -MM -MP $(INCDIRS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1\.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

.PHONY: clean
	
clean:
	-rm -f $(OBJDIR)/*.o
	-rm -f $(DEPDIR)/*.d
