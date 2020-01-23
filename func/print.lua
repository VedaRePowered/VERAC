local function rp(value, tabs, quotedStrings, noTabs)
	if not tabs then tabs = 0 end
	if not noTabs then
		for i = 1, tabs do
			io.write("\t")
		end
	end
	if type(value) == "table" then
		local gotInIpairs = {}
		local first = true
		io.write("{")
		for i, v in ipairs(value) do
			gotInIpairs[i] = true
			if not first then
				io.write(",")
			end
			io.write("\n")
			rp(v, tabs+1, true)
			first = false
		end
		for k, v in pairs(value) do
			if not gotInIpairs[k] then
				if not first then
					io.write(",")
				end
				io.write("\n")
				rp(k, tabs+1, true)
				io.write(" = ")
				rp(v, tabs+1, true, true)
			end
			first = false
		end
		if not first then
			io.write("\n")
			for i = 1, tabs do
				io.write("\t")
			end
		end
		io.write("}")
	elseif quotedStrings and type(value) == "string" then
		io.write("`", value:gsub("[\x01-\x1f\x7f-\xff]", function(c)return string.format("\\x%02X", string.byte(c))end), "\'")
	else
		io.write(tostring(value))
	end
end

return function(...) -- override default print function
	for _, v in ipairs{...} do
		rp(v)
	end
	io.write("\n")
end
