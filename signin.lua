
local backGroup, mainGroup, uiGroup
local composer = require( "composer" )

local scene = composer.newScene()
local isDevice = system.getInfo("environment") == "device"
local darkMode = system.getInfo("darkMode")
local json = require( "json" )

local q = require"base"
local googleSignIn
local androidClientID
if isDevice then
	androidClientID = "157948540483-bq1ivqmrt0q1l4vonaqkhv75p7fsle3r.apps.googleusercontent.com"  -- DUBAG KEY
	-- if system.getInfo("targetAppStore")=="none" then
	-- 	q.copyToResources("google-services!test.json","google-services.json")
	-- else
	-- 	q.copyToResources("google-services!release.json","google-services.json")
	-- end
	googleSignIn = require( "plugin.googleSignIn" )
	googleSignIn.init({
	ios={
	    clientId = androidClientID
	},
	android={
	    clientId = androidClientID,
	    scopes= {"https://www.googleapis.com/auth/drive.appdata"}
	}
	})
end 
 
local accounts = {} 

local jsonLink = "https://api.jsonstorage.net/v1/json/7258cfc4-e9f4-4045-be0a-9179b1ee9d45/b1c050e3-5c68-4028-93e9-fe62a502f1c5"
local apiKey = "85a773f9-f27f-45b9-a130-45f1d3edc380"


local pps = require"popup"
pps.init(q)

local fieldsTable = {}
darkMode = false
local c
if darkMode==false then
	c = {
	  backGround = q.CL"EFEFF1",
	  text1 = {.2},
	  -- text1 = {.97},
	  textOnBack = {.97},
	  textOnGround = {.97},
	  invtext1 = {.03},
	  mainButtons = q.CL"ADB5BD",
	  fieldBack = {.92},

	  upBackLogo = {0,.2},

	  buttons = q.CL"ADB5BD",
	  mainButtons = q.CL"ADB5BD",
	  appColor1 = q.CL"1A2525",
	  appColor2 = q.CL"F7F3E0",
	  appColor3 = q.CL"FADA24",

		hideButton = {1,0,0,.2},
		hideButton = {1,0,0,.01},
	}
else
	c = {
	  backGround = {.08,.08,.18},
	  text1 = {.97},
	  -- text1 = {.97},
	  textOnBack = {.97},
	  textOnGround = {.97},
	  invtext1 = {.03},
	  mainButtons = q.CL"ADB5BD",
	  fieldBack = {.92},

	  upBackLogo = {1,.3},
		hideButton = {1,0,0,.01},

	  buttons = q.CL"ADB5BD",
	  mainButtons = q.CL"ADB5BD",
	  appColor = q.CL"FD4801",
	}
end



local function getSpaceWidth(font,fontSize)
	local label = display.newText( " ", -1000, -1000, font, fontSize )
	local w, h = label.width, label.height
	display.remove( label )
	return w, h
end

