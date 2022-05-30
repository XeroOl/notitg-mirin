-- Convenience shortcuts

local sqrt = math.sqrt
local sin = math.sin
local asin = math.asin
local cos = math.cos
local pow = math.pow
local exp = math.exp
local pi = math.pi
local abs = math.abs


local M = require('mirin.utils').module()

-- Utility functions

--- Flip any easing function, making it go from 1 to 0
-- Example use:
-- ```lua
-- ease {0, 20, flip(outQuad), 50, 'modname'}
-- ```
M.flip = setmetatable({}, {
	__call = function(self, fn)
		self[fn] = self[fn] or function(x) return 1 - fn(x) end
		return self[fn]
	end
})

-- Mix two easing functions together into a new ease
-- the new ease starts by acting like the first argument, and then ends like the second argument
-- Example: ease {0, 20, blendease(inQuad, outQuad), 100, 'modname'}
M.blendease = setmetatable({}, {
	__index = function(self, key)
		self[key] = {}
		return self[key]
	end,
	__call = function(self, fn1, fn2)
		if not self[fn1][fn2] then
			local transient1 = fn1(1) <= 0.5
			local transient2 = fn2(1) <= 0.5
			if transient1 and not transient2 then
				error('blendease: the first argument is a transient ease, but the second argument doesn\'t match')
			end
			if transient2 and not transient1 then
				error('blendease: the second argument is a transient ease, but the first argument doesn\'t match')
			end
			self[fn1][fn2] = function(x)
				local mixFactor = 3*x^2-2*x^3
				return (1 - mixFactor) * fn1(x) + mixFactor * fn2(x)
			end
		end
		return self[fn1][fn2]
	end
})

local function param1cache(self, param1)
	self.cache[param1] = self.cache[param1] or function(x)
		return self.fn(x, param1)
	end
	return self.cache[param1]
end

local param1mt = {
	__call = function(self, x, param1)
		return self.fn(x, param1 or self.dp1)
	end,
	__index = {
		param = param1cache,
		params = param1cache,
	}
}

-- Declare an easing function taking one custom parameter
local function with1param(fn, defaultparam1)
	return setmetatable({
		fn = fn,
		dp1 = defaultparam1,
		cache = {},
	}, param1mt)
end
M.with1param = with1param

local function param2cache(self, param1, param2)
	self.cache[param1] = self.cache[param1] or {}
	self.cache[param1][param2] = self.cache[param1][param2] or function(x)
		return self.fn(x, param1, param2)
	end
	return self.cache[param1][param2]
end

local param2mt = {
	__call = function(self, x, param1, param2)
		return self.fn(x, param1 or self.dp1, param2 or self.dp2)
	end,
	__index = {
		param=param2cache,
		params=param2cache,
	}
}

-- Declare an easing function taking two custom parameters
local function with2params(fn, defaultparam1, defaultparam2)
	return setmetatable({
		fn = fn,
		dp1 = defaultparam1,
		dp2 = defaultparam2,
		cache = {},
	}, param2mt)
end
M.with2params = with2params

-- ===================================================================== --

-- Easing functions

function M.bounce(t) return 4 * t * (1 - t) end
local function tri(t) return 1 - abs(2 * t - 1) end
M.tri = tri
function M.bell(t) return inOutQuint(M.tri(t)) end
local function pop(t) return 3.5 * (1 - t) * (1 - t) * sqrt(t) end
M.pop = pop
local function tap(t) return 3.5 * t * t * sqrt(1 - t) end
M.tap = tap
function M.pulse(t) return t < .5 and tap(t * 2) or -pop(t * 2 - 1) end

function M.spike(t) return exp(-10 * abs(2 * t - 1)) end
function M.inverse(t) return t * t * (1 - t) * (1 - t) / (0.5 - t) end

local function popElasticInternal(t, damp, count)
	return (1000 ^ -(t ^ damp) - 0.001) * sin(count * pi * t)
end

local function tapElasticInternal(t, damp, count)
	return (1000 ^ -((1 - t) ^ damp) - 0.001) * sin(count * pi * (1 - t))
end

local function pulseElasticInternal(t, damp, count)
	if t < .5 then
		return tapElasticInternal(t * 2, damp, count)
	else
		return -popElasticInternal(t * 2 - 1, damp, count)
	end
end

M.popElastic = with2params(popElasticInternal, 1.4, 6)
M.tapElastic = with2params(tapElasticInternal, 1.4, 6)
M.pulseElastic = with2params(pulseElasticInternal, 1.4, 6)

M.impulse = with1param(function(t, damp)
	t = t ^ damp
	return t * (1000 ^ -t - 0.001) * 18.6
end, 0.9)

function M.instant() return 1 end
function M.linear(t) return t end
function M.inQuad(t) return t * t end
function M.outQuad(t) return -t * (t - 2) end
function M.inOutQuad(t)
	t = t * 2
	if t < 1 then
		return 0.5 * t ^ 2
	else
		return 1 - 0.5 * (2 - t) ^ 2
	end
end
function M.outInQuad(t)
	t = t * 2
	if t < 1 then
		return 0.5 - 0.5 * (1 - t) ^ 2
	else
		return 0.5 + 0.5 * (t - 1) ^ 2
	end
end
function M.inCubic(t) return t * t * t end
function M.outCubic(t) return 1 - (1 - t) ^ 3 end
function M.inOutCubic(t)
	t = t * 2
	if t < 1 then
		return 0.5 * t ^ 3
	else
		return 1 - 0.5 * (2 - t) ^ 3
	end
end
function M.outInCubic(t)
	t = t * 2
	if t < 1 then
		return 0.5 - 0.5 * (1 - t) ^ 3
	else
		return 0.5 + 0.5 * (t - 1) ^ 3
	end
