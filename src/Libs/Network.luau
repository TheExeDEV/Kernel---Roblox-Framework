--maded by TREMNOR_TTR

--!strict
--!optimize 2

local Network = {} :: Types.NetworkModule

local Types = require(script.Parent.Types)

local run_service = game:GetService("RunService")
local replicated = game:GetService("ReplicatedStorage")
local player_service = game:GetService("Players")

local isServer: boolean = run_service:IsServer()
local folder_name: string = "__kernelStorage"

local promise: any
local rate_limiter: any

if isServer then
	rate_limiter = require(script.Parent.RateLimiter)
end

function Network.RemoteSignal(): Types.RemoteSignalMarker
	return {
		_isRemoteSignal = true,
	}
end

local rate_limiters: { [string]: Types.RateLimiter } = {}

function Network.SetRateLimit(serviceName: string, methodName: string, rate: number)
	rate_limiters[serviceName.."."..methodName] = rate_limiter.NewRateLimiter(rate)
end

local function check_rate(player: Player, serviceName: string, methodName: string): boolean
	local limiter = rate_limiters[serviceName.."."..methodName]
	if not limiter then
		return rate_limiter.Default:CheckRate(player)
	end
	return limiter:CheckRate(player)
end

local val: { [string]: Types.ValidatorFunc } = {}

function Network.SetValidator(serviceName: string, methodName: string, valFunc: Types.ValidatorFunc)
	val[serviceName.."."..methodName] = valFunc
end

local function runVal(serviceName: string, methodName: string, ...: any): (boolean, string?)
	local func = val[serviceName.."."..methodName]
	if not func then
		return true, nil
	end
	local succ, err = func(...)
	if succ == false then
		return false, err or "Val Fail"
	end
	return true, nil
end

function Network.SetupServer(services: { [string]: Types.Service }, middlewares: { Types.MiddlewareFunc })
	local f: Folder = Instance.new("Folder")
	f.Name = folder_name
	f.Parent = replicated

	for serviceName: string, serv: Types.Service in pairs(services) do
		local client: Types.ServiceClient = serv.Client
		if not client then
			continue
		end

		local sf: Folder = Instance.new("Folder")
		sf.Name = serviceName
		sf.Parent = f

		for memberName: string, mem: any in pairs(client) do
			if memberName == "_service" then
				continue
			end

			if type(mem) == "function" then
				local rem: RemoteFunction = Instance.new("RemoteFunction")
				rem.Name = "RF/"..memberName
				rem.Parent = sf

				rem.OnServerInvoke = function(player: Player, ...: any): ...any
					if not check_rate(player, serviceName, memberName) then
						return nil, "rate limited"
					end

					local vali: boolean, valerr: string? = runVal(serviceName, memberName, ...)
					if not vali then
						return nil, valerr
					end

					if middlewares then
						for k, mw: Types.MiddlewareFunc in ipairs(middlewares) do
							local succ: boolean, merr: string? = mw({
								Player = player,
								Service = serviceName,
								Method = memberName,
							}, ...)
							if not succ then
								return nil, merr or "MIDDLEWARE_BLOCK"
							end
						end
					end

					local succ: boolean, r1: any, r2: any, r3: any, r4: any = pcall(mem, client, player, ...)
					if not succ then
						warn(string.format("Kernel err %s.Client.%s: %s", serviceName, memberName, tostring(r1)))
						return nil, "INTERNAL_ERR"
					end

					return r1, r2, r3, r4
				end

			elseif type(mem) == "table" and (mem :: any)._isRemoteSignal then
				local r: RemoteEvent = Instance.new("RemoteEvent")
				r.Name = "RE/"..memberName
				r.Parent = sf

				local wrapp: Types.RemoteSignalServer = {
					_remote = r,
				} :: Types.RemoteSignalServer

				function wrapp:Fire(player: Player, ...: any)
					r:FireClient(player, ...)
				end

				function wrapp:FireAll(...: any)
					r:FireAllClients(...)
				end

				function wrapp:FireExcept(excludePlayer: Player, ...: any)
					for k, player: Player in ipairs(player_service:GetPlayers()) do
						if player ~= excludePlayer then
							r:FireClient(player, ...)
						end
					end
				end

				function wrapp:FireList(playerList: { Player }, ...: any)
					for k, player: Player in ipairs(playerList) do
						r:FireClient(player, ...)
					end
				end

				function wrapp:FireFilter(filterFunc: (player: Player) -> boolean, ...: any)
					for k, player: Player in ipairs(player_service:GetPlayers()) do
						if filterFunc(player) then
							r:FireClient(player, ...)
						end
					end
				end

				function wrapp:Connect(cb: (player: Player, ...any) -> ()): Types.Connection
					return r.OnServerEvent:Connect(function(player: Player, ...: any)
						if not check_rate(player, serviceName, memberName) then
							return
						end
						local vali: boolean = runVal(serviceName, memberName, ...)
						if not vali then
							return
						end
						cb(player, ...)
					end)
				end

				client[memberName] = wrapp :: any
			end
		end
	end

	local ready: BoolValue = Instance.new("BoolValue")
	ready.Name = "__ready"
	ready.Value = true
	ready.Parent = f
