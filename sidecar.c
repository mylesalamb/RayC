#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int lib_test(lua_State *L){
    return 0;
}


int luaopen_mylib (lua_State *L) {
      lua_register(L,"lib_test",lib_test);
      return 1;
}