include config

CFLAGS += -fPIC -O3 -Wall -Werror --std=c++11
LFLAGS += -shared
LIBS   += -lutil
INSTALL = install -D

CFLAGS += `pkg-config $(LUAPKG) --cflags`
LIBS   += `pkg-config $(LUAPKG) --libs` -lpthread

SOURCES = src/main.cpp
OBJECTS = $(SOURCES:.cpp=.o)

all: autoyield.so

#pty.lua:
#	luac -p src/$@

autoyield.o: src/main.cpp
	$(CXX) -o autoyield.o -c $(CFLAGS) $<
#./src/main.cpp

autoyield.so: autoyield.o
	$(CXX) -o $@ $(LFLAGS) $(LIBS) $<
	
clean:
	$(RM) autoyield.o autoyield.so ./*~ ./**/*~
	
install-so: autoyield.so
	$(INSTALL) $< $(LUA_LIBDIR)/autoyield.so
	
install: install-so

