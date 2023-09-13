return {
	ease = function(beat, len, eas, mods, opts)
		local t = {beat, len, eas}
		for mod, percent in pairs(mods) do
			table.insert(t, percent)
			table.insert(t, mod)
		end
		opts = opts or {}
		for k, v in pairs(opts) do
			t[k] = v
		end
		xero.ease(t)
	end,
	add = function(beat, len, eas, mods, opts)
		local t = {beat, len, eas}
		for mod, percent in pairs(mods) do
			table.insert(t, percent)
			table.insert(t, mod)
		end
		opts = opts or {}
		for k, v in pairs(opts) do
			t[k] = v
		end
		xero.add(t)
	end,
	set = function(beat, mods, opts)
		local t = {beat}
		for mod, percent in pairs(mods) do
			table.insert(t, percent)
			table.insert(t, mod)
		end
		opts = opts or {}
		for k, v in pairs(opts) do
			t[k] = v
		end
		xero.set(t)
	end,
	acc = function(beat, mods, opts)
		local t = {beat}
		for mod, percent in pairs(mods) do
			table.insert(t, percent)
			table.insert(t, mod)
		end
		opts = opts or {}
		for k, v in pairs(opts) do
			t[k] = v
		end
		xero.acc(t)
	end,
	reset = function(beat, len, eas, opts)
		if type(len) == "table" then
			opts = len
			len = 0
			eas = xero.instant
		end
		local t = {beat, len, eas}
		opts = opts or {}
		for k, v in pairs(opts) do
			t[k] = v
		end
		xero.reset(t)
	end,
	alias = function(old, new)
		xero.alias {old, new}
	end,
	setDefault = function(mods)
		local t = {}
		for mod, percent in pairs(mods) do
			table.insert(t, percent)
			table.insert(t, mod)
		end
		xero.setDefault(t)
	end,
	aux = xero.aux,
	defineMod = function(inputs, fn, outputs, opts)
		local t = {}
		for _, v in ipairs(inputs) do
			table.insert(t, v)
		end
		table.insert(t, fn)
		if outputs and not opts and not outputs[1] then
			outputs, opts = nil, outputs
		end
		if outputs then
			for _, v in ipairs(outputs) do
				table.insert(t, v)
			end
		end
		opts = opts or {}
		for k, v in pairs(opts) do
			t[k] = v
		end
		xero.defineMod(t)
	end,
	node = function(inputs, fn, outputs, opts)
		local t = {}
		for _, v in ipairs(inputs) do
			table.insert(t, v)
		end
		table.insert(t, fn)
		if outputs and not opts and not outputs[1] then
			outputs, opts = nil, outputs
		end
		if outputs then
			for _, v in ipairs(outputs) do
				table.insert(t, v)
			end
		end
		opts = opts or {}
		for k, v in pairs(opts) do
			t[k] = v
		end
		xero.node(t)
	end,
	getPlr = xero.getPlr,
	touchMod = xero.touchMod,
	touchAllMods = xero.touchAllMods,
	func = function(beat, fn, opts)
		local t = {beat, fn}
		opts = opts or {}
		for k, v in pairs(opts) do
			t[k] = v
		end
		xero.func(t)
	end,
	perframe = function(beat, len, fn, opts)
		local t = {beat, len, fn}
		opts = opts or {}
		for k, v in pairs(opts) do
			t[k] = v
		end
		xero.perframe(t)
	end,
	funcEase = function(...)
		local t = arg
		if type(t[#t]) == "table" then
			local opts = t[#t]
			t[#t] = nil
			opts = opts or {}
			for k, v in pairs(opts) do
				t[k] = v
			end
		end
		xero.funcEase(t)
	end,
	setupAftSprite = xero.setupAftSprite,
	blendEase = xero.blendEase,
	stableSort = xero.stableSort,
	unstableSort = xero.unstableSort
}
