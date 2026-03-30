# Kernel-Roblox-Framework
# How To Use
- Server Side Runtime
```lua
local Kernel = require(game:GetService("ReplicatedStorage").Kernel)

Kernel.SetServiceFolder(script.Services)

Kernel.AddMiddleware(function(context, ...)
	print(string.format("[middleware] %s: %s.%s", context.Player.Name, context.Service, context.Method))
	return true
end)

Kernel.Start()
```

- Client Side Runtime
```lua
local Kernel = require(game:GetService("ReplicatedStorage").Kernel)

Kernel.SetControllerFolder(script.Controllers)
Kernel.Start()
```

# Contributors
- [Promise by evaera](https://github.com/evaera/roblox-lua-promise)
- [RateLimiter by MadStudioRoblox](https://github.com/MadStudioRoblox/ReplicaService/blob/master/src/ReplicatedStorage/RateLimiter.lua)
  
- [The idea was taken from the Knit Framework](https://github.com/Sleitnick/Knit)
