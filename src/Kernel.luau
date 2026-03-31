--maded by TREMNOR_TTR

local types = require("@self/Libs/Types")
local run_service = game:GetService("RunService")

if run_service:IsClient() then
	script.Server:Destroy()
	return require(script.Client) :: types.KernelClient
elseif run_service:IsServer() then
	local kernel = require(script.Server)
	kernel.Client = require(script.Client)
	return kernel :: types.KernelServer
end