local function textWithLetterSpacing(options, space)
	space = space*.01 + 1
	if options.color==nil then options.color={1,1,1} end
	options.anchorY = options.anchorY or .5
	local j = 0
	local text = options.text 
	local width = 0
	local textGroup = display.newGroup()
	options.parent:insert(textGroup)
	-- local testWidthLabel = display.newText( "A", -100, -100, options.font, options.fontSize )
	-- local A_charWidth = testWidthLabel.width
	-- display.remove(testWidthLabel)
	for i=1, #text:gsub('[\128-\191]', '') do
		local char = text:sub(i+j,i+j+1)
    local bytes = {string.byte(char,1,#char)}

    if bytes[1]==208 or bytes[1]==209 then -- for russian char
      char = text:sub(i+j,i+j+1)
      j=j+1
    else  -- for english char
      char = char:sub(1,1)
    end
		local charLabel = display.newText( textGroup, char, options.x+width, options.y, options.font, options.fontSize )
		charLabel.anchorX = 0
		charLabel.anchorY = options.anchorY
		-- local rect = display.newRect( textGroup, options.x+width, options.y, 3, 50)
		-- rect.fill = {1,0,0,.5}
		-- local rect = display.newRect( textGroup, options.x+width+charLabel.width, options.y, 3, 50)
		-- rect.fill = {0,0,1,.5}
		width = width + (charLabel.width-1.2)*space
		charLabel:setFillColor( unpack(options.color) )
	end
	textGroup.x = -width*(options.anchorX or .5)
	return textGroup
end

local function createField( group, y, label, name, discription )

	local fieldLabel = display.newText({
		parent = group,
		text = label,
		x = 50,
		y = y+6,
		font = "fonts/hindv_b.ttf",
		fontSize = 15*2,
	})
	fieldLabel:setFillColor(unpack(c.text1))
	fieldLabel.anchorX = 0
	fieldLabel.anchorY = 0
	y = y + fieldLabel.height + 35

	local logField = native.newTextField(50, y, q.fullw-100, 90)
	group:insert( logField )
	logField.anchorX=0
	logField.isEditable=true
	logField.hasBackground = false
	logField.placeholder = discription
	logField.font = native.newFont( "ubuntu_r.ttf",16*2)
	logField:resizeHeightToFitFont()
	logField:setTextColor( 0, 0, 0 )
	fieldsTable[name] = logField

	local line = display.newRoundedRect(group, 50, y+25, q.fullw-50*2, 5, 6)
	line.fill = {0,.1}
	line.anchorX = 0
	line.anchorY = 0

	return 92+38+20
end
local incorrectLabel
local function showWarnin(text,time)
	print(text)
	time = time~=nil and time or 5000
	incorrectLabel.text=text
	incorrectLabel.alpha=1
	incorrectLabel.fill.a=1
	transition.cancel( "incor" )
	timer.performWithDelay( time, 
	function()
		transition.to(incorrectLabel.fill,{a=0,time=500,tag="incor"} )
	end)
end
local function validemail(str)
  if str == nil then return nil end
  if str:len() == 0 then return nil, "?????????????? ??????????" end
  if (type(str) ~= 'string') then
    error("Expected string")
    return nil
  end
  if not str:find("%@.") then 
    return nil, "?????????? ?????????? @ ??????????????????????!"
  end
  local lastAt = str:find("[^%@]+$")
  local localPart = str:sub(1, (lastAt - 2)) -- Returns the substring before '@' symbol
  local domainPart = str:sub(lastAt, #str) -- Returns the substring after '@' symbol
  -- we werent able to split the email properly
  if localPart == nil then
    return nil, "?????????? ???? @ ??????????????????????!"
  end

  if domainPart == nil or not domainPart:find("%.") then
    return nil, "?????????? ?????????? @ ??????????????????????!"
  end
  if string.sub(domainPart, 1, 1) == "." then
    return nil, "???????????? ???????????? ???? ?????????? ???????? ????????????!"
  end
  -- local part is maxed at 64 characters
  if #localPart > 64 then
    return nil, "?????????? ???? @ ???????????? ???????? ???????????? 64????????.!"
  end
  -- domains are maxed at 253 characters
  if #domainPart > 253 then
    return nil, "?????????? ?????????? @ ???????????? ???????? ???????????? 253????????.!"
  end
  -- somthing is wrong
  if lastAt >= 65 then
    return nil, "??????-???? ???? ??????..."
  end
  -- quotes are only allowed at the beginning of a the local name
  local quotes = localPart:find("[\"]")
  if type(quotes) == 'number' and quotes > 1 then
    return nil, "?????????????????????? ?????????????????????? ??????????????!"
  end
  -- no @ symbols allowed outside quotes
  if localPart:find("%@+") and quotes == nil then
    return nil, "?????????????? ?????????? @!"
  end
  -- no dot found in domain name
  if not domainPart:find("%..") then
    return nil, "?????? .com/.ru ??????????!"
  end
  -- only 1 period in succession allowed
  if domainPart:find("%.%.") then
    return nil, "?????? ?????????? ???????????? ?????????? @!"
  end
  if localPart:find("%.%.") then
    return nil, "?????? ?????????? ???????????? ???? @!"
  end
  -- just a general match
  if not str:match('[%w]*[%p]*%@+[%w]*[%.]?[%w]*') then
    return nil, "???????????????? ???????????????????? ?????????? ??????????????????!"
  end
  -- all our tests passed, so we are ok
  return true
end

local allUsers

local function googleLogin( event )
	if event.isError then showWarnin("??????-???? ?????????? ???? ??????...") return
	elseif allUsers[event.email]==nil then
		showWarnin("???????????????? ?? ???????? ???????????? ???? ????????????????????")
		googleSignIn.signOut()
		return
	end
	event.idToken = event.idToken:sub(1,10)
	-- local text = display.newText( {
 --  	text = q.printTable( event ) or "None",
 --  	x = 10,
 --  	y = 10,
 --  	width = q.fullw-10*2
 --  } )
 --  text.anchorX = 0
 --  text.anchorY = 0
 --  text:setFillColor( 0,1,.5 )

	local mail = event.email
	local user = allUsers[mail] 
	user.mail = mail

  composer.setVariable( "googleOut",true)
	q.saveLogin(user)
	composer.gotoScene("menu")
	composer.removeScene( "signin" )
end

local userRegister = {}
local function patchResponse( event )
  if ( event.isError)  then
    print( "Error!" )
		showWarnin("???????????? ??????????????????????: "..tostring(event.response))
  else
    local myNewData = event.response
    if myNewData==nil or myNewData=="[]" or myNewData=="" then
      print("Server patch: ?????? ????????????")
      return
    elseif myNewData:sub(1,3)=='{"u' then
      print("Server patch: ??????????????")

			q.saveLogin(userRegister)
			composer.gotoScene("menu")
			composer.removeScene( "signin" )
    end
    print(myNewData)
  end
end

local function serverResponse( event )
  if ( event.isError)  then
    print( "Error!" )
		showWarnin("???????????? ??????????????????????: "..tostring(event.response))
  else
    local myNewData = event.response
    local responeTable = json.decode( myNewData )
    if responeTable==nil or responeTable.error~=nil then
      print("Error: Server reg resoponse - "..myNewData	)
			if responeTable then
				if responeTable.error=="error" then 
					showWarnin("???????????????? ???????? ??????????/????????????")
				elseif responeTable.error.email[1]=="The email has already been taken." then 
					showWarnin("?????????? ????????????")
				end
			end
      return
    elseif myNewData:sub(1,1)=='{' then
      print("Warning: server reg resoponse: ??????????????")
      print(myNewData)
			q.saveLogin(json.decode( myNewData ))
			composer.gotoScene("menu")
			composer.removeScene( "signin" )
    end
    print(myNewData)
  end
end

local isVan = false
local function submitSignIn(event)
	if not allUsers then return end

	local submitButton = event.target
	submitButton.fill = q.CL"4d327a"
	local r,g,b = unpack( c.appColor1 )
	timer.performWithDelay( 400, 
	function()
		transition.to(submitButton.fill,{r=r,g=g,b=b,time=300} )
	end)

	local mail, pass = fieldsTable.INmail.text, fieldsTable.INpass.text
	mail = q.trim(mail)
	mail = mail:lower()
	local allows, errorMail = validemail(mail)
	if not allows then
		showWarnin(errorMail)
	elseif allUsers[mail]~=nil and allUsers[mail].google then
		showWarnin("???????? ???????????? ?????????? Google")
	elseif #pass==0 then
		showWarnin("?????????????? ????????????")
	elseif #pass<6 then
		showWarnin("???????????? ???? 6 ????????????????")
	elseif pass:find("%s") then
		showWarnin("???????????? ???? ???????????? ?????????????????? ??????????????")
	-- elseif allUsers[mail]==nil or allUsers[mail].password~=pass then 
	-- 	showWarnin("???????????????? ???????? ??????????/????????????")
	else
		local userLogin = {
			password = pass,
			email = mail,
		}

		print("https://getlet.ru/login/"..json.encode(userLogin))
		network.request( "https://getlet.ru/login/"..json.encode(userLogin), "GET", serverResponse )
		-- local user = allUsers[mail] 
		-- user.mail = mail
		-- user.id = 1
		-- q.saveLogin(user)
		-- composer.gotoScene("menu")
		-- composer.removeScene( "signin" )
	end
end
local function submitSignUp(event)
	if not allUsers then return end

	local submitButton = event.target
	submitButton.fill = q.CL"4d327a"
	local r,g,b = unpack( c.appColor1 )
	timer.performWithDelay( 400, 
	function()
		transition.to(submitButton.fill,{r=r,g=g,b=b,time=300} )
	end)

	local mail, pass, nick = fieldsTable.UPmail.text, fieldsTable.UPpass.text, fieldsTable.UPname.text
	mail = q.trim(mail)
	mail = mail:lower()
	nick = q.trim(nick)
	print(email, pass, name)
	local allows, errorMail = validemail(mail)
	if #nick==0 then
		showWarnin("?????????????? ??????????")
	elseif #nick<3 then
		showWarnin("?????????? ???? 3 ????????????????")
	elseif nick:find("%s") then
		showWarnin("?????????? ???? ???????????? ?????????????????? ??????????????")
	elseif not allows then
		showWarnin(errorMail and errorMail or "mail")
	-- elseif allUsers[mail]~=nil then
	-- 	showWarnin("?????????????? ?? ???????? ???????????? ?????? ????????????????????")
	elseif #pass==0 then
		showWarnin("?????????????? ????????????")
	elseif #pass<6 then
		showWarnin("???????????? ???? 6 ????????????????")
	elseif pass:find("%s") then
		showWarnin("???????????? ???? ???????????? ?????????????????? ??????????????")
	else
		local status = "user"
		if mail:find("admin") then
			status = "admin"
		elseif isVan then
			status = "helper"
		end


		local userRegister = {
			password = pass,
			nick = nick,
			email = mail,
		}

		print("https://getlet.ru/user/"..json.encode(userRegister))
		network.request( "https://getlet.ru/user/"..json.encode(userRegister), "GET", serverResponse )
		-- network.request( jsonLink.."?apiKey="..apiKey, "PATCH", patchResponse, {
	 --    headers = {
	 --      ["Content-Type"] = "application/json"
	 --    },
	 --    body = json.encode(userRegister),
	 --    bodyType = "text",
	 --  } )
		-- userRegister = userRegister[mail]
		-- userRegister.mail = mail
		-- userRegister[mail] = nil
	end
end
local function googleRegistration( event )
	if event.isError then showWarnin("??????-???? ?????????? ???? ??????...") return
	elseif allUsers[event.email]~=nil then
		showWarnin("?????????????? ?? ???????? ???????????? ?????? ????????????????????")
		googleSignIn.signOut()
		return
	end
	event.idToken = event.idToken:sub(1,10)
	-- local text = display.newText( {
 --  	text = q.printTable( event ) or "None",
 --  	x = 10,
 --  	y = 10,
 --  	width = q.fullw-10*2
 --  } )
 --  text.anchorX = 0
 --  text.anchorY = 0
 --  text:setFillColor( 0,1,.5 )
	-- print(q.printTable(event))

	local mail = event.email
	local status = "user"
	if mail:find("admin") then
		status = "admin"
	elseif isVan then
		status = "helper"
	end

	local usersCount = 0
	for k in pairs(allUsers) do
		usersCount = usersCount + 1
	end
	userRegister[mail] = {
		password = event.idToken,
		google = true,
		nick = event.displayName,
		signupdate = os.time(),
		status = status,
		id = usersCount + 1,
		likedTo = {},
		subTo = {},
	}

	-- text.text = "Request send"
  composer.setVariable( "googleOut",true)
	network.request( jsonLink.."?apiKey="..apiKey, "PATCH", patchResponse, {
    headers = {
      ["Content-Type"] = "application/json"
    },
    body = json.encode(userRegister),
    bodyType = "text",
  } )
	userRegister = userRegister[mail]
	userRegister.mail = mail
	userRegister[mail] = nil
end

local countError = 5
local goButton
local function gotoOfflineMode()
	exit = true
	local user = {
		mail = "none@none.nome",
		password = "123456789",
		name = "???????????? ?????????? .",
		id = 1,
		status = "offline",
		test = {"..<24","????, ??????????","???????????????? ??????????????????"},
		signupdate = "01.01.0001"
	}
	q.saveLogin(user)
	composer.gotoScene("menu")
	composer.removeScene( "signin" )
end
local loadAllUsers
local function noInternerPop( event )
	if nowScene=="noInternet" then return end
	local allPopGroup = display.newGroup()
  local eventGroupName = pps.popUp("noInternet", allPopGroup)

 	local backBlackTone = display.newRect(allPopGroup, q.cx, q.cy, q.fullw, q.fullh)
 	backBlackTone.fill = {0,0,0,.2}

 	transition.to(allPopGroup, {y = -300, time = 500})

 	local backWhite = display.newRoundedRect(allPopGroup, q.cx, q.fullh-30, q.fullw, 360, 40)
 	backWhite.fill = {.88}--c.backGround
 	backWhite.anchorY = 0

 	local noEthLabel = display.newText( {
		parent = allPopGroup,
		text = "?????? ?????????????????????? ?? ??????????????????...",
		x = 40,
		y = q.fullh + 10,
		font = "ubuntu_b.ttf",
		fontSize = 16*2,
		} )
	noEthLabel.anchorX = 0
	noEthLabel.anchorY = 0
	noEthLabel.fill = {0}--c.text1

	local offlineLabel = display.newText( {
		parent = allPopGroup,
		text = "???? ???????????? ?????????? ?????? ?????????????????????? ?? ?????????????? ??????????",
		x = 40,
		y = q.fullh + 10 + 50,
		font = "ubuntu_r.ttf",
		fontSize = 12*2,
		} )
	offlineLabel.anchorX = 0
	offlineLabel.anchorY = 0
	offlineLabel.fill ={0}--c.text1

	local offButton = display.newRoundedRect( allPopGroup, q.cx, q.fullh+130, q.fullw-120, 110, 30)
	offButton.anchorY=0
	offButton.fill = {.7}

	local offContinue = textWithLetterSpacing( {
		parent = allPopGroup, 
		text = "?????????????? - ??????????", 
		x = q.cx, 
		y = offButton.y+55, 
		font = "ubuntu_b.ttf", 
		fontSize = 14*2,
		color = {.97},
	}, 10, .5)

	q.event.add("tryConnectionAgain", backBlackTone, function()
		if countError==0 then
  		network.request( jsonLink, "GET", loadAllUsers )
		end
		countError = 10
 		transition.to(allPopGroup, {y = 0, time = 500, onComplete = pps.removePop})

	end, eventGroupName)

	q.event.add("noEthGotoOffline", offButton, gotoOfflineMode, eventGroupName)
	
	q.event.group.on(eventGroupName)

end
loadAllUsers = function( event )
	print("check resoponse")
  if ( event.isError )  then
    print( "Error!", event.response)
  	countError = countError - 1
  	if countError~=0 then
  		timer.performWithDelay( 500, function()
  			network.request( jsonLink, "GET", loadAllUsers )
  		end )
  	else
  		noInternerPop()
    end
    return false
  else
    local myNewData = event.response
    if myNewData==nil or myNewData=="[]" then
      print("Server read: ?????? ????????????")
      return false
    end
    if myNewData=="You've exceeded 500 requests daily limit, please upgrade your plan or try again tomorrow." then
    	error("?????????? ?? 500 ?????????????????????? ?? ???????? ??????????????")
    end
    allUsers = json.decode(myNewData)

  end
  -- print("connected")
  if goButton then
  	-- print("coloring")
	  local r,g,b = unpack(c.appColor1)
	  transition.to( goButton.fill, {r=r,g=g,b=b, time=500} )
  end
  return true
end



local signUpMenu
local function signInMenu()

	local signInGroup = display.newGroup()
  local eventGroupName = pps.popUp("signIn", signInGroup)

  local back = display.newRect(signInGroup,q.cx,q.cy,q.fullw,q.fullh)
	back.fill = c.backGround

	local backLogoRounded = display.newRoundedRect( signInGroup, q.cx, 220, 200, 200, 30 )
	backLogoRounded.fill = {
		type = "image",
		filename = "img/logo.png"
	}

	-- local backLogo = display.newImageRect( signInGroup, "img/logo.png", 180, 180 )
	-- backLogo.x, backLogo.y = q.cx, 220


	local labelSignIn = display.newText( {
		parent = signInGroup,
		text = "??????????",
		x = 50,
		y = 440+60,
		font = "fonts/hindv_b.ttf",
		fontSize = 80,
		} )
	labelSignIn.anchorX = 0
	labelSignIn.fill = c.text1

	local label = display.newText( {
		parent = signInGroup, 
		text = "???????????? ?????????????",
		x = 50,
		y = labelSignIn.y+labelSignIn.height*.5+10, 
		font = "fonts/hindv_b.ttf", 
		fontSize = 16*2
		})
	label:setFillColor( unpack(c.appColor1) )
	-- label.alpha = .5
	label.anchorX=0

	-- local backButton = display.newRect( signInGroup, 60-30, label.y-40, 380, 80 )
	-- backButton.fill = c.hideButton
	-- backButton.anchorX = 0
	-- backButton.anchorY = 0


	local lastY = 640
	local space = 30
	lastY = lastY + createField( signInGroup, lastY, "??????????", "INmail", "?????????????? ??????????/??????????" ) + space
	fieldsTable.INmail.inputType = "email"
	
	lastY = lastY + createField( signInGroup, lastY, "????????????","INpass", "?????????????? ????????????" )
	fieldsTable.INpass.inputType = "no-emoji"

	if not isDevice then
		fieldsTable.INmail.text = "admin@gmail.com"
		fieldsTable.INpass.text = "12345678"
	end

	
	lastY = lastY + 60
	local spase = 40
	local labelContinue = display.newText( {
		parent = signInGroup, 
		text = "??????????", 
		x = q.fullw-50-spase, 
		y = lastY,  
		font = "fonts/hindv_r.ttf", 
		fontSize = 16*2,
	})
	-- labelContinue:setFillColor( 0 )
	labelContinue.anchorX = 1
	
	local submitButton = display.newRoundedRect( signInGroup, labelContinue.x+spase, labelContinue.y, spase*2+labelContinue.width, 60, 50)
	submitButton.anchorX=1
	if allUsers then
		submitButton.fill = c.appColor1
	else
		submitButton.fill = {.7,.7,.7}
		goButton = submitButton
	end
	labelContinue:toFront()
	incorrectLabel.y = lastY + submitButton.height - 20

	lastY = lastY + submitButton.height + 50

	local centSpace = 150
	local line1 = display.newRect(signInGroup, 50, lastY, q.cx-50-centSpace*.5, 5)
	line1.fill = {0,.2}
	line1.anchorX = 0
	local line2 = display.newRect(signInGroup, q.fullw-50, lastY, q.cx-50-centSpace*.5, 5)
	line2.fill = {0,.2}
	line2.anchorX = 1

	local labelContinue = display.newText( {
		parent = signInGroup, 
		text = "?????? ????", 
		x = q.cx, 
		y = lastY,  
		font = "fonts/hindv_r.ttf", 
		fontSize = 16*2,
	})
	labelContinue:setFillColor(0)

	lastY = lastY + 150
	local space = 130
	local height = 90
	local googleButton = display.newRoundedRect( signInGroup, q.cx, lastY, q.fullw-space*2, height, 50)
	googleButton.anchorY=1
	googleButton.fill = c.backGround
	googleButton:setStrokeColor( unpack(c.appColor1) )
	googleButton.strokeWidth = 6

	local textAndLogo = display.newGroup()
	signInGroup:insert(textAndLogo)

	local logoGoogle = display.newImageRect( textAndLogo, "img/google.png", 35, 35 )
	logoGoogle.anchorX = 0
	logoGoogle.y = googleButton.y-googleButton.height*.5

	local labelContinue = display.newText( {
		parent = textAndLogo, 
		text = "???????????????????? ?????????? Google", 
		x = logoGoogle.width+20, 
		y = googleButton.y-googleButton.height*.5,  
		font = "fonts/hindv_r.ttf", 
		fontSize = 16*2,
	})
	labelContinue.anchorX = 0
	labelContinue:setFillColor(unpack(q.CL"505050"))

	textAndLogo.x = q.cx - textAndLogo.width*.5

	lastY = lastY + height + 50
	local orLoginButton = display.newRoundedRect( signInGroup, q.cx, lastY, q.fullw-space*2, height, 50)
	orLoginButton.anchorY=1
	orLoginButton.fill = c.appColor1

	local labelContinue = display.newText( {
		parent = signInGroup, 
		text = "????????????????????????????????????", 
		x = q.cx, 
		y = orLoginButton.y-orLoginButton.height*.5,  
		font = "fonts/hindv_r.ttf", 
		fontSize = 16*2,
	})


	if isDevice then
		q.event.add("googleSingIn",googleButton,function()
			if not allUsers then return end
			googleSignIn.signIn( androidClientID, nil, nil, googleLogin)
		
		end, eventGroupName)
	end

	q.event.add("orToRegister",orLoginButton, function()	
		pps.removePop()
		fieldsTable = {}
		signUpMenu()
	end, eventGroupName)
	q.event.add("finishSignIn", submitButton, submitSignIn, eventGroupName)
	
	q.event.group.on(eventGroupName)

	signInGroup.alpha = 0
	transition.to( signInGroup, {alpha=1, time = 300} )
end


signUpMenu = function()

	local signUpGroup = display.newGroup()
  local eventGroupName = pps.popUp("signUp", signUpGroup, {
	  onHide=function()
	  	for k, v in pairs(fieldsTable) do
				v.x = q.fullw
			end
	  end,
	  onShow=function()
	  	for k, v in pairs(fieldsTable) do
				v.x = 70
			end
	  end,
  })

	local back = display.newRect(signUpGroup,q.cx,q.cy,q.fullw,q.fullh)
	back.fill = c.backGround

	local backLogoRounded = display.newRoundedRect( signUpGroup, q.cx, 180, 200, 200, 30 )
	backLogoRounded.fill = {
		type = "image",
		filename = "img/logo.png"
	}
	-- local backLogo = display.newImageRect( signUpGroup, "img/logo.png", 180, 180 )
	-- backLogo.x, backLogo.y = q.cx, 220


	local labelSignIn = display.newText( {
		parent = signUpGroup,
		text = "??????????????????????",
		x = 50,
		y = 400,
		font = "fonts/hindv_b.ttf",
		fontSize = 80,
		} )
	labelSignIn.anchorX = 0
	labelSignIn.fill = c.text1

	local label = display.newText( {
		parent = signUpGroup, 
		text = "?????? ???????? ???????????????",
		x = 50,
		y = labelSignIn.y+labelSignIn.height*.5+10, 
		font = "fonts/hindv_b.ttf", 
		fontSize = 16*2
		})
	label:setFillColor( unpack(c.appColor1) )
	-- label.alpha = .5
	label.anchorX=0

	local backButton = display.newRect( signUpGroup, 60-30, label.y-40, 380, 80 )
	backButton.fill = c.hideButton
	backButton.anchorX = 0
	backButton.anchorY = 0


	local lastY = 540
	local space = 30
	lastY = lastY + createField( signUpGroup, lastY, "?????? ??????", "UPname", "?????????????? ??????" ) + space
	fieldsTable.UPname.inputType = "no-emoji"

	lastY = lastY + createField( signUpGroup, lastY, "??????????", "UPmail", "?????????????? ??????????" ) + space
	fieldsTable.UPmail.inputType = "email"
	
	lastY = lastY + createField( signUpGroup, lastY, "????????????","UPpass", "?????????????? ????????????" )
	fieldsTable.UPpass.inputType = "no-emoji"

	if not isDevice then
		fieldsTable.UPname.text = "TheBrainMaps"
		fieldsTable.UPmail.text = "admin@gmail.com"
		fieldsTable.UPpass.text = "12345678"
	end

	
	lastY = lastY + 60
	local spase = 40
	local labelContinue = display.newText( {
		parent = signUpGroup, 
		text = "????????????????????????????????????", 
		x = q.fullw-50-spase, 
		y = lastY,  
		font = "fonts/hindv_r.ttf", 
		fontSize = 16*2,
	})
	-- labelContinue:setFillColor( 0 )
	labelContinue.anchorX = 1
	
	local submitButton = display.newRoundedRect( signUpGroup, labelContinue.x+spase, labelContinue.y, spase*2+labelContinue.width, 60, 50)
	submitButton.anchorX=1
	if allUsers then
		submitButton.fill = c.appColor1
	else
		submitButton.fill = {.7,.7,.7}
		goButton = submitButton
	end
	labelContinue:toFront()
	incorrectLabel.y = lastY + submitButton.height - 20

	lastY = lastY + submitButton.height + 50

	local centSpace = 150
	local line1 = display.newRect(signUpGroup, 50, lastY, q.cx-50-centSpace*.5, 5)
	line1.fill = {0,.2}
	line1.anchorX = 0
	local line2 = display.newRect(signUpGroup, q.fullw-50, lastY, q.cx-50-centSpace*.5, 5)
	line2.fill = {0,.2}
	line2.anchorX = 1

	local labelContinue = display.newText( {
		parent = signUpGroup, 
		text = "?????? ????", 
		x = q.cx, 
		y = lastY,  
		font = "fonts/hindv_r.ttf", 
		fontSize = 16*2,
	})
	labelContinue:setFillColor(0)

	lastY = lastY + 150
	local space = 130
	local height = 90
	local googleButton = display.newRoundedRect( signUpGroup, q.cx, lastY, q.fullw-space*2, height, 50)
	googleButton.anchorY=1
	googleButton.fill = c.backGround
	googleButton:setStrokeColor( unpack(c.appColor1) )
	googleButton.strokeWidth = 6

	local textAndLogo = display.newGroup()
	signUpGroup:insert(textAndLogo)

	local logoGoogle = display.newImageRect( textAndLogo, "img/google.png", 35, 35 )
	logoGoogle.anchorX = 0
	logoGoogle.y = googleButton.y-googleButton.height*.5

	local labelContinue = display.newText( {
		parent = textAndLogo, 
		text = "???????????????????? ?????????? Google", 
		x = logoGoogle.width+20, 
		y = googleButton.y-googleButton.height*.5,  
		font = "fonts/hindv_r.ttf", 
		fontSize = 16*2,
	})
	labelContinue.anchorX = 0
	labelContinue:setFillColor(unpack(q.CL"505050"))

	textAndLogo.x = q.cx - textAndLogo.width*.5

	lastY = lastY + height + 50
	local orLoginButton = display.newRoundedRect( signUpGroup, q.cx, lastY, q.fullw-space*2, height, 50)
	orLoginButton.anchorY=1
	orLoginButton.fill = c.appColor1

	local labelContinue = display.newText( {
		parent = signUpGroup, 
		text = "??????????", 
		x = q.cx, 
		y = orLoginButton.y-orLoginButton.height*.5,  
		font = "fonts/hindv_r.ttf", 
		fontSize = 16*2,
	})


	if isDevice then
		q.event.add("googleSingUp",googleButton,function()
			if not allUsers then return end
			googleSignIn.signIn( androidClientID, nil, nil, googleRegistration)
		
		end, eventGroupName)
	end

	q.event.add("IneedToLogin",backButton, function()
		pps.removePop()
		fieldsTable = {}
		signInMenu()
	end, eventGroupName)
	q.event.add("orToLogin",orLoginButton, function()
		pps.removePop()
		fieldsTable = {}
		signInMenu()
	end, eventGroupName)
	q.event.add("finishSignUp", submitButton, submitSignUp, eventGroupName)
	
	q.event.group.on(eventGroupName)

	signUpGroup.alpha = 0
	transition.to( signUpGroup, {alpha=1, time = 300} )
	-- noInternerPop()
end

local logField, pasField, ipField

local onKeyEvent
if ( system.getInfo("environment") == "device" ) then
  onKeyEvent = function( event )
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    -- print( message )
    -- print(system.getInfo("platform") )
    -- If the "back" key was pressed on Android, prevent it from backing out of the app
    if ( event.keyName == "back" and nowScene~="menu" and nowScene~="chatlist" and event.phase == "down" ) then
      pps.removePop()
      
      return true
    end

    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
  end
else
  onKeyEvent = function( event )
    
    local key = event.keyName
    local message = "PC Key '" .. key .. "' was pressed " .. event.phase
    print( message )

    if ( event.phase == "down" ) then
      if key=="escape" and nowScene~="menu" and nowScene~="chatlist" then
        -- display.remove(newPopUp)
        pps.removePop()
      end
    end

  end
end
function scene:create( event )
	local sceneGroup = self.view

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)


	mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)
	mainGroup.alpha = 0

	local welcomeGroup = display.newGroup()
	sceneGroup:insert(welcomeGroup)
	
	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)


	local back = display.newRect(backGroup,q.cx,q.cy,q.fullw,q.fullh)
	back.fill = c.backGround


	do -- ?? ?? ?? ?? ?? ?? ??
		local welcomeImage = display.newImageRect( welcomeGroup, "img/welcome_back.png", q.fullh*0.612, q.fullh+5 )
		welcomeImage.x = q.cx
		welcomeImage.y = -5
		welcomeImage.anchorY = 0

		local welcomeFiller = display.newRect( welcomeGroup, q.cx, q.cy, q.fullw, q.fullh)
		welcomeFiller.fill = q.CL"1A2525"


		local logo = display.newImageRect( welcomeGroup, "img/logo_words.png", q.fullw*.8, (q.fullw*.8)/4.8 )
		logo.x, logo.y = q.cx, q.cy-100

		local aboutAppLabel = display.newText( {
			parent = welcomeGroup,
			text = "???????????? ???????????????????? ???????? ??????????????????????\n???????????????? Sight ?? ???????????? ???????????????? YAKSE.\n\n?????????????? ?????? ?????????? ???????????????????? ??????????\n?????????????????? ?? ?????????? ?????????????? 2023.",
			align = "center",
			width = q.fullw-200,
			x = q.cx,
			y = logo.y + logo.height*.5+50,
			font = "fonts/sah_roboto_r.ttf",
			fontSize = 30,
		} )
		aboutAppLabel.anchorY = 0


		-- local welcomeLabelMain = display.newVisualParagraph("?????????? ?????????????????? ?????? ??????????????-????????????????", q.fullw - 40*2,{
	 --    lineHeight = 1.5,
	 --    font = "fonts/mont_b.ttf",
	 --    size = 60,
	 --    align = "left",
	 --  })
	 --  welcomeGroup:insert( welcomeLabelMain )
	 --  welcomeLabelMain.x = 40
	 --  welcomeLabelMain.y = -100 + 60

	 --  local welcomeLabelDop = display.newVisualParagraph("?????????? ???????????? ?????????????? ?????????? ?????? ??????????????!", q.fullw - 40*2,{
	 --    lineHeight = 1.5,
	 --    font = "fonts/mont_b.ttf",
	 --    size = 40,
	 --    align = "left",
	 --  })
	 --  welcomeGroup:insert( welcomeLabelDop )
	 --  welcomeLabelDop.x = 40
	 --  welcomeLabelDop.y = welcomeLabelMain.y + welcomeLabelMain.height + 85

	  local space = 130
	  local height = 90
		local regButton = display.newRoundedRect( welcomeGroup, space, q.fullh-240, q.fullw-space*2, height, 50)
		regButton.anchorX=0
		regButton.anchorY=1
		-- regButton.fill = {1}

		local labelContinue = display.newText( {
			parent = welcomeGroup, 
			text = "????????????????????????????????????", 
			x = q.cx, 
			y = regButton.y-regButton.height*.5,  
			font = "fonts/hindv_r.ttf", 
			fontSize = 16*2,
		})
		labelContinue:setFillColor( unpack(c.text1) )

		local signButton = display.newRoundedRect( welcomeGroup, space, q.fullh-240+120, q.fullw-space*2, height, 50)
		signButton.anchorX=0
		signButton.anchorY=1
		signButton.fill = {0,0,0,.01}
		signButton.strokeWidth = 5
		signButton:setStrokeColor( unpack(c.appColor3) )
		-- if darkMode then
		-- 	signButton.fill = c.text1
		-- end

		local labelContinue = display.newText( {
			parent = welcomeGroup, 
			text = "??????????", 
			x = q.cx, 
			y = signButton.y-signButton.height*.5,  
			font = "fonts/hindv_r.ttf", 
			fontSize = 16*2,
		})
		-- labelContinue:setFillColor( unpack(c.text2) )


		local offButton = display.newRoundedRect( welcomeGroup, q.cx, q.fullh-120*3+50, q.fullw-120, 110, 30)
		offButton.anchorY=1
		offButton.fill = c.text1
		offButton.alpha = .01

		local color = c.appColor
    q.event.add("toSignIn", signButton, signInMenu, "hub-popUp")
    q.event.add("toRegister", regButton, signUpMenu, "hub-popUp")

		pps.addMainScene("hub", welcomeGroup, {
      onShow = function()
      	goButton = nil
				incorrectLabel.alpha = 0
      end
    })
    q.event.group.on("hub-popUp")
	end

	incorrectLabel = display.newText( {
		parent = uiGroup, 
		text = "???????????????? ???????? ??????????/????????????!", 
		x = q.fullw-50, 
		y = q.fullh-195,
		width = q.fullw - 60*2,
		align = "right", 
		font = "img/hindv_b.ttf", 
	fontSize = 30})
	incorrectLabel:setFillColor( unpack( c.appColor1) )
	incorrectLabel.anchorX=1
	incorrectLabel.anchorY=0
	incorrectLabel.alpha=0
	
  Runtime:addEventListener( "key", onKeyEvent )
