vim.pack.add({ "https://github.com/williamboman/mason.nvim" })

require("mason").setup()

local M = {}

-- Install any missing mason packages, then call on_ready (on the main loop)
function M.ensure_installed(names, on_ready)
	local registry = require("mason-registry")
	registry.refresh(vim.schedule_wrap(function()
		local pending = 1
		local function done()
			pending = pending - 1
			if pending == 0 and on_ready then
				vim.schedule(on_ready)
			end
		end

		for _, name in ipairs(names) do
			local pkg = registry.get_package(name)
			if not pkg:is_installed() and not pkg:is_installing() then
				pending = pending + 1
				vim.notify("mason: installing " .. name)
				pkg:install({}, function(ok, err)
					if not ok then
						vim.schedule(function()
							vim.notify("mason: failed to install " .. name .. ": " .. tostring(err), vim.log.levels.ERROR)
						end)
					end
					done()
				end)
			end
		end
		done()
	end))
end

return M
