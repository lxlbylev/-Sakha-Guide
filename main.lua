

local composer = require( "composer" )

require "text"
local controller = require "controller"
composer.setVariable("controller",controller)


display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )

-- local q = require("base")
-- local accountInfo = q.loadLogin()
-- if accountInfo~=nil and accountInfo~={} and accountInfo["password"]~=nil and accountInfo["password"]~="" then
-- 	composer.gotoScene( "menu" )
-- else
	composer.gotoScene( "signin" )
-- end
