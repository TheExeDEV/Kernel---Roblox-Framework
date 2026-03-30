--maded by TREMNOR_TTR

--!strict

export type Connection = {
	Disconnect: (self: Connection) -> (),
	Connected: boolean,
}
export type Signal<T...> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Wait: (self: Signal<T...>) -> T...,
	Fire: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
	Destroy: (self: Signal<T...>) -> (),
}

export type Promise<T...> = {
	andThen: (self: Promise<T...>, successHandler: (T...) -> ...any, failureHandler: ((any) -> ...any)?) -> Promise<...any>,
	catch: (self: Promise<T...>, failureHandler: (any) -> ...any) -> Promise<T...>,
	finally: (self: Promise<T...>, finallyHandler: (status: string) -> ...any) -> Promise<T...>,
	cancel: (self: Promise<T...>) -> (),
	await: (self: Promise<T...>) -> (boolean, T...),
	expect: (self: Promise<T...>) -> T...,
}
export type RemoteSignalServer = {
	_remote: RemoteEvent,
	_isRemoteSignal: boolean?,
	Fire: (self: RemoteSignalServer, player: Player, ...any) -> (),
	FireAll: (self: RemoteSignalServer, ...any) -> (),
	FireExcept: (self: RemoteSignalServer, excludePlayer: Player, ...any) -> (),
	FireList: (self: RemoteSignalServer, playerList: { Player }, ...any) -> (),
	FireFilter: (self: RemoteSignalServer, filterFunc: (player: Player) -> boolean, ...any) -> (),
	Connect: (self: RemoteSignalServer, callback: (player: Player, ...any) -> ()) -> Connection,
}
export type RemoteSignalClient = {
	Connect: (self: RemoteSignalClient, callback: (...any) -> ()) -> Connection,
	Once: (self: RemoteSignalClient, callback: (...any) -> ()) -> Connection,
	Wait: (self: RemoteSignalClient) -> ...any,
	Fire: (self: RemoteSignalClient, ...any) -> (),
}
export type RemoteSignalMarker = {
	_isRemoteSignal: true,
}
export type MiddlewareContext = {
	Player: Player,
	Service: string,
	Method: string,
}
export type MiddlewareFunc = (context: MiddlewareContext, ...any) -> (boolean, string?)
export type ValidatorFunc = (...any) -> (boolean, string?)
export type RateLimiter = {
	CheckRate: (self: RateLimiter, player: Player) -> boolean,
}
export type ServiceClient = {
	_service: any,
	[string]: ((...any) -> ...any) | RemoteSignalServer | RemoteSignalMarker,
}
export type ServiceConfig = {
	Name: string,
	Client: { [string]: any }?,
	KernelInit: ((self: any) -> ())?,
	KernelStart: ((self: any) -> ())?,
	[string]: any,
}
export type Service = {
	Name: string,
	Client: ServiceClient,
	KernelInit: ((self: Service) -> ())?,
	KernelStart: ((self: Service) -> ())?,
	[string]: any,
}
export type ControllerConfig = {
	Name: string,
	KernelInit: ((self: any) -> ())?,
	KernelStart: ((self: any) -> ())?,
	[string]: any,
}
export type Controller = {
	Name: string,
	KernelInit: ((self: Controller) -> ())?,
	KernelStart: ((self: Controller) -> ())?,
	[string]: any,
}
export type ServiceProxy = {
	[string]: ((...any) -> ...any) | RemoteSignalClient,
}
export type NetworkModule = {
	RemoteSignal: () -> RemoteSignalMarker,
	SetRateLimit: (serviceName: string, methodName: string, rate: number) -> (),
	SetValidator: (serviceName: string, methodName: string, valFunc: ValidatorFunc) -> (),
	SetupServer: (services: { [string]: Service }, middlewares: { MiddlewareFunc }) -> (),
	SetupClient: () -> (),
	getService_proxy: (serviceName: string) -> ServiceProxy,
}
export type KernelServer = {
	CreateService: (config: ServiceConfig) -> Service,
	GetService: (name: string) -> Service,
	AddMiddleware: (fn: MiddlewareFunc) -> (),
	SetServiceFolder: (folder: Instance) -> nil,
	Start: () -> boolean,

	Signal: any,
	Promise: any,
	t: any,
	Network: NetworkModule,
	RemoteSignal: () -> RemoteSignalMarker,
}
export type KernelClient = {
	CreateController: (config: ControllerConfig) -> Controller,
	GetController: (name: string) -> Controller,
	GetService: (name: string) -> ServiceProxy,
	SetControllerFolder: (folder: Instance) -> nil,
	Start: () -> boolean,

	Signal: any,
	Promise: any,
	t: any,
}

return {}
