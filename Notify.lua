local network = require "network"
local json = require "json"

local notifyDataFile = system.pathForFile("notifyInfo.json", system.DocumentsDirectory)

local function log(str)
	print("NOTIFY: "..str)
end

local notifyData =
{
	lastNotificationID = -1
}

local function loadNotificationID()
	local file, err = io.open( notifyDataFile ,"r" )

	if not file then
		log "no notification data file"
	else
		local serialized = file:read( "*a" )
		file:close()

		local decoded = json.decode( serialized )
		if decoded ~= nil and
			type(decoded.lastNotificationID) == "number"
		then
			log("found notification data file id "..decoded.lastNotificationID)
			notifyData.lastNotificationID = decoded.lastNotificationID
		end
	end
end

local function saveNotificationID()

	local serialized = json.encode( notifyData )

	local file, err = io.open( notifyDataFile, "w" )

	if not file then
		log "cannot save notification id"
	else
		log("saved "..serialized)
		file:write( serialized )
		file:close()
	end
end

local function dispNotification(title, msg, links, okLabel)

	if title == nil or msg == nil or okLabel == nil then return end

	local labels = {okLabel}

	local function listener(event)
		if event.action == "clicked" then
			local i = event.index
			if links[i-1] ~= nil then
				log( "opening "..links[i-1] )
				system.openURL( links[i-1] )
			end
		end
	end

	log( "==========" )
	local i = 1
	for k,v in pairs(links) do
		log( k,v )
		table.insert( labels, k )
		table.insert( links, v )
		i = i + 1
	end

	native.showAlert( title, msg, labels, listener )
end

local function fetchNotification(notifyURL)

	local function networkListener(event)
		if event.isError then
			log "Notify fetch error!"
		else
			local rsp = event.response

			if rsp == nil then return end

			log("recieved Notify response:")
			log(rsp)

			local jsonRsp = json.decode( rsp )
			if jsonRsp == nil or jsonRsp.status ~= "OK" then return end

			if jsonRsp.ID ~= notifyData.lastNotificationID then
				dispNotification(jsonRsp.title, jsonRsp.msg, jsonRsp.links, jsonRsp.okLabel)
				notifyData.lastNotificationID = jsonRsp.ID
			end

			saveNotificationID()
		end
	end

	network.request( notifyURL, "GET", networkListener)

end

local Notify = {}

function Notify.init(notifyURL)
	log("Notify init URL "..notifyURL)
	loadNotificationID()
	fetchNotification(notifyURL)
end

return Notify