end


function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- local accountInfo = q.loadLogin()
		-- if accountInfo~=nil and accountInfo~={} and accountInfo["email"]~=nil and accountInfo["email"]~="" then
		-- 	print(accountInfo[1])
		-- 	-- composer.setVariable( "ip", accountInfo[3] )
		-- 	composer.gotoScene( "menu" )
		-- 	composer.removeScene( "signin" )
		-- else
		-- 	-- composer.gotoScene("signtest")
		-- end

		for k,v in pairs(fieldsTable) do
			fieldsTable[k].x = 70
		end
	elseif ( phase == "did" ) then
		local accountInfo = q.loadLogin()
		-- print("Warning",json.encode(accountInfo))
		if accountInfo~=nil and accountInfo["email"]~=nil and accountInfo["email"]~="" then
			print(accountInfo.name)
			-- composer.setVariable( "ip", accountInfo[3] )
			composer.gotoScene( "menu" )
			composer.removeScene( "signin" )
		else
  		network.request( jsonLink, "GET", loadAllUsers )
			if  composer.getVariable( "googleOut")==true then
				-- timer.performWithDelay( 1000,function()
					googleSignIn.signOut()
  				composer.setVariable( "googleOut",false)
				-- end )
			end
			-- signUpMenu()
			-- signInMenu()
			-- composer.gotoScene("signtest")
		end
			-- composer.gotoScene("signup")
		-- timer.performWithDelay( 1,function()
		-- 	for k,v in pairs(fieldsTable) do
		-- 		fieldsTable[k].x = -q.fullw
		-- 	end
		-- 	composer.gotoScene("signup")
		-- end )
		-- composer.gotoScene("menu")

	end
end


function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		native.setKeyboardFocus(nil)
    Runtime:removeEventListener( "key", onKeyEvent )
		pps.reset()
		if allUsers then
  		composer.setVariable( "allUsers", allUsers)
		end

	elseif ( phase == "did" ) then
	end
end


function scene:destroy( event )

	local sceneGroup = self.view

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
