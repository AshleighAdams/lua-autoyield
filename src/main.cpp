

//#include <pty.h>
//int openpty(int *amaster, int *aslave, char *name,						const struct
//termios *termp,						const struct winsize *winp);
//pid_t forkpty(int *amaster, char *name,							const struct termios
//*termp,							const struct winsize *winp);
//#include <utmp.h>
//int login_tty(int fd);
//Link with -lutil.

#include <lua5.2/lua.hpp>

// Posix
#include <stdio.h>
#include <stdint.h>
#include <errno.h>
//#include <util.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <pty.h>
#include <termios.h>

// STD
#include <iostream>
#include <string>
#include <vector>
#include <memory>
#include <fstream>
#include <thread>
#include <mutex>
#include <unordered_map>

int hook_resume(lua_State* L)
{
	return 0;
}

void hook(lua_State* L, lua_Debug *ar)
{
	// not sure if this is needed?
	//lua_yieldk(L, 0, 0, &hook_resume);
	lua_yield(L, 0);
	return;
}

int autoyield(lua_State* L)
{
	lua_State* T = lua_tothread(L, 1);
	int count = lua_tonumber(L, 2);
	int mask = /*LUA_MASKLINE +*/ LUA_MASKCOUNT;
	
	lua_sethook(T, &hook, mask, count);
	return 0;
}

static const luaL_Reg R[] =
{
	{"autoyield", autoyield},
	{ NULL, NULL }
};


extern "C"
{
	LUALIB_API int luaopen_autoyield(lua_State *L)
	{
		luaL_newlib(L, R);
		
		lua_pushstring(L, "_VERSION");
		lua_pushstring(L, "autoyield 0.1");
		lua_settable(L, -3);
		
		return 1;
	}
}

