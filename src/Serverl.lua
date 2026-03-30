--maded by TREMNOR_TTR

--!strict
--!optimize 2

local Server = {} :: Types.KernelServer

local Types = require(script.Parent.Libs.Types)
local Network: Types.NetworkModule = require(script.Parent.Libs.Network)

local services: { [string]: Types.Service } = {}
local middlewares: { Types.MiddlewareFunc } = {}
local started: boolean = false

local serverFolder: Instance? = nil

function Server.CreateService(config: Types.ServiceConfig): Types.Service
	assert(not started, "Kernel cannot create service after :Start()")
	assert(config.Name, "Kernel service needs a name")
	assert(not services[config.Name], "Kernel service "..config.Name.." alr exists")

	local service: Types.Service = {} :: Types.Service
	for k, v in config do
		(service :: any)[k] = v
	end

	if service.Client then
		service.Client._service = service
	else
		service.Client = { 
			_service = service
		}
	end

	services[config.Name] = service
	return service
end

function Server.GetService(name: string): Types.Service
	local service = services[name]
	assert(service, "Kernel Service "..name.." not found")
	return service
end

function Server.AddMiddleware(fn: Types.MiddlewareFunc)
	assert(not started, "Kernel cannot add middleware after :Start()")
	table.insert(middlewares, fn)
end

function Server.SetServiceFolder(folder: Instance): nil
	if folder and folder ~= nil then
		serverFolder = folder
	end
	return nil
end

function Server.Start(): boolean
	assert(serverFolder, "Kernel needs a server folder")
	assert(not started, "Kernel already started")

	for k, v in ipairs(serverFolder:GetChildren()) do
		if v:IsA("ModuleScript") then
			local succ, err = pcall(require, v)
			if not succ then
				warn("Kernel service fail to load:", v:GetFullName(), err)
			end
		end
	end

	started = true
	Network.SetupServer(services, middlewares)

	for k, serv in services do
		if serv.KernelInit then
			local succ, err = pcall(serv.KernelInit, serv)
			if not succ then
				warn("Kernel KernelInit error in "..serv.Name..": "..tostring(err))
			end
		end
	end

	task.defer(function()
		for k, serv in services do
			if serv.KernelStart then
				task.spawn(function()
					local succ, err = pcall(serv.KernelStart, serv)
					if not succ then
						warn("Kernel KernelStart error in "..serv.Name..": "..tostring(err))
					end
				end)
			end
		end
	end)

	print("[Kernel] Server started!")
	return true
end

Server.Promise = require(script.Parent.Libs.Promise)
Server.Network = Network
Server.RemoteSignal = Network.RemoteSignal

return Server
