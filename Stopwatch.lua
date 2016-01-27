local function sysTimeSec()
	return system.getTimer() / 1000
end

local Stopwatch = 
{
	startTime = 0,
	storedTime = 0,

	isRunning = false
}
Stopwatch.__index = Stopwatch

--call mechanism!
setmetatable(Stopwatch, {
	__call = function(...)
		return Stopwatch.new(...)
	end
})

function Stopwatch:new()
	local o = setmetatable( {}, Stopwatch )
	return o
end

function Stopwatch:getTimeSeconds()
	if self.isRunning then
		return self.storedTime + (sysTimeSec() - self.startTime)
	else
		return self.storedTime
	end
end

function Stopwatch:getFormattedTime()
	local timeSec = self:getTimeSeconds()
	local minutes = math.floor( timeSec / 60 )
	local seconds = math.floor( timeSec % 60 )
	local millisecs = timeSec % 1.

	local mSecStr = "0"
	if millisecs ~= 0 then
		mSecStr = string.sub(""..millisecs, 3)
	end

	if #mSecStr > 3 then
		mSecStr = string.sub( mSecStr, 1, 3 )
	end

	return ""..minutes.." : "..seconds.." . "..mSecStr
end

function Stopwatch:start()
	if not self.isRunning then
		self.startTime = sysTimeSec()
		self.isRunning = true
	end
end

function Stopwatch:stop()
	if self.isRunning then
		self.storedTime = self.storedTime + (sysTimeSec() - self.startTime)
		self.isRunning = false
		self.startTime = 0
	end
end

function Stopwatch:reset()
	self.startTime = 0
	self.storedTime = 0
	self.isRunning = false
end

return Stopwatch