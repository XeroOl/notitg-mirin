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

files['src/prelude.lua'] = {
    ignore = {
        "111"; -- read unknown global
        "113"; -- write unknown global
    }
}
files['src/require.lua'] = {
    globals = {
        "require";
        "package";
    }
}

files['src/mirin/v6.lua'] = {
	ignore = {
		"212"; -- unused argument
		"211"; -- unused function
	}
}
