codes = true
cache = true
std = "max"
globals = { "xero" }
max_line_length = 120
max_cyclomatic_complexity = 20
read_globals = {
    "GAMESTATE";
    "DISPLAYMAN";
    "SCREENMAN";
}
ignore = {
    "413";
    "213";
}

files['template/prelude.lua'] = {
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
