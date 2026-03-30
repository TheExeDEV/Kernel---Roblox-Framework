## Kernel Framework

- GithubLink  - [link](https://github.com/TheExeDEV/Kernel-Roblox-Framework/)
- RobloxModel - [link](https://create.roblox.com/store/asset/93082908591460)

version - 1.0.0
# How To Use
- Server Side Runtime
```lua
--Server Runtime
local Kernel = require(game:GetService("ReplicatedStorage").Kernel)

Kernel.SetServiceFolder(script.Services) --where will the services be taken from

Kernel.AddMiddleware(function(context, ...)
	print(string.format("[middleware] %s: %s.%s", context.Player.Name, context.Service, context.Method))
	return true
end)

Kernel.Start()
```

- Client Side Runtime
```lua
--Client Runtime
local Kernel = require(game:GetService("ReplicatedStorage").Kernel)

Kernel.SetControllerFolder(script.Controllers) --where will the controllers be taken from
Kernel.Start()
```
- Service & Controller Sides
```lua
--Test Service
local Kernel = require(game.ReplicatedStorage.Kernel)

local TestService = Kernel.CreateService({
	Name = "TestService",
	Client = {
		ping = Kernel.RemoteSignal(),

		hi = function(self, player: Player)
			return "hello: "..player.Name
		end,
	},
})

function TestService:KernelInit()
	print("im first started in server")
	
	self.Client.ping:Connect(function(player)
		print("ping", player.Name)
		self.Client.ping:Fire(player, "pong!")
	end)
end

function TestService:KernelStart()
	print("im second started")
end

return TestService
```

```lua
--Test Controller
local Kernel = require(game.ReplicatedStorage.Kernel)

local TestController = Kernel.CreateController({
	Name = "TestController",
})

function TestController:KernelInit()
	print("im first started in client")
	local TestService = Kernel.GetService("TestService")

	TestService.ping:Connect(function(msg)
		print("msg:", msg)
	end)
end

function TestController:KernelStart()
	print("im second started in client")
	local TestService = Kernel.GetService("TestService")
	print("Test controller server said:", TestService:hi())

	TestService.ping:Fire()
end

return TestController
```
# why is it better than the Knit Framework:
- Knit is an archived Framework
- Knit has poor networking
- Knit is quite old and needs to be updated

# Contributors
- [Promise by evaera](https://github.com/evaera/roblox-lua-promise)
- [RateLimiter by MadStudioRoblox](https://github.com/MadStudioRoblox/ReplicaService/blob/master/src/ReplicatedStorage/RateLimiter.lua)
  
- [The idea was taken from the Knit Framework](https://github.com/Sleitnick/Knit)
###### - my first job
