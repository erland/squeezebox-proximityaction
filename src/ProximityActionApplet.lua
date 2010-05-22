
--[[
=head1 NAME

applets.ProximityAction.ProximityActionApplet - Proximity applet that triggers an action based on proximity

=head1 DESCRIPTION

Proximity Action is a applet that can be configured to perform an action when you are getting close to the device

=head1 FUNCTIONS

Applet related methods are described in L<jive.Applet>. ScrollBugApplet overrides the
following methods:

=cut
--]]


-- stuff we use
local pairs, ipairs, tostring, tonumber, setmetatable, package, type = pairs, ipairs, tostring, tonumber, setmetatable, package, type

local oo               = require("loop.simple")
local os               = require("os")
local io               = require("io")
local math             = require("math")
local string           = require("jive.utils.string")

local Applet           = require("jive.Applet")
local Window           = require("jive.ui.Window")
local Group            = require("jive.ui.Group")
local Label            = require("jive.ui.Label")
local Font             = require("jive.ui.Font")
local Framework        = require("jive.ui.Framework")
local Timer            = require("jive.ui.Timer")

local System           = require("jive.System")

local appletManager    = appletManager
local jiveMain         = jiveMain

local WH_FILL           = jive.ui.WH_FILL
local LAYOUT_NONE       = jive.ui.LAYOUT_NONE

local SENSITIVITY = 15

module(..., Framework.constants)
oo.class(_M, Applet)


----------------------------------------------------------------------------------------
-- Helper Functions
--

function openWindow(self)
	self.window = Window("window")
	self.window:setSkin(self:_getSkin(jiveMain:getSelectedSkin()))
	self.window:reSkin()
	self.window:setShowFrameworkWidgets(false)

	self.textwidget = Group("proximitytext",{
		label = Label("proximitytext","")
	})
	self.window:addWidget(self.textwidget)

	-- Show the window
	self.window:show(Window.transitionFadeInFast)
end

function init(self)
	self.timer = Timer(100,
		function()
			self:_tick()
		end
	)
	self.timer:start()
	
end

function free(self)
	-- prevent this app from being unloaded.
	return false
end

function closeWindow(self)
	if self.window then
		self.window:hide(Window.transitionFadeIn)
		self.window = nil
		self.textwidget = nil
	end
end

function _tick(self)
	if System:getMachine() == "fab4" then
		local f = io.open("/sys/bus/i2c/devices/0-0047/proximity_density")
		local density = f:read("*all")
		f:close()
		if self.window and self.textwidget and self.window:isVisible() then
			if tonumber(density) < SENSITIVITY then
				self.textwidget:setWidgetValue("label",tostring(self:string("SCREENSAVER_PROXIMITY_AWAY",tonumber(density))))
				if self.timeoutTimer then
					self.timeoutTimer:stop()
				end
				self.hiddenAfterTimeout = false
				self:closeWindow()
			else
				if not self.timeoutTimer then
--					self.timeoutTimer = Timer(3000,function()
--							self.hiddenAfterTimeout = true
--							self:closeWindow()
--						end)
				elseif not self.timeoutTimer:isRunning() then
--					self.timeoutTimer:restart()
				end
				self.textwidget:setWidgetValue("label",tostring(self:string("SCREENSAVER_PROXIMITY_NEAR",tonumber(density))))
			end
		elseif tonumber(density)>=SENSITIVITY and not self.hiddenAfterTimeout then
			self:openWindow()
		elseif tonumber(density)<SENSITIVITY then
			self.hiddenAfterTimeout = false
		end
	elseif self.window and self.textwidget and self.window:isVisible() then
			self.textwidget:setWidgetValue("label",tostring(self:string("SCREENSAVER_PROXIMITY_UNSUPPORTED")))
	end
end

function _loadFont(self,font,fontSize)
	log:debug("Loading font: "..font.." of size "..fontSize)
        return Font:load(font, fontSize)
end

function _getSkin(self,skin)
	local s = {}

	s.window = {}

	s.window["proximitytext"] = {
		position = LAYOUT_NONE,
		y = 50,
		x = 0,
		zOrder = 4,
	}
	local font = self:_loadFont("fonts/FreeSans.ttf",45)
	
	s.window["proximitytext"]["proximitytext"] = {
			border = {5,0,5,0},
			font = font,
			align = "center",
			lineHeight = 50,
			w = WH_FILL,
			h = 60,
			fg = {0xff, 0xff, 0xff},
		}

	return s
end

--[[

=head1 LICENSE

Copyright 2010, Erland Isaksson (erland_i@hotmail.com)
Copyright 2010, Logitech, inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Logitech nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL LOGITECH, INC BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
--]]

