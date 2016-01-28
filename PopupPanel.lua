--[[
USAGE
	local PopupPanel = require "popupPanel"

	popup = PopupPanel:new()
	popup.title = "Share"

	popup:addElement("Facebook", facebookShareFunction())
	popup:addElement("Twitter", twitterShareFunction())
	popup:addElement("Cancel", popup:getHideFunction())

	popup:show()
]]


local widget = require "widget"

local dispW, dispH = display.actualContentWidth, display.actualContentHeight

--PopupPanel class
--popup panel with buttons and a title
--you can modify any of these attributes for customization
local PopupPanel =
{
	title = "Panel",
	elements = {},
	font = native.systemFont,
	fontSize = 24,
	elemSize = 50,
	titleSize = nil,
	container = nil,
	borderSpacing = 20,
	ease = easing.outCubic,
	time = 500,
	titleColor = {.3, 1.},
	backgroundColor = {1., 1.}
}
PopupPanel.__index = PopupPanel

function PopupPanel:new()
	local o = setmetatable( {}, self )
	return o
end

function PopupPanel:addElement(elem_, listener_)
	table.insert( self.elements, {elem = elem_, listener = listener_} )
end

function PopupPanel:show()
	self:setupContainer()
	local opt =
	{
		time = self.time,
		transition = self.ease,
		y = dispH - self.container.height
	}
	transition.to( self.container, opt )
end

function PopupPanel:hide()
	local opt =
	{
		time = self.time,
		transition = self.ease,
		y = dispH
	}
	transition.to( self.container, opt )
	self.container = nil
end

function PopupPanel:getHideFunction()
	local func = function()
		self:hide()
	end
	return func
end

function PopupPanel:setupContainer()

	local b = self.borderSpacing
	local h = self.elemSize * (1 + #self.elements) + b*2
	self.container = display.newContainer( dispW, h )

	local container = self.container

	container.anchorX = 0
	container.anchorY = 0

	container.y = dispH
	container.x = 0

	local backRect = display.newRect( 0, 0, dispW, h )
	backRect:setFillColor( unpack(self.backgroundColor) )
	container:insert( backRect )

	--title
	local titleText = display.newText
    {
    	text = self.title,
    	x = 0,
    	y = -h/2 + b + self.elemSize/2,
    	width = dispW,     --required for multi-line and alignment
    	font = self.font,
    	fontSize = self.titleSize or self.fontSize,
    	align = "center"
    }
    titleText:setFillColor( unpack(self.titleColor) )
    container:insert(titleText)

    for i, v in ipairs(self.elements) do

    	local elemButton = widget.newButton
	    {
	    	x = 0,
	    	y = -h/2 + b + (i + .5) * self.elemSize,
	    	onPress = v.listener,
	    	font = self.font,
	    	fontSize = self.fontSize
		}
		elemButton:setLabel( v.elem )
		container:insert(elemButton)

    end

    container:addEventListener( "touch",
    	function() return true end )
end

return PopupPanel
