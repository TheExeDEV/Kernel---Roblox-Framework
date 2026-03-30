--maded by TREMNOR_TTR

--!strict
--!optimize 2

local Client = {} :: Types.KernelClient

local Types = require(script.Parent.Libs.Types)
local Network: Types.NetworkModule = require(script.Parent.Libs.Network)

local controllers: { [string]: Types.Controller } = {}
local started: boolean = false

local clientFolder: Instance? = nil

function Client.CreateController(config: Types.ControllerConfig): Types.Controller
	assert(not started, "Kernel cannot create controller after :Start()")
	assert(config.Name, "Kernel controller needs a Name")
	assert(not controllers[config.Name], "Kernel controller "..config.Name.." alr exists")

	local controller: Types.Controller = {} :: Types.Controller
	for k, v in config do
		(controller :: any)[k] = v
	end

	controllers[config.Name] = controller
	return controller
end

function Client.GetController(name: string): Types.Controller
	local controller = controllers[name]
	assert(controller, "Kernel controller "..name.." not found")
	return controller
end

function Client.GetService(name: string): Types.ServiceProxy
	return Network.getService_proxy(name)
end

function Client.SetControllerFolder(folder: Instance): nil
	if folder and folder ~= nil then
		clientFolder = folder
	end
	return nil
end

function Client.Start(): boolean
	assert(clientFolder, "Kernel needs a client folder")
	assert(not started, "Kernel already started")

	for k, v in ipairs(clientFolder:GetChildren()) do
		if v:IsA("ModuleScript") then
			local succ, err = pcall(require, v)
			if not succ then
				warn("Kernel controller fail to load:", v:GetFullName(), err)
			end
		end
	end

	started = true
	Network.SetupClient()

	for k, cont in controllers do
		if cont.KernelInit then
			local succ, err = pcall(cont.KernelInit, cont)
			if not succ then
				warn("Kernel KernelInit error in "..cont.Name..": "..tostring(err))
			end
		end
	end

	task.defer(function()
		for k, cont in controllers do
			if cont.KernelStart then
				task.spawn(function()
					local succ, err = pcall(cont.KernelStart, cont)
					if not succ then
						warn("Kernel KernelStart error in "..cont.Name..": "..tostring(err))
					end
				end)
			end
		end
	end)

	print("[Kernel] Client started!")
	return true
end

Client.Promise = require(script.Parent.Libs.Promise)

return Client