end

local service_proxy: { [string]: Types.ServiceProxy } = {}
local network_ready: boolean = false

function Network.SetupClient()
	promise = require(script.Parent.Promise)

	local folder: Instance? = replicated:WaitForChild(folder_name, 30)
	assert(folder, "Kernel network folder not found")
	folder:WaitForChild("__ready", 30)
	network_ready = true
end

function Network.getService_proxy(serviceName: string): Types.ServiceProxy
	if service_proxy[serviceName] then
		return service_proxy[serviceName]
	end

	while not network_ready do
		task.wait()
	end

	local f: Instance = (replicated :: any)[folder_name]
	local sf: Instance? = f:WaitForChild(serviceName, 10)
	assert(sf, "Kernel service folder "..serviceName.." not found")

	local proxy: Types.ServiceProxy = {} :: Types.ServiceProxy
	local cache: { [string]: any } = {}

	setmetatable(proxy :: any, {
		__index = function(_: any, k: string): any
			if cache[k] then
				return cache[k]
			end

			local r: Instance? = sf:FindFirstChild("RE/"..k)
			if r then
				local signProxy: Types.RemoteSignalClient = {} :: Types.RemoteSignalClient

				function signProxy:Connect(cb: (...any) -> ()): Types.Connection
					return (r :: RemoteEvent).OnClientEvent:Connect(cb)
				end

				function signProxy:Once(cb: (...any) -> ()): Types.Connection
					local con: RBXScriptConnection
					con = (r :: RemoteEvent).OnClientEvent:Connect(function(...: any)
						con:Disconnect()
						cb(...)
					end)
					return con :: any
				end

				function signProxy:Wait(): ...any
					return (r :: RemoteEvent).OnClientEvent:Wait()
				end

				function signProxy:Fire(...: any)
					(r :: RemoteEvent):FireServer(...)
				end

				cache[k] = signProxy
				return signProxy
			end

			local promised: boolean = false
			local bName: string = k

			if string.sub(k, -7) == "Promise" then
				promised = true
				bName = string.sub(k, 1, -8)
			end

			local rf: Instance? = sf:FindFirstChild("RF/"..bName)
			if rf then
				if promised then
					local promiseFunc = function(_: any, ...: any): Types.Promise<...any>
						local args = {...}
						return promise.new(function(resolve: (...any) -> (), reject: (...any) -> ())
							local succ: boolean, r1: any, r2: any, r3: any, r4: any = pcall(
								(rf :: RemoteFunction).InvokeServer, rf, table.unpack(args)
							)
							if not succ then
								reject(r1)
								return
							end
							if r1 == nil and type(r2) == "string" then
								reject(r2)
								return
							end
							resolve(r1, r2, r3, r4)
						end)
					end
					cache[k] = promiseFunc
					return promiseFunc
				else
					local meth = function(_: any, ...: any): ...any
						return (rf :: RemoteFunction):InvokeServer(...)
					end
					cache[k] = meth
					return meth
				end
			end

			error("Kernel "..k.." does not exist in service: "..serviceName)
		end,
	})

	service_proxy[serviceName] = proxy
	return proxy
end

return Network
