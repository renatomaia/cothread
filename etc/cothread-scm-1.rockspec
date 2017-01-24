package = "CoThread"
version = "scm-1"
source = {
	url = "https://github.com/renatomaia/luacothread/archive/master.zip",
	dir = "luacothread-master",
}
description = {
	summary = "Cooperative Multithreading using Lua Coroutines",
	detailed = [[
		CoThread is a library for cooperative multithreading in Lua using
		coroutines. It is organized as a set o modules that provides different
		functionalities incrementally. Such functionalities can be in the form
		of module extensions or extra modules with utility functions and objects.
	]],
	license = "MIT",
	homepage = "http://www.tecgraf.puc-rio.br/~maia/lua/cothread",
}
dependencies = {
	"lua >= 5.1",
	"loop >= 3.0, < 4.0",
	"loopcollections >= 1.0beta, < 2.0",
	"loopdebugging >= 1.0beta, < 2.0",
	"loopobjects >= 1.0beta, < 2.0",
}
build = {
	type = "builtin",
	modules = {
		["cothread.copas"] = "lua/cothread/copas.lua",
		["cothread.EventGroup"] = "lua/cothread/EventGroup.lua",
		["cothread.EventPoll"] = "lua/cothread/EventPoll.lua",
		["cothread.Mutex"] = "lua/cothread/Mutex.lua",
		["cothread.plugin.signal"] = "lua/cothread/plugin/signal.lua",
		["cothread.plugin.sleep"] = "lua/cothread/plugin/sleep.lua",
		["cothread.plugin.socket"] = "lua/cothread/plugin/socket.lua",
		["cothread.Queue"] = "lua/cothread/Queue.lua",
		["cothread.socket"] = "lua/cothread/socket.lua",
		["cothread.Timer"] = "lua/cothread/Timer.lua",
		["cothread"] = "lua/cothread.lua",
	},
}
