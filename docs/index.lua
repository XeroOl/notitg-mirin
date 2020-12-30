local t = {}
for k, v in pairs(xero) do
	table.insert(t, {k, v})
end
table.sort(t, function(a, b) return a[1] < b[1] end)
for _, v in pairs(t) do
	print(t[1], t[2])
end