end
function M.inQuart(t) return t * t * t * t end
function M.outQuart(t) return 1 - (1 - t) ^ 4 end
function M.inOutQuart(t)
	t = t * 2
	if t < 1 then
		return 0.5 * t ^ 4
	else
		return 1 - 0.5 * (2 - t) ^ 4
	end
end
function M.outInQuart(t)
	t = t * 2
	if t < 1 then
		return 0.5 - 0.5 * (1 - t) ^ 4
	else
		return 0.5 + 0.5 * (t - 1) ^ 4
	end
end
function M.inQuint(t) return t ^ 5 end
function M.outQuint(t) return 1 - (1 - t) ^ 5 end
function M.inOutQuint(t)
	t = t * 2
	if t < 1 then
		return 0.5 * t ^ 5
	else
		return 1 - 0.5 * (2 - t) ^ 5
	end
end
function M.outInQuint(t)
	t = t * 2
	if t < 1 then
		return 0.5 - 0.5 * (1 - t) ^ 5
	else
		return 0.5 + 0.5 * (t - 1) ^ 5
	end
end
local function inExpo(t) return 1000 ^ (t - 1) - 0.001 end
M.inExpo = inExpo
local function outExpo(t) return 1.001 - 1000 ^ -t end
M.outExpo = outExpo
function M.inOutExpo(t)
	t = t * 2
	if t < 1 then
		return 0.5 * 1000 ^ (t - 1) - 0.0005
	else
		return 1.0005 - 0.5 * 1000 ^ (1 - t)
	end
end
function M.outInExpo(t)
	if t < 0.5 then
		return outExpo(t * 2) * 0.5
	else
		return inExpo(t * 2 - 1) * 0.5 + 0.5
	end
end
local function inCirc(t) return 1 - sqrt(1 - t * t) end
M.inCirc = inCirc
local function outCirc(t) return sqrt(-t * t + 2 * t) end
M.outCirc = outCirc
function M.inOutCirc(t)
	t = t * 2
	if t < 1 then
		return 0.5 - 0.5 * sqrt(1 - t * t)
	else
		t = t - 2
		return 0.5 + 0.5 * sqrt(1 - t * t)
	end
end
function M.outInCirc(t)
	if t < 0.5 then
		return outCirc(t * 2) * 0.5
	else
		return inCirc(t * 2 - 1) * 0.5 + 0.5
	end
end
local function outBounce(t)
	if t < 1 / 2.75 then
		return 7.5625 * t * t
	elseif t < 2 / 2.75 then
		t = t - 1.5 / 2.75
		return 7.5625 * t * t + 0.75
	elseif t < 2.5 / 2.75 then
		t = t - 2.25 / 2.75
		return 7.5625 * t * t + 0.9375
	else
		t = t - 2.625 / 2.75
		return 7.5625 * t * t + 0.984375
	end
end
M.outBounce = outBounce
local function inBounce(t) return 1 - outBounce(1 - t) end
M.inBounce = inBounce
function M.inOutBounce(t)
	if t < 0.5 then
		return inBounce(t * 2) * 0.5
	else
		return outBounce(t * 2 - 1) * 0.5 + 0.5
	end
end
function M.outInBounce(t)
	if t < 0.5 then
		return outBounce(t * 2) * 0.5
	else
		return inBounce(t * 2 - 1) * 0.5 + 0.5
	end
end
local function inSine(x) return 1 - cos(x * (pi * 0.5)) end
M.inSine = inSine
local function outSine(x) return sin(x * (pi * 0.5)) end
M.outSine = outSine
function M.inOutSine(x)
	return 0.5 - 0.5 * cos(x * pi)
end
function M.outInSine(t)
	if t < 0.5 then
		return outSine(t * 2) * 0.5
	else
		return inSine(t * 2 - 1) * 0.5 + 0.5
	end
end

local function outElasticInternal(t, a, p)
	return a * pow(2, -10 * t) * sin((t - p / (2 * pi) * asin(1/a)) * 2 * pi / p) + 1
end
local function inElasticInternal(t, a, p)
	return 1 - outElasticInternal(1 - t, a, p)
end
local function inOutElasticInternal(t, a, p)
	return t < 0.5
		and  0.5 * inElasticInternal(t * 2, a, p)
		or  0.5 + 0.5 * outElasticInternal(t * 2 - 1, a, p)
end
local function outInElasticInternal(t, a, p)
	return t < 0.5
		and  0.5 * outElasticInternal(t * 2, a, p)
		or  0.5 + 0.5 * inElasticInternal(t * 2 - 1, a, p)
end

M.inElastic = with2params(inElasticInternal, 1, 0.3)
M.outElastic = with2params(outElasticInternal, 1, 0.3)
M.inOutElastic = with2params(inOutElasticInternal, 1, 0.3)
M.outInElastic = with2params(outInElasticInternal, 1, 0.3)

local function inBackInternal(t, a) return t * t * (a * t + t - a) end
local function outBackInternal(t, a) t = t - 1 return t * t * ((a + 1) * t + a) + 1 end
local function inOutBackInternal(t, a)
	return t < 0.5
		and  0.5 * inBackInternal(t * 2, a)
		or  0.5 + 0.5 * outBackInternal(t * 2 - 1, a)
end
local function outInBackInternal(t, a)
	return t < 0.5
		and  0.5 * outBackInternal(t * 2, a)
		or  0.5 + 0.5 * inBackInternal(t * 2 - 1, a)
end

M.inBack = with1param(inBackInternal, 1.70158)
M.outBack = with1param(outBackInternal, 1.70158)
M.inOutBack = with1param(inOutBackInternal, 1.70158)
M.outInBack = with1param(outInBackInternal, 1.70158)

return M
