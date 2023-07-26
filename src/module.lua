local Queue = {}
Queue.RunningQueues = {}
Queue.__index = Queue.RunningQueues

local Cache = {}

function Queue.new(Name : string, RefreshRate : number, MassRun : boolean)
	assert(type(Name) == "string", string.format("bad argument #1 to Queue.new (string expected, got %s)", type(Name)))
	assert(type(RefreshRate) == "number", string.format("bad argument #2 for Queue.new (number expected, got %s", type(RefreshRate)))
	assert(type(MassRun) == "boolean", string.format("bad argument #3 for Queue.new (boolean expected, got %s)", type(MassRun)))
	
	local self = {
		Name = Name,
		Queue = {},
		RefreshRate = RefreshRate,
		MassRun = MassRun,
		Paused = false
	}
	
	local Metatable = (setmetatable(self, Queue))
	table.insert(Cache, Metatable)
	
	return Metatable
end

function Queue.Fetch(Name : string)
	assert(type(Name) == "string", string.format("bad argument #1 to Queue.Fetch (string expected, got %s)", type(Name)))
	
	for Key, Value in ipairs(Cache) do
		if Value.Name == Name then
			return Value
		end
	end
	
	return {}
end

function Queue.RunningQueues:Add(Function : any)
	assert(type(Function) == "function", string.format("bad argument #1 to Queue:Add (function expected, got %s)", type(Function)))
	
	return table.insert(self.Queue, Function)
end

function Queue.RunningQueues:Run()
	coroutine.wrap(function()
		while task.wait(self.RefreshRate) do
			if not self.Paused and #self.Queue > 0 then
				if self.MassRun then
					for Key, Value in next, self.Queue do
						--pcall(Value)
						Value()
						
						self.Queue[Key] = nil

						repeat
							task.wait()
						until self.Queue[Key] == nil
					end
				else
					local Key, Value = next(self.Queue)
					--pcall(Value)
					Value()
					self.Queue[Key] = nil
					
					repeat
						task.wait()
					until self.Queue[Key] == nil
				end
			end
		end
	end)()
end

function Queue.RunningQueues:Clear(RunFunctions : boolean)
	assert(type(RunFunctions) == "boolean", string.format("bad argument #1 to Queue:Clear (boolean expected, got %s)", type(RunFunctions)))
	
	if RunFunctions then
		for Key, Value in next, self.Queue do
			--pcall(Value)
			Value()
			
			self.Queue[Key] = nil
		end
	end
	
	self.Queue = {}
end

function Queue.RunningQueues:Pause()
	self.Paused = true
end

function Queue.RunningQueues:Resume()
	self.Paused = false
end

return Queue