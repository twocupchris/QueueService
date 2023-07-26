local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QueueService = require(ReplicatedStorage:FindFirstChild("QueueService"))
local MyQueue = QueueService.New("MyQueue", 5, false)

MyQueue:Add(function()
	print("New Item Added to Queue!")
end)
MyQueue:Run()

local MyQueue = QueueService.Fetch("MyQueue")
MyQueue:Add(function()
    print("New Item Added To Queue!")
end)
MyQueue:Run()

MyQueue:Clear(false) --bool argument determines whether all functions in queue should run at once or clear

MyQueue:Pause()
MyQueue:Resume()