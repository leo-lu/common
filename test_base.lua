local _M = { _VERSION = 0.1 }

_M.new = function(self, name)
	local obj = { _name = name }
	setmetatable(obj, { __index = _M })
	return obj
end
 
_M.run = function(self)
	print("test module name: " .. self._name)
	for k, v in pairs(self) do
		if "function" == type(v) then
			local rst, err = pcall(v, nil)
			if rst then
				print(k, " PASS")
			else
				print(k, err)
			end
		end
	end
end

return _M