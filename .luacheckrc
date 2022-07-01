codes = true
cache = true
std = "max"
globals = { "xero" }
max_line_length = 120
read_globals = {
    "GAMESTATE";
    "DISPLAYMAN";
    "SCREENMAN";
}
ignore = {
    "413";
    "213";
}

files['template/core/setup.lua'] = {
    ignore = {
        "111"; -- read unknown global
        "113"; -- write unknown global
    }
}
files['template/require.lua'] = {
    globals = {
        "require";
        "package";
    }
}

files['template/mirin/v6.lua'] = {
	ignore = {
		"212"; -- unused argument
		"211"; -- unused function
	}
}
