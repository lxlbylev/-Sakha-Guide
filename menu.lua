--[[
main-file
local composer = require( "composer" )
display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )
composer.gotoScene( "menu" )
--]]
local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )

-- local androidFilePicker = require "plugin.androidFilePicker"

local tile = require( "tilebg" )

-- local googleSignIn
-- local androidClientID = "157948540483-bq1ivqmrt0q1l4vonaqkhv75p7fsle3r.apps.googleusercontent.com"
-- if isDevice then  
--   googleSignIn = require( "plugin.googleSignIn" )
--   googleSignIn.init({
--   ios={
--       clientId = androidClientID
--   },
--   android={
--       clientId = androidClientID,
--       scopes= {"https://www.googleapis.com/auth/drive.appdata"}
--   }
--   })
-- end
-- local roundedRectAndShadow = require( "shadowRR" )

-- local isDevice = (system.getInfo("environment") == "device")

local allInstaPost = {}

local backGroup

local mainGroup
local topMain

local subGroup
local fireGroup
local streamGroup
local profileGroup

local uiGroup


local q = require("base")
local chat = require("chat")

local json = require( "json" )
local server = "127.0.0.1"


local c = {
  backGround = {.97},
  text1 = {0},
  invtext1 = {1},
  mainButtons = {1},
  hideButtons = {1,0,0,.01},

	black = q.CL"000000",
	gray = q.CL"808080",
	gray2 = q.CL"DEDEDE",
	buttons = q.CL"ADB5BD",
	prewhite = q.CL"F9FAFB",
	ultrablack = q.CL"CCCCCC",
	outline = q.CL"9F9F9F",
	white = q.CL"FFFFFF",
	
  main = q.CL"fada25",
  right = q.CL"00a576",
  error = q.CL"ea5a41",
  blank = q.CL"f7f3e0",
  text = q.CL"1a2525",
}

-- local c = {
--   backGround = {.03},
--   text1 = {.97},
--   invtext1 = {.03},
--   mainButtons = q.CL"ADB5BD",

--   buttons = q.CL"ADB5BD",
--   mainButtons = q.CL"ADB5BD",
--   appColor = q.CL"0058EE",
-- }

local searchField
local toBotField
local menuButton, newsButton, chatButton, profileButton
local inNewsOverlay
local downNavigateGroup, upNavigateGroup


local closePCMenu = function() end

local pps = require"popup"
pps.init(q) -- popUp system


-- ========== --
-- ========== --
-- ========== --

local function menuButtonsListener( event )
  pps.mainScene(event.target.name)
end
-- -- --

local function textWithLetterSpacing(options, space, anchorX)
	space = space*.01 + 1
	if options.color==nil then options.color={1,1,1} end

	local j = 0
	local text = options.text 
	local width = 0
	local textGroup = display.newGroup()
	options.parent:insert(textGroup)
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
		charLabel.anchorX=0
		width = width + (charLabel.width-1.5)*space
		charLabel:setFillColor( unpack(options.color) )
	end
	if anchorX then
		textGroup.x = -width*(anchorX)
	end
  return textGroup
end

local incorrectChange
local function showPassWarning(text, time)
  timer.cancel( "passwarn" )
  transition.cancel( "passwarn" )
  
  time = time~=nil and time or 2000
  incorrectChange.text=text
  incorrectChange.alpha=1
  incorrectChange.fill.a=1
  timer.performWithDelay( time, 
  function()
    transition.to(incorrectChange.fill,{a=0,time=500, tag="passwarn"} )
  end, 1, "passwarn")
end
local function changeResponder(event)
  if ( event.isError) then
    print( "Change password server error:", event.response)
  else
    local myNewData = event.response
    -- print("Server:"..myNewData)
    if myNewData=="Incorrect\n\n\n" then
      showPassWarning("Текущий пароль не верен")
    elseif myNewData=="PasswordChanged\n\n\n" then
      -- showPassWarning("Пароль изменён успешно!")
      closePCMenu()
    else
    -- elseif myNewData=="User not found\n\n\n" then
      showPassWarning("Упс.. Что-то пошло не так")
    end

  end
end

local function line(group, y, width, stroke, color)
  local line = display.newRoundedRect(group, q.cx, y, width or (q.fullw-110), stroke or (3*2), 50 )
  line.fill = color or q.CL"EEEEEE"
  return line
end



local function getLabelSize(options)
  -- print(options)
  local label = display.newText(options)
  local width = label.width
  local height = label.height
  display.remove(label)
  return width, height
end


local submitButton
local jsonLink = "https://api.jsonstorage.net/v1/json/7258cfc4-e9f4-4045-be0a-9179b1ee9d45/fee33a78-f8ae-4524-b75c-e7e96bfdfcf1"
local apiKey = "602b9c9c-acc1-4cb5-a412-8200236660e4"
local allUsers
local function patchResponse( event )
  if ( event.isError)  then
    print( "Error!" )
  else
    local myNewData = event.response
    if myNewData==nil or myNewData=="[]" or myNewData=="" then
      print("Server patch: нет ответа")
      return
    elseif myNewData:sub(1,3)=='{"u' then
      print("Server patch: успешно")
      -- hideMain()
      -- handleResponse()
    end
    print(myNewData)
  end
end
local function patcher( patch )
  print(patch)
  network.request( jsonLink.."?apiKey="..apiKey, "PATCH", patchResponse, {
    headers = {
      ["Content-Type"] = "application/json"
    },
    body = patch,
    bodyType = "text",
  } )
end





local function generateButtonWithLogo(options)
  if options.textWidth==nil then
    options.textWidth = getLabelSize({
      font = "mont_sb",
      fontSize = 18*2,
      text = options.text1
    })
  end
  local group = display.newGroup( )
  if options.parent then
    options.parent:insert(group)
  end
  group.x = options.x
  group.y = options.y

  local text = {
    font = "mont_sb",
    fontSize = 18*2,
  }
  -- local back = roundedRectAndShadow({
  --   parent = group, 
  --   x = 0, 
  --   y = 0, 
  --   width = 140+math.ceil(options.textWidth), 
  --   height = 66*2,
  --   shadeWidth = 7,
  --   cornerRadius = 12*2, 
  --   anchorX = 0, 
  --   anchorY = 0,
  --   color = options.backColor,
  -- })
  -- group.back = back
  local back = display.newRoundedRect( group, 0, 0, 140+math.ceil(options.textWidth), 66*2, 12*2 )
  back.anchorX = 0
  back.anchorY = 0
  back:setStrokeColor( 0,0,0,.1 )
  back.strokeWidth = 3
  back.fill = c.mainButtons
  group.back = back

  local icon = display.newImageRect(group, options.imagePath or "img/search.png", 80, 80 )
  icon.x, icon.y = back.x, back.height*.5
  icon.anchorX = 0
  icon.x = icon.x + 20


  text.parent = group
  text.x = icon.x + icon.width + 15
  text.y = icon.y - 20
  text.align = "left"

  local label = display.newParagraph(options.text1:gsub("\n"," \n "), 60,{
    lineHeight = 1,
    font = "mont_sb",
    size = text.fontSize,
    align = "left",
    color = options.textColor or{0,0,0}
  })
  group:insert( label )
  label.x = text.x
  label.y = text.y - label.height*.5 - 30


  -- text.text = options.text2
  -- text.y = text.y + label.height*.5 + 15
  -- text.font = "mont_m.ttf"
  -- local label = display.newText(text)
  -- label:setFillColor(0)
  -- label.anchorX = 0
  -- label.alpha = .35

  return group
end

local function generateGroupedWikiButtons(options)

  local group = display.newGroup()
  options.parent:insert(group)
  group.y = options.y

  local bufferX = 35
  local bufferY = 30
  local startX = 0 + bufferX
  
  local height = 66*2

  local lastX = startX
  local lastY = 0
  local buttons = {}
  for k, v in pairs(options.buttons) do
    local text = v.label

    local textWidth = getLabelSize({
      font = "mont_sb",
      fontSize = 18*2,
      text = text
    })
    if (lastX + textWidth) >= (q.fullw - bufferX*2) then
      lastX = startX
      lastY = lastY + height + bufferY
    end
    local button = generateButtonWithLogo({
      parent = group,
      x = lastX,
      y = lastY,
      text1 = text,
      imagePath = v.imagePath,
      textWidth = textWidth,
    })
    button.adress = v.adress
    buttons[k] = button
    -- button.specName = v
    -- q.event.add("to"..(v:upper()).."_"..info.name, button, openGroupSpec, "menu-popUp" )
   
    lastX = lastX + (140 + math.ceil(textWidth)) + bufferX
  end

  local scrollEndPoint = display.newRect(group, q.cx, lastY+320, 20, 20)

  return group, buttons
end
local function generateInteristingButton(options)

  local group = display.newGroup()
  options.parent:insert(group)
  group.y = options.y

  local bufferX = 35
  local bufferY = 30
  local startX = 0 + bufferX
  
  local height = 66*2

  local lastX = startX
  local lastY = 0 - height - bufferY
  local buttons = {}
  for k, v in pairs(options.buttons) do
    local text = v.label

    local textWidth = getLabelSize({
      font = "mont_sb",
      fontSize = 18*2,
      text = text
    })
    -- if (lastX + textWidth) >= (q.fullw - bufferX*2) then
      lastX = startX
      lastY = lastY + height + bufferY
    -- end
    local button = generateButtonWithLogo({
      parent = group,
      x = lastX,
      y = lastY,
      text1 = text,
      imagePath = v.imagePath,
      textWidth = q.fullw-210,
    })
    button.adress = v.adress
    buttons[k] = button
    -- button.specName = v
    -- q.event.add("to"..(v:upper()).."_"..info.name, button, openGroupSpec, "menu-popUp" )
   
    lastX = lastX + (140 + math.ceil(textWidth)) + bufferX
  end

  local scrollEndPoint = display.newRect(group, q.cx, lastY+320, 20, 20)
  scrollEndPoint.alpha = .01

  return group, buttons
end

---------------------

local account
local myID, toID, id1, id2, myI

local function htmlRead(text)
  text = text:gsub("<b>","")
  text = text:gsub("</b>","")
  text = text:gsub("<br>","\n")
  text = text:gsub("<br />","")
  print("response:\n"..text)
  return text
end

local function drawInMsg(event)
  if ( event.isError)  then
    print( "Messager load error:", event.response)
    return
  end

  local myNewData = event.response
  -- htmlRead(myNewData)
  -- if text~="[]" then
  --   error(text)
  -- end
  -- print( "response:", myNewData:gsub("<br>","\n"))
  local msg = json.decode( myNewData ) or {}
  local msgIn = {}
  for k,v in pairs(msg) do
    msgIn[tonumber(k)] = v
  end
  for k,v in pairs(msgIn) do
    msgIn[k].fromYou = false
    msgIn[k].i = nil
  end
  -- print( "response:", q.printTable(msgIn))
  
  for k,msg in pairs(msgIn) do
    chat.addMsg(msg)
  end
end


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
    -- print( message )

    if ( event.phase == "down" ) then
      if key=="escape" and nowScene~="menu" and nowScene~="chatlist" then
        -- display.remove(newPopUp)
        pps.removePop()
      end
    end

  end
end
 

local function getMenuButtonsInfo( table )
  local out = {}
  local i = 0
  for k,v in pairs(table) do
  -- for i=1, #numiration do
    if k~="rus" then 
      i = i + 1
      -- print('adress:',k)
      out[i] = {
        adress = k,
        label = v.rus,
        imagePath = "img/miniButtonsLogo/"..k..".png"
      }
    end
  end
  return out
end

local function createButton(group,label,y)
  local submitButton = display.newRoundedRect(group, 50, y, q.fullw-50*2, 80, 50)
  submitButton.anchorX=0
  submitButton.anchorY=1
  submitButton.fill = c.main
  local labelContinue = textWithLetterSpacing( {
    parent = group, 
    text = label, 
    x = submitButton.x+submitButton.width*.5, 
    y = submitButton.y-submitButton.height*.5, 
    font = "fonts/hindv_r.ttf", 
    fontSize = 14*2,
    }, 10, .5)

  return submitButton, labelContinue
end


local function groupView(event)
  if event.y>q.fullh-150 then return end
  local newPopUp = display.newGroup()
  local eventGroupName = pps.popUp("groupedWiki", newPopUp)
  
  local adress
  if type(event)=="string" then
    adress = event
  else
    adress = event.target.adress
  end

  local backLight = display.newRect(newPopUp, q.cx, 0, q.fullw, q.fullh*2)
  backLight.anchorY = 0

  local gV = wikiByAdress(adress)

  local mainLabel = display.newText( {
    parent = newPopUp,
    text = gV.rus,
    x=30,
    y=60,
    font = "ubuntu_m.ttf",
    fontSize = 24*2} )
  mainLabel.fill = c.black  
  mainLabel.anchorX = 0

  local buttonsInfo = {}

  for appName, aV in pairs(gV) do
    if appName~="rus" then
      for themeName, tV in pairs(aV) do
        if themeName~="rus" then
          local adress = adress.." "..appName.." "..themeName
          buttonsInfo[#buttonsInfo+1] = wikiButtonInfoByAdress(adress)

        end
      end
    end
  end

  local buttons = generateWikiButtons{
    parent = newPopUp,
    y = 110+20,
    buttonsInfo = buttonsInfo
  }
  
  for i=1, #buttons do
    buttons[i].adress = buttonsInfo[i].adress
    q.event.add("toWiki-"..buttons[i].adress.."", buttons[i], createWiki, eventGroupName)
  end
  q.event.group.on(eventGroupName)

  if #buttons==0 then
    local mainLabel = display.newText( {
      parent = newPopUp,
      text = "Упс.. мы все еще заполняем этот\nраздел",
      x=30,
      y=150,
      font = "ubuntu_m.ttf",
      fontSize = 20*2} )
    mainLabel.fill = {.4}  
    mainLabel.anchorX = 0
  end
end


local function printServer( event )
  if ( event.isError)  then
    print("Load error:", event.response)
  else
    local myNewData = event.response
    print("!",myNewData)
  end
end

local rusMonthNames = {
  "Января",
  "Февраля",
  "Марта",
  "Апреля",
  "Майя",
  "Июня",
  "Июля",
  "Августа",
  "Сентября",
  "Октября",
  "Ноября",
  "Декабря",
}

local photoForPost = {}
local kraySpase = 30
local inSpase = 20
local max = 3
local ost = (q.fullw - kraySpase*2 - inSpase*(max-1) )/max
local addPhotoButton

local postCreateGroup
local postCreateEventGroupName
local function removePhoto( event )
  -- error("hi")
  local back = event.target
  local i = back.i
  display.remove(photoForPost[i])
  display.remove(back)

  if #photoForPost==max then
    addPhotoButton.alpha = 1
  else
    addPhotoButton.x = addPhotoButton.x - ost - inSpase
  end
  for i=i+1, #photoForPost do
    photoForPost[i].x = photoForPost[i].x - ost - inSpase
    photoForPost[i].back.x = photoForPost[i].x
    photoForPost[i].back.i = photoForPost[i].back.i - 1
  end
  table.remove(photoForPost, i)
end

local photoResponser
local profilePhotoSelect
local inProfilePhoto

if ( media.hasSource( media.PhotoLibrary ) ) then
  local function onSelect(event)
    local photo = event.target
    postCreateGroup:insert(photo)
    photo.x = addPhotoButton.x + ost*.5
    photo.y = 130
    photo.anchorY = 0
    
    if photo.width>photo.height then
      photo.height = ost*(photo.height/photo.width)
      photo.width = ost
    else
      photo.width = ost*(photo.width/photo.height)
      photo.height = ost
    end
    photoForPost[#photoForPost+1] = photo
    
    if max==#photoForPost then
      addPhotoButton.alpha = 0
    else
      addPhotoButton.x = addPhotoButton.x +ost+inSpase
    end

    local back = display.newRect(postCreateGroup, photo.x, photo.y + ost*.5, ost, ost)
    back.fill = {0}
    back.i = #photoForPost
    photo.back = back
    photo:toFront()

    timer.performWithDelay( 10, function()
      local eventName = q.event.add("removePhoto"..back.i, back, removePhoto, postCreateEventGroupName)
      q.event.on(eventName)
    end )
  end
  
  photoResponser = function()
    media.selectPhoto(
    {
      mediaSource = media.PhotoLibrary,
      listener = onSelect, 
    })
  end
  local function photoSelected( event )
    local photo = event.target
    photo.x = q.fullw*-3
    
    local ost = 512
    if photo.width>photo.height then
      photo.height = ost*(photo.height/photo.width)
      photo.width = ost
    else
      photo.width = ost*(photo.width/photo.height)
      photo.height = ost
    end
    display.save( photo, { filename=account.nick:lower().."_logo.png", baseDir=system.DocumentsDirectory, captureOffscreenArea=true, backgroundColor={0,0,0,0} } )
    timer.performWithDelay( 10, function()
      inProfilePhoto.fill = {
        type = "image",
        filename = account.nick:lower().."_logo.png",
        baseDir = system.DocumentsDirectory
      }
      native.showAlert( "Смена фото профиля", "Изменения придут в силу в течении 5-ти минут.")
    end )
  end
  profilePhotoSelect = function()
    media.selectPhoto(
    {
      mediaSource = media.PhotoLibrary,
      listener = photoSelected 
    })
  end
else
  photoResponser = function()
    local photo = display.newImage( "img/tests/1.jpg" )
    postCreateGroup:insert(photo)
    photo.x = addPhotoButton.x + ost*.5
    photo.y = 130
    photo.anchorY = 0
    
    if photo.width>photo.height then
      photo.height = ost*(photo.height/photo.width)
      photo.width = ost
    else
      photo.width = ost*(photo.width/photo.height)
      photo.height = ost
    end
    photoForPost[#photoForPost+1] = photo
    
    if max==#photoForPost then
      addPhotoButton.alpha = 0
    else
      addPhotoButton.x = addPhotoButton.x +ost+inSpase
    end

    local back = display.newRect(postCreateGroup, photo.x, photo.y + ost*.5, ost, ost)
    back.fill = {0}
    back.i = #photoForPost
    photo.back = back
    photo:toFront()

    timer.performWithDelay( 10, function()
      local eventName = q.event.add("removePhoto"..back.i, back, removePhoto, postCreateEventGroupName)
      q.event.on(eventName)
    end )
  end
end


local function createOrangeButton(group, y, text, space, height)
  space = space or 130
  height = height or 90
  local regButton = display.newRoundedRect( group, q.cx, y, q.fullw-space, height, 50)
  regButton.anchorY=1
  regButton.fill = c.appColor

  local labelContinue = display.newText( {
    parent = group, 
    text = text, 
    x = q.cx, 
    y = regButton.y-regButton.height*.5,  
    font = "fonts/hindv_r.ttf", 
    fontSize = 16*2,
  })
  regButton.text = labelContinue

  return regButton
end


local commentsGroup
local function generateMsgs( parent, info )
  if commentsGroup~=nil then display.remove(commentsGroup) end
  commentsGroup = display.newGroup()
  commentsGroup.y = commentsGroup.y + 10
  local allHeight = 0
  -- for i=1, #info.comments do
  for i=1, #info.comments do
    local cmn = info.comments[math.max(1,i-4)]
    local cmn = info.comments[i]

    local back = display.newRect(commentsGroup, q.cx, allHeight, q.fullw, 110)
    back.anchorY = 0
    back.fill={.94 + .3*(i%2)}

    local userImage = display.newCircle( commentsGroup, 25, 20+allHeight, 35 ) 
    userImage.anchorX=0
    userImage.anchorY=0
    userImage.fill = {
      type = "image",
      filename = cmn.imagePath,
      baseDir = system.DocumentsDirectory,
    }

    local userName = display.newText({
      parent = commentsGroup,
      text = cmn.name,
      x = userImage.x+userImage.width+20,
      y = userImage.y+userImage.height*.5,
      font = "fonts/hindv_b.ttf",
      fontSize = 13*2,
      })
    userName.anchorX = 0
    userName.anchorY = 1
    userName:setFillColor( unpack(c.text1) )
    
    -- local date = os.date("*t",tonumber(info.datePost))
    local commentText = display.newText({
      parent = commentsGroup,
      text = cmn.text,
      -- text = ("a b c "):rep(20),
      x = userName.x,
      y = userImage.y+userImage.height*.5,
      font = "fonts/hindv_r.ttf",
      fontSize = 13*2,
      align = "left",
      width = (q.fullw - userImage.x) - 70 - 35
    })
    commentText.anchorX = 0
    commentText.anchorY = 0
    commentText:setFillColor( unpack(c.text1) )
    commentText.alpha = .8

    back.height = back.height + commentText.height - 26
    allHeight = allHeight + back.height
  end

  parent:insert( commentsGroup )
end

local showPeopleAccount
local function openPost( event )
  if event.y>q.fullh-100 then return end
  local info = event.target.info

  local msgField

  local followButton
  local followFilledButton
  local likesLogo
  local likesFilledLogo
  local likesCount 
  
  local authorNick = info.postedBy.name
  local accountPost = allInstaPost[account.nick]
  local authorId
  
  
  local inLike = false
  local inFollow = false

  local thisPost = display.newGroup()
  local eventGroupName = pps.popUp("readPost"..info.postedBy.name.."_"..info.id.."a", thisPost, {
    onShow = function()
      downNavigateGroup.alpha = 0
      if msgField == nil then return end
      msgField.x = msgField.startX
      likesCount.text = info.likes
      
      if followButton == nil then return end

      inLike = false
      for i=1, #accountPost.likeTo do
        if accountPost.likeTo[i]==info.id then
          inLike = true
          break
        end
      end
      if inLike then
        likesLogo.alpha = .01
        likesFilledLogo.alpha = 1
      else
        likesLogo.alpha = 1
        likesFilledLogo.alpha = 0
      end

      inFollow = false
      for i=1, #accountPost.subTo do
        if accountPost.subTo[i]==authorId then
          inFollow = true
          break
        end
      end
      if inFollow then
        followButton.alpha = .01
        followFilledButton.alpha = 1
      else
        followButton.alpha = 1
        followFilledButton.alpha = 0
      end

    end,
    onHide = function()
      msgField.x = msgField.x + 3000
      downNavigateGroup.alpha = 1
      commentsGroup = nil
      -- reloadHomeList()
    end,
  })

  local back = display.newRect(thisPost,q.cx,q.cy,q.fullw,q.fullh)
  back.fill = c.backGround
  
  local postImage
  do
    local group = thisPost
    local y = 100
    local back = display.newRoundedRect(group, q.cx, y, q.fullw-60, 120, 30)
    back.anchorY=0
    back:setStrokeColor( unpack(c.appColor) )
    back.strokeWidth = 3
    back:toBack()

    local adminImage = display.newCircle( group, 50, 20+y, 35 ) 
    adminImage.anchorX=0
    adminImage.anchorY=0
    adminImage.fill = {
      type = "image",
      filename = info.postedBy.image,
      baseDir = system.DocumentsDirectory,
    }
    adminImage.nick = info.postedBy.name
    q.event.add("ShowAccount_"..adminImage.nick.."_post#"..info.id, adminImage, showPeopleAccount, eventGroupName )

    
    if info.postedBy.name == account.nick then
      local uPostImage = display.newImageRect( group, "img/mypost.png",131.5*2.2,2.2*26.44)
      uPostImage.x = q.fullw-50
      uPostImage.y = adminImage.y + adminImage.height*.5
      uPostImage.anchorX = 1
    else
      followButton = display.newImageRect( group, "img/sub0.png",131.5*2.2,2.2*26.44)
      followButton.x = q.fullw-50
      followButton.y = adminImage.y + adminImage.height*.5
      followButton.anchorX = 1

      followFilledButton = display.newImageRect( group, "img/sub1.png",131.5*2.2,2.2*26.44)
      followFilledButton.x = q.fullw-50
      followFilledButton.y = adminImage.y + adminImage.height*.5
      followFilledButton.anchorX = 1
      followFilledButton.alpha = 0
    end

    local adminName = display.newText({
      parent = group,
      text = info.postedBy.name,
      x = adminImage.x+adminImage.width+20,
      y = adminImage.y+adminImage.height*.5,
      font = "fonts/hindv_b.ttf",
      fontSize = 13*2,
      })
    adminName.anchorX = 0
    adminName.anchorY = 1
    adminName:setFillColor( unpack(c.text1) )
    
    local date = os.date("*t",tonumber(info.datePost))
    local dateLabel = display.newText({
      parent = group,
      text = date.day.." "..rusMonthNames[date.month].." "..date.year,
      x = adminName.x,
      y = adminImage.y+adminImage.height*.5,
      font = "fonts/hindv_r.ttf",
      fontSize = 13*2,
      })
    dateLabel.anchorX = 0
    dateLabel.anchorY = 0
    dateLabel:setFillColor( unpack(c.text1) )
    dateLabel.alpha = .6


    postImage = display.newImage( group, authorNick.." "..info.id.." "..(1)..".png", system.DocumentsDirectory, q.cx, dateLabel.y+dateLabel.height + 20 )
    postImage.anchorY = 0

    local ost = q.fullw-100
    if postImage.width>postImage.height then
      postImage.height = ost*(postImage.height/postImage.width)
      postImage.width = ost
    else
      postImage.width = ost*(postImage.width/postImage.height)
      postImage.height = ost
    end
      
    local lastY = postImage.y + postImage.height + 40

    likesLogo = display.newImageRect( group, "img/like0.png", 50, 50)
    likesLogo.x = 60
    likesLogo.y = lastY
    likesLogo.anchorX = 0

    likesFilledLogo = display.newImageRect( group, "img/like1.png", 50, 50)
    likesFilledLogo.x = 60
    likesFilledLogo.y = lastY
    likesFilledLogo.anchorX = 0
    likesFilledLogo.alpha = 0

    likesCount = display.newText(group, (info.likes), likesLogo.x + likesLogo.width + 10, lastY, "fonts/hindv_r.ttf", 40 )
    likesCount:setFillColor( 0 )
    likesCount.anchorX = 0

    local likesButton = display.newRect(group, likesLogo.x-15, lastY, (likesCount.x+likesCount.width+15)-(likesLogo.x-20), 70)
    likesButton.fill = c.hideButtons
    likesButton.anchorX = 0

    
    if followButton then -- Если пост не твой (можешь лайкать и подписываться)

      for i=1, #accountPost.likeTo do
        if accountPost.likeTo[i]==info.id then
          inLike = true
          break
        end
      end
      if inLike then
        likesLogo.alpha = .01
        likesFilledLogo.alpha = 1
      end

      q.event.add("INVIEW_sub_byPost"..authorNick.."_#"..info.id, likesButton, function()
        if inLike==false then
          likesLogo.alpha = 0
          likesFilledLogo.alpha = 1
          accountPost.likeTo[#accountPost.likeTo+1] = info.id
          info.likes = info.likes + 1
        else
          info.likes = info.likes - 1
          likesLogo.alpha = 1
          likesFilledLogo.alpha = 0
          for i=1, #accountPost.likeTo do
            if accountPost.likeTo[i]==info.id then
              table.remove(accountPost.likeTo, i)
              break
            end
          end

        end
        likesCount.text = info.likes
        inLike = not inLike
        q.postConnection("post",allInstaPost)
      end, eventGroupName )

      -- =============
      -- =============
      -- =============
      for mail, infoAcc in pairs(allUsers) do
        if infoAcc.nick==authorNick then
          authorId = infoAcc.id
        end
      end

      for i=1, #accountPost.subTo do
        if accountPost.subTo[i]==authorId then
          inFollow = true
          break
        end
      end
      if inFollow then
        followButton.alpha = .01
        followFilledButton.alpha = 1
      end

      eventName = q.event.add("INVIEW_sub_byPost"..info.postedBy.name.."inPost"..info.id, followButton, function()
        if inFollow==false then
          local postsBy = allInstaPost[info.postedBy.name] 
          postsBy.subcribes = postsBy.subcribes + 1
          accountPost.subTo[#accountPost.subTo+1] = authorId
          followButton.alpha = .01
          followFilledButton.alpha = 1
          print("sub")
        else
          print("unsub")
          local postsBy = allInstaPost[info.postedBy.name] 
          postsBy.subcribes = postsBy.subcribes - 1
          followButton.alpha = 1
          followFilledButton.alpha = 0
          for i=1, #accountPost.subTo do
            if accountPost.subTo[i]==authorId then
              table.remove(accountPost.subTo, i)
              break
            end
          end

        end
        inFollow = not inFollow
        q.postConnection("post",allInstaPost)
      end, eventGroupName )

    else -- Если пост мой
      likesLogo.alpha = 0
      likesFilledLogo.alpha = 1
      likesFilledLogo:setFillColor( .3,.7,.7 )
    end
    
    back.height = 120+postImage.height + 40 + 30
  end

  local back = display.newRect(thisPost,q.cx,postImage.y, q.fullw-100, postImage.height )
  back.anchorY = 0
  back.fill = {0,.78}
  postImage:toFront( )

  local mainText = display.newText({
    parent = thisPost,
    text = info.title,
    x = 55,
    y = postImage.y + postImage.height + 80,
    font = "fonts/hindv_b.ttf",
    align = "left",
    width = q.fullw-100,
    fontSize = 30,
  })
  mainText:setFillColor( 0 )
  mainText.anchorX = 0
  mainText.anchorY = 0

  local discText = display.newText({
    parent = thisPost,
    text = info.text,
    x = 55,
    y = mainText.y + mainText.height + 10,
    font = "fonts/hindv_r.ttf",
    align = "left",
    width = q.fullw-100,
    fontSize = 30,
  })
  discText:setFillColor( 0 )
  discText.anchorX = 0
  discText.anchorY = 0

  local commentsLabel = display.newText({
    parent = thisPost,
    text = "Комментарии",
    x = q.cx,
    y = discText.y + discText.height + 50,
    font = "fonts/hindv_r.ttf",
    fontSize = 30,
  })
  commentsLabel:setFillColor( 0 )
  commentsLabel.anchorY = 0

  local top = commentsLabel.y+commentsLabel.height+15
  local height = q.fullh-top-100
  local scrollView = widget.newScrollView(
  {
    top = top,
    left = 0,
    width = q.fullw,
    height = height,
    horizontalScrollDisabled = true,
    -- verticalScrollDisabled = true,
    hideBackground = true,
  })
  thisPost:insert(scrollView)

  -- local allHeight = 50
  do
    local allHeight = q.fullh - 20 
    local rounded = display.newRoundedRect( thisPost, 30, allHeight, q.fullw-170, 70, 30 )
    rounded.anchorX = 0
    rounded.anchorY = 1
    rounded.fill = c.gray2

    local send = display.newRoundedRect( thisPost, rounded.x+rounded.width+20, allHeight, q.fullw-(rounded.x+rounded.width+20*2), rounded.height, 40 )
    send.anchorX = 0
    send.anchorY = 1
    send.fill = c.appColor
   

    local scrollChatOn = false
    
    -- local function moveFieldsDown()
    --   timer.performWithDelay(100, function()
    --     transition.to( inTextGroup, { time=200, y=inTextGroup.startY} )
    --   end)
    -- end
    -- local function moveFieldsUp()
    --   transition.to( inTextGroup, { time=200, y=q.fullh-keyboardOffset-150-200+20} )
    -- end

    q.event.add("sendMsg", send, function()
      local text = q.trim(msgField.text)

      if text~="" then 
        native.setKeyboardFocus( nil )
        info.comments[#info.comments+1] = {
          name = account.nick,
          date = os.time(),
          text = text,
        }        
        -- allChats.ready = true
        msgField.text = ""
        generateMsgs(scrollView, info)
        q.postConnection("post",allInstaPost)
        -- q.postConnection("chats",allChats)
        -- scrollView:insert(msgGroup)
      end
    end, eventGroupName )

    local function moveDescription(event) 
      if event.phase == "began" then
      elseif event.phase == "editing" then
      elseif event.phase == "submitted" then
      end
    end

    -- local fakeFieldLabel = display.newText({
    --   parent = thisPost,
    --   x = rounded.x+20,
    --   y = rounded.height*.5,
    --   text = "Ваш комментарий",
    --   font = "fonts/hindv_r.ttf",
    -- })
    -- fakeFieldLabel.anchorX = 0
    -- fakeFieldLabel:setFillColor( 0 )
    msgField = native.newTextField(rounded.x+20-3000, allHeight-rounded.height*.5, rounded.width-20*2, 200)
    -- commentsGroup:insert( msgField )
    -- msgField = native.newTextField(rounded.x+20-3000, q.fullh - 50, rounded.width-20*2, 200)
    thisPost:insert( msgField )
    msgField.anchorX=0

    msgField.startX=msgField.x+3000
    msgField.hasBackground = false
    msgField.placeholder = "Ваш комментарий"

    msgField.font = native.newFont( "ubuntu_r.ttf",20*2)

    msgField:resizeHeightToFitFont()
    msgField:setTextColor( 0, 0, 0 )
    msgField:addEventListener( "userInput", moveDescription )
    msgField.x=msgField.startX

    local sendIco = display.newImageRect( thisPost, "img/send.png", 45, 45 )
    sendIco.x, sendIco.y = send.x+send.width*.5+5, send.y-send.height*.5

  end
  generateMsgs(scrollView, info)
 
  -- scrollView:toBack( )

  -- mainListGroup = display.newGroup()
  -- mainListGroup.scrollGroup = scrollView

  q.event.group.on(eventGroupName)
end

local function createPost()
  if not allUsers then return end
  downNavigateGroup.alpha = 0
  postCreateGroup = display.newGroup()
  local eventGroupName = pps.popUp("postCreate", postCreateGroup, {
    onShow = function()
      downNavigateGroup.alpha = 0
    end,
    onHide = function()
      downNavigateGroup.alpha = 1
      -- for i=1, #photoForPost do
      --   q.deleteFile("forPost"..i..".jpg", system.TemporaryDirectory)
      -- end
      
      -- q.event.group.on("home-popUp")
    end,
  })
  postCreateEventGroupName = eventGroupName
  local back = display.newRect(postCreateGroup,q.cx,q.cy,q.fullw,q.fullh)
  back.fill = c.backGround

  
  
  addPhotoButton = display.newImageRect( postCreateGroup, "img/addphoto.png", ost, ost )
  addPhotoButton.anchorY = 0
  addPhotoButton.anchorX = 0
  addPhotoButton.x = kraySpase
  addPhotoButton.y = 130

  local backTitle = display.newRoundedRect(postCreateGroup, q.cx, 425, q.fullw-40*2, 590, 30)
  backTitle.anchorY=0
  backTitle.fill = q.CL"F3F3F3"
  backTitle:setStrokeColor( unpack(q.CL"A1A1A1") )
  backTitle.strokeWidth = 5

  local titleField = native.newTextField(65, backTitle.y+45, back.width-120, 90)
  postCreateGroup:insert( titleField )
  titleField.anchorX=0
  titleField.pos = {x=titleField.x, y=titleField.y}
  titleField.isEditable = true
  titleField.hasBackground = false
  titleField.placeholder = "Заголовок поста"
  titleField.font = native.newFont( "fonts/hindv_b.ttf", 30 )
  titleField:resizeHeightToFitFont()
  titleField:setTextColor( 0, 0, 0 )

  local longField = native.newTextBox(65, titleField.y+titleField.height-10, back.width-120, 490)
  postCreateGroup:insert( longField )
  longField.anchorX = 0
  longField.anchorY = 0
  longField.pos = {x=longField.x, y=longField.y}
  longField.isEditable = true
  longField.hasBackground = false
  longField.placeholder = "Описание поста"
  longField.font = native.newFont( "fonts/hindv_r.ttf", 30 )
  longField:setTextColor( 0, 0, 0 )

  local space = 40
  local height = 90
  local publicateButton = display.newRoundedRect( postCreateGroup, space, backTitle.y+backTitle.height+120, q.fullw-space*2, height, 50)
  publicateButton.anchorX=0
  publicateButton.anchorY=1
  publicateButton.fill = c.appColor

  local labelContinue = display.newText( {
    parent = postCreateGroup, 
    text = "Опубликовать", 
    x = q.cx, 
    y = publicateButton.y-publicateButton.height*.5,  
    font = "fonts/hindv_r.ttf", 
    fontSize = 16*2,
  })
  
  q.event.add("addPhoto", addPhotoButton, photoResponser, eventGroupName)

  q.event.add("publishPost", publicateButton, function()
    if #photoForPost==0 then return end 

    local time = os.time()
    
    local idNew
    if allInstaPost[account.nick]==nil then error(account.nick) end
    if allInstaPost[account.nick].post[1]~=nil then
      print("had to check")
      idNew = allInstaPost[account.nick].post[1].id
      for i=2, #allInstaPost[account.nick].post do
        local id = allInstaPost[account.nick].post[i].id
        idNew = math.max(idNew,id)
      end
    else
      idNew = 0
    end
    idNew = idNew + 1
    
    allInstaPost[account.nick].post[#allInstaPost[account.nick].post+1] = {
      title = titleField.text,
      datePost = time,
      text = longField.text,
      id = idNew,
      images = #photoForPost,
      likes = 0,
      comments = {},
    }
    q.postConnection("post",allInstaPost)

    for i=1, #photoForPost do
      local photo = photoForPost[i]
      local ost = q.fullw
      photo.x = q.fullw*-3
      if photo.width>photo.height then
        photo.height = ost*(photo.height/photo.width)
        photo.width = ost
      else
        photo.width = ost*(photo.width/photo.height)
        photo.height = ost
      end
  
      display.save( photo, { filename=account.nick.." "..idNew.." "..i..".png", baseDir=system.DocumentsDirectory, captureOffscreenArea=true, backgroundColor={0,0,0,0} } )
    end
    photoForPost = {}
    
    timer.performWithDelay( 1, pps.removePop)  
  end, eventGroupName)
  q.event.group.on(eventGroupName)
end

local function discriptionPopUp( event )
  local changingGroup = display.newGroup()
  local eventGroupName = pps.popUp("changeDiscription", changingGroup)

  local backZone = display.newRect(changingGroup,q.cx,100,q.fullw,q.fullh-720)
  backZone.anchorY = 0
  backZone.alpha = .01
  
  q.event.add("backToProfile", backZone, pps.removePop, eventGroupName)

  local backBlack = display.newRect(changingGroup,q.cx,q.cy,q.fullw,q.fullh)
  backBlack.fill = {0,0,0,0}
  transition.to(backBlack.fill, {a = .2, time=200})


  local slideUpGroup = display.newGroup()
  changingGroup:insert(slideUpGroup)
  slideUpGroup.y=q.fullh
  transition.to(slideUpGroup, {y = q.fullh-680, time=300})

  local back = display.newRoundedRect(slideUpGroup, q.cx, 0, q.fullw, 650, 60)
  back.anchorY = 0
  back.fill = c.backGround

  local editorLabel = display.newText({
    parent = slideUpGroup,
    text = "Описание профиля",
    x = 50,
    y = 30,
    font = "hindv_b.ttf",
    fontSize = 32,
  })
  editorLabel.anchorX = 0
  editorLabel.anchorY = 0
  editorLabel:setFillColor( unpack(c.text1) )

  local backTitle = display.newRoundedRect(slideUpGroup, q.cx, 100, q.fullw-40*2, 290, 30)
  backTitle.anchorY=0
  backTitle.fill = c.backGround
  backTitle:setStrokeColor( unpack(c.text1) )
  backTitle.alpha = .5
  backTitle.strokeWidth = 5

  local myAccountPost = allInstaPost[account.nick]
  local longField = native.newTextBox(q.cx, 120, backTitle.width-40, 250)
  slideUpGroup:insert( longField )
  longField.anchorY = 0
  longField.pos = {x=longField.x, y=longField.y}
  longField.isEditable = true
  longField.hasBackground = false
  longField.placeholder = "Введите описание"
  longField.text = myAccountPost.discription
  longField.font = native.newFont( "fonts/hindv_r.ttf", 30 )
  longField:setTextColor( 0, 0, 0 )

  local button, label = createButton(slideUpGroup, "СОХРАНИТЬ", backTitle.y+backTitle.height+110)

  q.event.add("saveDiscription", button, function()
    allInstaPost[account.nick].discription = longField.text
    q.postConnection("post",allInstaPost)
    pps.removePop()

  end, eventGroupName)

  q.event.group.on(eventGroupName)
end

showPeopleAccount = function(event)
  local otherAcoountGroup = display.newGroup()
  
  local inFollow = false
  local inNotif = false
  local notifButton
  local notifFilledButton
  local followButton
  local followFilledButton

  local changeDiscription

  local subcribesNumber
  local postsNumber
  local subscribeOnSomebodyNumber
  local userDisc

  local nick = event.target.nick
  local accountPost = allInstaPost[nick]
  local myAccountPost = allInstaPost[account.nick]
  local account = allUsers[account.mail]

  local authorId
  for mail, infoAcc in pairs(allUsers) do
    if infoAcc.nick==nick then
      authorId = infoAcc.id
    end
  end

  local eventGroupName = pps.popUp("showPeopleAccount", otherAcoountGroup, {
    onShow = function()
      if subcribesNumber==nil then return end
      subcribesNumber.text = accountPost.subcribes
      postsNumber.text = #accountPost.post
      subscribeOnSomebodyNumber.text = #accountPost.subTo

      userDisc.text = accountPost.discription or "error: no discription"
      if followButton==nil then return end

      inFollow = false
      for i=1, #myAccountPost.subTo do
        if myAccountPost.subTo[i]==authorId then
          inFollow = true
          break
        end
      end
      if inFollow then
        followButton.alpha = .01
        followFilledButton.alpha = 1
      else
        followButton.alpha = 1
        followFilledButton.alpha = 0
      end

      inNotif = false
      for i=1, #myAccountPost.notifTo do
        if myAccountPost.notifTo[i]==authorId then
          inNotif = true
          break
        end
      end
      if inNotif then
        notifButton.alpha = .01
        notifFilledButton.alpha = 1
      else
        notifButton.alpha = 1
        notifFilledButton.alpha = 0
      end
    end,
    -- onHide = reloadHomeList,
  })


  local back = display.newRect(otherAcoountGroup,q.cx,q.cy,q.fullw,q.fullh)
  back.fill = q.CL"F8F8F8"--c.backGround

  local profilePhoto = display.newCircle( otherAcoountGroup, 50, 100+50, 80 ) 
  profilePhoto.anchorX=0
  profilePhoto.anchorY=0
  profilePhoto.fill = {
    type = "image",
    filename = nick:lower().."_logo.png",
    baseDir = system.DocumentsDirectory,
  }

  local userNick = display.newText({
    parent = otherAcoountGroup,
    text = nick,
    x = profilePhoto.x,
    y = profilePhoto.y + profilePhoto.height + 30,
    font = "hindv_b.ttf",
    fontSize = 32,
  })
  userNick.anchorX = 0
  userNick.anchorY = 0
  userNick:setFillColor( unpack(c.text1) )

  userDisc = display.newText({
    parent = otherAcoountGroup,
    text = accountPost.discription or "error: no discription",
    x = profilePhoto.x,
    y = userNick.y + userNick.height + 20,
    align = "left",
    width = 300,
    font = "hindv_r.ttf",
    fontSize = 26,
  })
  userDisc.anchorX = 0
  userDisc.anchorY = 0
  userDisc:setFillColor( unpack(c.text1) )

  if nick ~= account.nick then
    notifButton = display.newImageRect( otherAcoountGroup, "img/notif0.png",131.5*2.2,2.2*26.44)
    notifButton.x = q.fullw-50
    notifButton.y = userNick.y
    notifButton.anchorX = 1
    notifButton.anchorY = 0

    notifFilledButton = display.newImageRect( otherAcoountGroup, "img/notif1.png",131.5*2.2,2.2*26.44)
    notifFilledButton.x = notifButton.x
    notifFilledButton.y = notifButton.y
    notifFilledButton.anchorX = 1
    notifFilledButton.anchorY = 0
    notifFilledButton.alpha = 0

    followButton = display.newImageRect( otherAcoountGroup, "img/sub0.png",131.5*2.2,2.2*26.44)
    followButton.x = q.fullw-50
    followButton.y = userNick.y+70
    followButton.anchorX = 1
    followButton.anchorY = 0

    followFilledButton = display.newImageRect( otherAcoountGroup, "img/sub1.png",131.5*2.2,2.2*26.44)
    followFilledButton.x = followButton.x
    followFilledButton.y = followButton.y
    followFilledButton.anchorX = 1
    followFilledButton.anchorY = 0
    followFilledButton.alpha = 0

    

    for i=1, #myAccountPost.subTo do
      if myAccountPost.subTo[i]==authorId then
        inFollow = true
        break
      end
    end
    if inFollow then
      followButton.alpha = .01
      followFilledButton.alpha = 1
    end

    q.event.add("subTo"..nick.."_profile", followButton, function()
      local postsBy = allInstaPost[nick] 
      if inFollow==false then
        postsBy.subcribes = postsBy.subcribes + 1
        followButton.alpha = .01
        followFilledButton.alpha = 1
        myAccountPost.subTo[#myAccountPost.subTo+1] = authorId
        print("sub")
      else
        print("unsub")
        postsBy.subcribes = postsBy.subcribes - 1
        followButton.alpha = 1
        followFilledButton.alpha = 0
        for i=1, #myAccountPost.subTo do
          if myAccountPost.subTo[i]==authorId then
            table.remove(myAccountPost.subTo, i)
            break
          end
        end

      end
      inFollow = not inFollow
      q.postConnection("post",allInstaPost)
    end, eventGroupName )

    -- =================


    for i=1, #myAccountPost.notifTo do
      if myAccountPost.notifTo[i]==authorId then
        inNotif = true
        break
      end
    end
    if inNotif then
      notifButton.alpha = .01
      notifFilledButton.alpha = 1
    end

    q.event.add("notifTo"..nick.."_profile", notifButton, function()

      local postsBy = allInstaPost[nick] 
      if inNotif==false then
        notifButton.alpha = .01
        notifFilledButton.alpha = 1
        myAccountPost.notifTo[#myAccountPost.notifTo+1] = authorId
        print("notif")
      else
        print("un-notif")
        notifButton.alpha = 1
        notifFilledButton.alpha = 0
        for i=1, #myAccountPost.notifTo do
          if myAccountPost.notifTo[i]==authorId then
            table.remove(myAccountPost.notifTo, i)
            break
          end
        end

      end
      q.postConnection("post",allInstaPost)
    end, eventGroupName )
  else
    changeDiscription = display.newImageRect( otherAcoountGroup, "img/editbutton.png",131.5*2.2,2.2*26.44)
    changeDiscription.x = userDisc.x + userDisc.width + 50
    changeDiscription.y = userDisc.y
    changeDiscription.anchorX = 0
    changeDiscription.anchorY = 0
    q.event.add("changeDiscription_"..nick, changeDiscription, discriptionPopUp, eventGroupName )
  end

  local spase = 1
  local y = profilePhoto.y+profilePhoto.height*.5
  
  subcribesNumber = display.newText({
    parent = otherAcoountGroup,
    text = accountPost.subcribes,
    x = profilePhoto.x+profilePhoto.width+130,
    y = y - spase*.5,
    font = "hindv_b.ttf",
    fontSize = 40,
    align = "center"
  })
  subcribesNumber.anchorY = 1
  subcribesNumber:setFillColor( unpack(c.text1) )

  local subcribesLabel = display.newText({
    parent = otherAcoountGroup,
    text = "подписчиков",
    x = subcribesNumber.x,
    y = y + spase*.5,
    font = "hindv_r.ttf",
    fontSize = 25,
    align = "center"
  })
  subcribesLabel.anchorY = 0
  subcribesLabel:setFillColor( unpack(c.text1) )

  postsNumber = display.newText({
    parent = otherAcoountGroup,
    text = #accountPost.post,
    x = subcribesLabel.x + 150,
    y = y - spase*.5,
    font = "hindv_b.ttf",
    fontSize = 40,
    align = "center"
  })
  postsNumber.anchorY = 1
  postsNumber:setFillColor( unpack(c.text1) )

  local postsLabel = display.newText({
    parent = otherAcoountGroup,
    text = "постов",
    x = postsNumber.x,
    y = y + spase*.5,
    font = "hindv_r.ttf",
    fontSize = 25,
    align = "center"
  })
  postsLabel.anchorY = 0
  postsLabel:setFillColor( unpack(c.text1) )

  
  subscribeOnSomebodyNumber = display.newText({
    parent = otherAcoountGroup,
    text = #accountPost.subTo,
    x = postsNumber.x + 150,
    y = y - spase*.5,
    font = "hindv_b.ttf",
    fontSize = 40,
    align = "center"
  })
  subscribeOnSomebodyNumber.anchorY = 1
  subscribeOnSomebodyNumber:setFillColor( unpack(c.text1) )

  local subscribeOnSomebodyLabel = display.newText({
    parent = otherAcoountGroup,
    text = "подписок",
    x = subscribeOnSomebodyNumber.x,
    y = y + spase*.5,
    font = "hindv_r.ttf",
    fontSize = 25,
    align = "center"
  })
  subscribeOnSomebodyLabel.anchorY = 0
  subscribeOnSomebodyLabel:setFillColor( unpack(c.text1) )

  local outSpace = 20
  local inSpace = 10
  local on1lineCount = 3
  local size = (q.fullw-outSpace*2-inSpace*(on1lineCount-1) ) / on1lineCount

  local startY = math.max(userDisc.y + userDisc.height + 50, (followFilledButton and followFilledButton.y or 0) + 90)


  local userPostsScrollView = widget.newScrollView(
  {
    top = startY-10,
    left = 0,
    width = q.fullw,
    height = q.fullh-125-startY+10,
    horizontalScrollDisabled = true,
    -- verticalScrollDisabled = true,
    hideBackground = true,
    -- backgroundColor = {1,0,0,.2}, 
  })
  otherAcoountGroup:insert( userPostsScrollView )
  local content = display.newGroup()
  local startY = 10
  -- for i=1, 10 do
  for i=1, #accountPost.post do
    local x = (i-1)%3+1
    local y = math.floor((i-1)/3)+1
    
    local container = display.newContainer( content, size, size )
    container.x, container.y = outSpace+(size+inSpace)*(x-1), startY+(size+inSpace)*(y-1)
    container.anchorX = 0
    container.anchorY = 0

    local postImage = display.newImage( container, nick.." "..accountPost.post[i].id.." 1.png", system.DocumentsDirectory, 0, 0 )

    local ost = size
    if postImage.width<postImage.height then
      postImage.height = ost*(postImage.height/postImage.width)
      postImage.width = ost
    else
      postImage.width = ost*(postImage.width/postImage.height)
      postImage.height = ost
    end

    postImage.info = accountPost.post[i]
    local eventName = q.event.add("open"..nick.."inPost"..(i).."byProfile", postImage, openPost, eventGroupName )
    -- q.event.on(eventName)

    -- local rect = display.newRect(container, 0, 0, size, size)
    -- rect.fill = {.4}
  end
  userPostsScrollView:insert(content)
  q.event.group.on(eventGroupName)
end

local followOnAccount = {
  -- nick = {isFollowed = false, buttons = {{clearButton, fillButton}}}
}
local function createInstaPostButton(group, y, info, eventGroupName, eventTable)
  if not allUsers then return end
  local authorNick = info.postedBy.name

  local back = display.newRoundedRect(group, q.cx, y, q.fullw-60, 120, 30)
  back.anchorY=0
  back:setStrokeColor( unpack(c.appColor) )
  back.strokeWidth = 3
  back:toBack()

  local adminImage = display.newCircle( group, 50, 20+y, 35 ) 
  adminImage.anchorX=0
  adminImage.anchorY=0
  adminImage.fill = {
    type = "image",
    filename = info.postedBy.image,
    baseDir = system.DocumentsDirectory,
  }

  adminImage.nick = info.postedBy.name
  eventTable[#eventTable+1] = q.event.add("ShowAccount_"..authorNick.."_post#"..info.id, adminImage, showPeopleAccount, eventGroupName )


  local followButton
  local followFilledButton
  if info.postedBy.name == account.nick then
    followButton = display.newImageRect( group, "img/mypost.png",131.5*2.2,2.2*26.44)
    followButton.x = q.fullw-50
    followButton.y = adminImage.y + adminImage.height*.5
    followButton.anchorX = 1
  else
    followOnAccount[authorNick] = followOnAccount[authorNick] or {inFollow=false, buttons = {}}
    followButton = display.newImageRect( group, "img/sub0.png",131.5*2.2,2.2*26.44)
    followButton.x = q.fullw-50
    followButton.y = adminImage.y + adminImage.height*.5
    followButton.anchorX = 1

    followFilledButton = display.newImageRect( group, "img/sub1.png",131.5*2.2,2.2*26.44)
    followFilledButton.x = q.fullw-50
    followFilledButton.y = adminImage.y + adminImage.height*.5
    followFilledButton.anchorX = 1
    followFilledButton.alpha = 0

    followOnAccount[authorNick].buttons[#followOnAccount[authorNick].buttons+1] = {followButton, followFilledButton}
  end

  local adminName = display.newText({
    parent = group,
    text = info.postedBy.name,
    x = adminImage.x+adminImage.width+20,
    y = adminImage.y+adminImage.height*.5,
    font = "fonts/hindv_b.ttf",
    fontSize = 13*2,
    })
  adminName.anchorX = 0
  adminName.anchorY = 1
  adminName:setFillColor( unpack(c.text1) )
  
  local date = os.date("*t",tonumber(info.datePost))
  local dateLabel = display.newText({
    parent = group,
    text = date.day.." "..rusMonthNames[date.month].." "..date.year,
    x = adminName.x,
    y = adminImage.y+adminImage.height*.5,
    font = "fonts/hindv_r.ttf",
    fontSize = 13*2,
    })
  dateLabel.anchorX = 0
  dateLabel.anchorY = 0
  dateLabel:setFillColor( unpack(c.text1) )
  dateLabel.alpha = .6


  local postImage = display.newImage( group, authorNick.." "..info.id.." "..(1)..".png", system.DocumentsDirectory, q.cx, dateLabel.y+dateLabel.height + 20 )
  postImage.anchorY = 0

  local ost = q.fullw-100
  if postImage.width>postImage.height then
    postImage.height = ost*(postImage.height/postImage.width)
    postImage.width = ost
  else
    postImage.width = ost*(postImage.width/postImage.height)
    postImage.height = ost
  end
    
  local lastY = postImage.y + postImage.height + 40

  local likesLogo = display.newImageRect( group, "img/like0.png", 50, 50)
  likesLogo.x = 60
  likesLogo.y = lastY
  likesLogo.anchorX = 0

  local likesFilledLogo = display.newImageRect( group, "img/like1.png", 50, 50)
  likesFilledLogo.x = 60
  likesFilledLogo.y = lastY
  likesFilledLogo.anchorX = 0
  likesFilledLogo.alpha = 0

  local likesCount = display.newText(group, (info.likes), likesLogo.x + likesLogo.width + 10, lastY, "fonts/hindv_r.ttf", 40 )
  likesCount:setFillColor( 0 )
  likesCount.anchorX = 0

  local likesButton = display.newRect(group, likesLogo.x-15, lastY, (likesCount.x+likesCount.width+15)-(likesLogo.x-20), 70)
  likesButton.fill = c.hideButtons
  likesButton.anchorX = 0

  local commentsLogo = display.newImageRect( group, "img/postchat.png", 50, 50)
  commentsLogo.x = likesCount.x + likesCount.width + 40
  commentsLogo.y = lastY
  commentsLogo.anchorX = 0

  local commentsCount = display.newText(group, #info.comments, commentsLogo.x + commentsLogo.width + 10, lastY, "fonts/hindv_r.ttf", 40 )
  commentsCount:setFillColor( 0 )
  commentsCount.anchorX = 0

  local accountPost = allInstaPost[account.nick]
  if followFilledButton then -- Если пост не твой (можешь лайкать и подписываться)

    local inLike = false
    for i=1, #accountPost.likeTo do
      if accountPost.likeTo[i]==info.id then
        inLike = true
        break
      end
    end
    if inLike then
      likesLogo.alpha = 0
      likesFilledLogo.alpha = 1
    end

    eventTable[#eventTable+1] = q.event.add("lik_post_by"..authorNick.."_#"..info.id, likesButton, function()
      if inLike==false then
        likesLogo.alpha = 0
        likesFilledLogo.alpha = 1
        accountPost.likeTo[#accountPost.likeTo+1] = info.id
        info.likes = info.likes + 1
      else
        info.likes = info.likes - 1
        likesLogo.alpha = 1
        likesFilledLogo.alpha = 0
        for i=1, #accountPost.likeTo do
          if accountPost.likeTo[i]==info.id then
            table.remove(accountPost.likeTo, i)
            break
          end
        end

      end
      likesCount.text = info.likes
      inLike = not inLike
      -- q.postConnection
      -- q.saveLogin(account)
      q.postConnection("post",allInstaPost)
    end, eventGroupName )
    -- postsEvents[#postsEvents+1] = eventName

    -- =============
    -- =============
    -- =============

    local authorId
    for mail, infoAcc in pairs(allUsers) do
      if infoAcc.nick==authorNick then
        authorId = infoAcc.id
      end
    end

    local inFollow = followOnAccount[authorNick].inFollow
    for i=1, #accountPost.subTo do
      if accountPost.subTo[i]==authorId then
        inFollow = true
        break
      end
    end
    if inFollow then
      followButton.alpha = .01
      followFilledButton.alpha = 1
    end

    eventTable[#eventTable+1] = q.event.add("subTo"..info.postedBy.name.."inPost"..info.id, followButton, function()
      local postsBy = allInstaPost[info.postedBy.name] 
      if inFollow==false then
        postsBy.subcribes = postsBy.subcribes + 1
        for i,buttons in ipairs(followOnAccount[authorNick].buttons) do
          buttons[1].alpha = .01
          buttons[2].alpha = 1
        end
        accountPost.subTo[#accountPost.subTo+1] = authorId
        print("sub")
      else
        print("unsub")
        postsBy.subcribes = postsBy.subcribes - 1
        for i,buttons in ipairs(followOnAccount[authorNick].buttons) do
          buttons[1].alpha = 1
          buttons[2].alpha = 0
        end
        for i=1, #accountPost.subTo do
          if accountPost.subTo[i]==authorId then
            table.remove(accountPost.subTo, i)
            break
          end
        end

      end
      inFollow = not inFollow
      q.postConnection("post",allInstaPost)
    end, eventGroupName )
    -- postsEvents[#postsEvents+1] = eventName
  else
    likesLogo.alpha = 0
    likesFilledLogo.alpha = 1
    likesFilledLogo:setFillColor( .3,.7,.7 )
  end

  back.height = 120+postImage.height + 40 + 30

  postImage.info = info
  postImage.buttons = {
    like = {
      clear = likesLogo,
      fill = likesFilledLogo,
      label = likesCount,
    },
    comments = {
      clear = commentsLogo,
      label = commentsCount,
    }
  }
  eventTable[#eventTable+1] = q.event.add("open"..info.postedBy.name.."inPost"..info.id, postImage, openPost, eventGroupName )
  -- q.event.on(eventName)
  -- postsEvents[#postsEvents+1] = eventName

  return back, postImage, likesButton

end

local homeListY
local homeListCroll

local function createAllInstaPost()
  if not allUsers then error("AllUsers is nil") end

  local homeListGroup = display.newGroup()
  local eventGroupName, eventTable = pps.reload("home", homeListGroup)

  homeListCroll = widget.newScrollView(
  {
    top = 100,
    left = 0,
    width = q.fullw,
    height = q.fullh-175-50,
    horizontalScrollDisabled = true,
    hideBackground = true,
    friction = .98,
  })
  homeListCroll:toBack( )

  eventTable[#eventTable+1] = q.event.add("nothing",homeListCroll, function()end, eventGroupName)
  

  local mainListGroup = display.newGroup()
  -- mainListGroup.scrollGroup = homeListCroll
  
  local allHeight = 20
  local spaceY = 30

  for k, v in pairs( allInstaPost ) do
    for i=1, #v.post do
      allInstaPost[k].post[i].postedBy = {name=k,image=k:lower().."_logo.png"}
      allHeight = allHeight + spaceY + createInstaPostButton(mainListGroup, allHeight, v.post[i], eventGroupName, eventTable).height
    end
    print(k,q.printTable(v))

  end
  homeListCroll:insert(mainListGroup)
  homeListGroup:insert(homeListCroll)

  local scrollEndPoint = display.newRect( mainListGroup, q.cx, mainListGroup.y + mainListGroup.height + 50, 20, 20)
  scrollEndPoint.alpha = 0
  
  if homeListY then
    homeListCroll:scrollToPosition( {y = homeListY, time = 0} )
  end
  q.event.group.on(eventGroupName)
  print("\ncreateALL Onning")
end

local function loadAllUsers( event )
  if ( event.isError)  then
    print( "Error!", event.response)
    return false
  else
    local myNewData = event.response
    if myNewData==nil or myNewData=="[]" then
      print("Server read: нет ответа")
      return false
    end
    allUsers = json.decode(myNewData)
    print("getallusers from ethernet")
    createAllInstaPost()
    loadAllUsers = nil
  end
  return true
end

local function showSubTo( event )
  local subToGroup = display.newGroup()
  local eventGroupName, eventTable = pps.reload("subcribes", subToGroup)

  local myAccountPost = allInstaPost[account.nick]
  local account = allUsers[account.mail]

  local back = display.newRect(subToGroup,q.cx,q.cy,q.fullw,q.fullh)
  back.fill = {1,1,1,.01}
  eventTable[#eventTable+1] = q.event.add("lol", back, function()end, eventGroupName)

  local sortedByID = {} 
  for nick, infoAcc in pairs( allInstaPost ) do
    local id = infoAcc.id
    sortedByID[tonumber(id)] = infoAcc
    sortedByID[tonumber(id)].nick = nick
  end

  local allscrollView = widget.newScrollView(
  {
    top = 100,
    left = 0,
    width = q.fullw,
    height = q.fullh-175-50,
    horizontalScrollDisabled = true,
    -- verticalScrollDisabled = true,
    hideBackground = true,
  })
  -- allscrollView:toBack( )
  subToGroup:insert( allscrollView )

  local allcontent = display.newGroup()
  allcontent.scrollGroup = allscrollView

  local backForTouch = display.newRect(allcontent, q.cx, 0, q.fullw,1) 
  backForTouch.alpha = .01
  backForTouch.anchorY = 0

  local startY = 130 - 100
  local outSpase = 40
  local inSpase = 40
  local countOnScreen = 3
  local size = (q.fullw-outSpase-inSpase*(countOnScreen-1 +1) ) / countOnScreen 
  for i=1, #myAccountPost.subTo do
  -- for i=1, 12 do
    
    local hisPostAccount = sortedByID[myAccountPost.subTo[i]]
    -- local hisPostAccount = sortedByID[myAccountPost.subTo[1]]

    local hisLogo = display.newCircle( allcontent, 30, startY, 40 ) 
    hisLogo.anchorX=0
    hisLogo.anchorY=0
    hisLogo.fill = {
      type = "image",
      filename = hisPostAccount.nick:lower().."_logo.png",
      baseDir = system.DocumentsDirectory,
    }
    hisLogo.nick = hisPostAccount.nick
    eventTable[#eventTable+1] = q.event.add("ShowAccount_"..hisLogo.nick.."_bySubMenu", hisLogo, showPeopleAccount, eventGroupName )

    local nickLabel = display.newText({
      parent = allcontent,
      text = hisPostAccount.nick,
      x = hisLogo.x+hisLogo.width+20,
      y = startY+hisLogo.height*.5,
      font = "hindv_b.ttf",
      fontSize = 35,
    })
    nickLabel.anchorX = 0
    nickLabel:setFillColor( unpack(c.text1) )
    
    local scrollView = widget.newScrollView(
    {
      top = startY+hisLogo.height+20,
      height = size+20,
      left = 0,
      width = q.fullw,
      rightPadding = outSpase+inSpase,
      -- horizontalScrollDisabled = true,
      verticalScrollDisabled = true,
      hideBackground = true,
    })
    allcontent:insert(scrollView)
    local content = display.newGroup()

    -- local back = display.newRect(content,q.cx,q.cy,q.fullw,q.fullh)
    -- back.fill = {1,0,0,.2}

    print(q.printTable(hisPostAccount))
    local posts = hisPostAccount.post
    for id, post in ipairs(posts) do
    -- for id=1, 5 do

      local container = display.newContainer( content, size*(16/9), size )
      container.x, container.y = outSpase+(size*(16/9)+inSpase)*(id-1), (size+20)*.5
      container.anchorX = 0

      -- local rect = display.newRect(container, 0,0, size*(16/9), size )
      -- rect.fill = {.4}
      local postImage = display.newImage( container, hisPostAccount.nick.." "..id.." 1.png", system.DocumentsDirectory, 0, 0 )

      local ost = size*(16/9)
      if postImage.width<postImage.height then
        postImage.height = ost*(postImage.height/postImage.width)
        postImage.width = ost
      else
        postImage.width = ost*(postImage.width/postImage.height)
        postImage.height = ost
      end

      postImage.info = post
      eventTable[#eventTable+1] = q.event.add("open"..hisPostAccount.nick.."Post#"..(id), postImage, openPost, eventGroupName )

    end
    scrollView:insert(content)
    startY = startY + scrollView.height + hisLogo.height + 50
  end
  backForTouch.height = allcontent.height
  allscrollView:insert( allcontent )

  q.event.group.on(eventGroupName)
end

local function createWideBlankButton( width, height, num, text )
  local group = display.newGroup()

  local back = display.newRoundedRect( group, 0, 0, width, height, 20)
  back:setFillColor( unpack(c.blank) )
  
  local brightLeft = display.newRoundedRect( group, -width*.5, 0, height, height, 20)
  brightLeft:setFillColor( unpack(c.main) )
  brightLeft.anchorX = 0

  local numberLabel = display.newText( group, num, brightLeft.x+brightLeft.width*.5, 0, "fonts/sah_roboto_r.ttf", 64)
  numberLabel:setFillColor( unpack(c.text) )

  local label = display.newText( group, text, brightLeft.x+brightLeft.width+30, 0, "fonts/sah_roboto_r.ttf", 48)
  label:setFillColor( unpack(c.text) )
  label.anchorX = 0

  return group
end

local abc = {
  {"машина","массыына"},
  {"снег","хаар"},
  {"дом","дьиэ"},
  {"корова","ынах"},
  {"загон","далга"},
  {"улица","уулусса"},
}

local tasksGenerator = {
  pairFounder = function()
  end,
  wrongCorrect = function()
    local out = {}
    out.type = "correctOrWrong"

    local i = math.random(#abc)
    local myWords = abc[i]
    out.inWord = myWords[2]
    
    out.correct = math.random(2)==2
    
    if out.correct then
      out.outWord = myWords[1]
    else
      i = (i + math.random(#abc-1) -1)%(#abc) +1
      out.outWord = abc[i][1]
    end

    return out
  end
}


local function getAnswersTable(tasks)
  local answers = {}
  for i=1, #tasks do
    local task = tasks[i]
    if task.type == "correctOrWrong" then
      answers[i] = task.correct
    end
  end
  return answers
end

local function vievWrongCorrect(task,userAnswerTable)
  local group = display.newGroup()

  local discription = display.newText({
    parent = group,
    text = "Правильный ли это\nперевод?",
    x = q.cx,
    y = 300,
    align = "center",
    font = "fonts/sah_roboto_b.ttf",
    fontSize = 38,
  })
  discription:setFillColor( unpack(c.text) )

  local taskLanel = display.newText({
    parent = group,
    text = task.outWord.." = "..task.inWord,
    x = q.cx,
    y = 410,
    align = "center",
    font = "fonts/sah_roboto_r.ttf",
    fontSize = 79,
  })
  taskLanel:setFillColor( unpack(c.text) )

  local bear = display.newImageRect( group, "img/bear_think.png", 350, 350+20 )
  bear.x, bear.y = 40, taskLanel.y+100
  bear.anchorX, bear.anchorY = 0, 0

  local noButton = display.newRoundedRect( group, q.fullw*.75, bear.y+80, 300, 120, 20)
  noButton:setFillColor( unpack(c.gray2) )

  local noLabel = display.newText( group, "Нет", noButton.x, noButton.y, "font/sah_roboto_r.ttf", 42 )
  noLabel:setFillColor( unpack(c.text) )

  return group
end

local function inLocalGame(tasks)
  local gameGroup = display.newGroup()
  local eventGroupName = pps.popUp("localGame", gameGroup, {
    onShow = function()
      downNavigateGroup.alpha = 0
    end,
    onHide = function()
      downNavigateGroup.alpha = 1
    end,
  })
  
  gameGroup.alpha = 0
  transition.to(gameGroup, {alpha = 1, time=200})

  local backBlack = display.newRect(gameGroup,q.cx,q.cy,q.fullw,q.fullh)

  local mainLabel = display.newText(gameGroup, "Упражнения", q.cx, 70, "fonts/sah_roboto_b.ttf", 52)
  mainLabel:setFillColor( unpack(c.text) )

  local backProgress = display.newRoundedRect(gameGroup, q.cx, 170, q.fullw-200, 15,  10)
  backProgress:setFillColor(unpack(q.CL"E5E5E5"))

  local frontProgress = display.newRoundedRect(gameGroup, backProgress.x-backProgress.width*.5, backProgress.y, q.fullw-200, 15,  10)
  frontProgress:setFillColor(unpack(c.right))
  frontProgress.anchorX = 0
  frontProgress.width = backProgress.width*.1

  local progress = 0
  local answers = getAnswersTable(tasks)

  local checkAnswerButton = display.newRoundedRect(gameGroup, q.cx, q.fullh-130, q.fullw-80, 130, 40)
  checkAnswerButton:setFillColor(unpack(c.main))

  local checkAnswerLabel = display.newText(gameGroup, "Проверить", q.cx, checkAnswerButton.y, "fonts/sah_roboto_b.ttf", 40)
  checkAnswerLabel:setFillColor(unpack(c.text))

  local userAnswers = {}
  local curretTaskIndex = 1
  local lastTaskGroup

  local function drawTask(task)
    userAnswers[curretTaskIndex] = {}
    if task.type=="correctOrWrong" then
      lastTaskGroup = vievWrongCorrect(task,userAnswers[curretTaskIndex])
      gameGroup:insert( lastTaskGroup )
    end
  end

  drawTask(tasks[curretTaskIndex])
  

  q.event.group.on(eventGroupName)
end


-- local function lessonPairFound()
--   local lessonsListGroup = display.newGroup()
--   local eventGroupName = pps.popUp("lessonsList", lessonsListGroup)
  
--   lessonsListGroup.alpha = 0
--   transition.to(lessonsListGroup, {alpha = 1, time=200})

--   local backBlack = display.newRect(lessonsListGroup,q.cx,q.cy,q.fullw,q.fullh)

--   local mainLabel = display.newText(lessonsListGroup, "Список заданий", q.cx, 70, "fonts/sah_roboto_r.ttf", 52)
--   mainLabel:setFillColor( unpack(c.text) )

--   local buttons = {
--     {"Найди пару", lessonPairFound},
--     {"Заполни пропуск", lessonPairFound},
--   }
--   for i=1, #buttons do
--     local button = createWideBlankButton(q.fullw-80, 115, i, buttons[i][1])
--     button.x, button.y = q.cx, 200+(i-1)*(button.height+46)
--   end

-- end

local function lessonsListPopUp( event )
  local lessonsListGroup = display.newGroup()
  local eventGroupName = pps.popUp("lessonsList", lessonsListGroup)
  
  lessonsListGroup.alpha = 0
  transition.to(lessonsListGroup, {alpha = 1, time=200})

  local backBlack = display.newRect(lessonsListGroup,q.cx,q.cy,q.fullw,q.fullh)

  local mainLabel = display.newText(lessonsListGroup, "Список заданий", q.cx, 70, "fonts/sah_roboto_r.ttf", 52)
  mainLabel:setFillColor( unpack(c.text) )

  local buttons = {
    {"Верно/неверно", function()
      local tasks = {}
      for i=1, 5 do
        tasks[i] = tasksGenerator.wrongCorrect()
      end
      inLocalGame(tasks) 
    end},
    {"Заполни пропуск", inLocalGame},
  }
  for i=1, #buttons do
    local button = createWideBlankButton(q.fullw-80, 115, i, buttons[i][1])
    lessonsListGroup:insert(button)
    button.x, button.y = q.cx, 200+(i-1)*(button.height+46)


    q.event.add("saveDiscription"..i, backBlack, buttons[i][2], eventGroupName)
  end

  q.event.group.on(eventGroupName)
end

local function createRoom()
  local lessonsListGroup = display.newGroup()
  local eventGroupName = pps.popUp("createRoom", lessonsListGroup)
  
  lessonsListGroup.alpha = 0
  transition.to(lessonsListGroup, {alpha = 1, time=200})

  local backBlack = display.newRect(lessonsListGroup,q.cx,q.cy,q.fullw,q.fullh)

  local mainLabel = display.newText(lessonsListGroup, "Создание комнаты", q.cx, 70, "fonts/sah_roboto_r.ttf", 52)
  mainLabel:setFillColor( unpack(c.text) )

  local tasks = {}
  for i=1, 5 do
    tasks[i] = tasksGenerator.wrongCorrect()
  end
  local answers = getAnswersTable(tasks)

  network.request( "https://getlet.ru/createRoom/"..json.encode(
  {
    teacher_id = tonumber(account.id),
    exercise = json.encode(tasks),
    answers = json.encode(answers),
  }), "GET" )
end

function scene:create( event )
  print("menu state: CREATE")

	local sceneGroup = self.view

	backGroup = display.newGroup() -- Группа фоновых элементов
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup() -- Группа основного экрана
	sceneGroup:insert(mainGroup)

  inNewsOverlay = display.newGroup() -- Группа для кнопок 
  mainGroup:insert(inNewsOverlay)

  subGroup = display.newGroup() -- Группа основного экрана
  sceneGroup:insert(subGroup)
  subGroup.alpha = 0

  fireGroup = display.newGroup() -- Группа основного экрана
  sceneGroup:insert(fireGroup)
  fireGroup.alpha = 0

  streamGroup = display.newGroup() -- Группа основного экрана
  sceneGroup:insert(streamGroup)
  streamGroup.alpha = 0

	profileGroup = display.newGroup() -- Группа профиля
	sceneGroup:insert(profileGroup)
	profileGroup.alpha = 0

  account = q.loadLogin()
  q.getConnection("post", nil, function(event)


      local a = display.newImage("img/chat_profile.png", q.cx, q.cy)
      display.save( a, { filename=account.nick:lower().."_logo.png", baseDir=system.DocumentsDirectory, captureOffscreenArea=true, backgroundColor={0,0,0,0} } )
      display.remove( a )
      
    
  end, nil, true)

	uiGroup = display.newGroup() -- Группа общих элементов
	sceneGroup:insert(uiGroup)

  local back = display.newRect( backGroup, q.cx, q.cy, q.fullw, q.fullh )
  -- back.fill = c.backGround
  

  downNavigateGroup = display.newGroup()
  uiGroup:insert(downNavigateGroup)
  -- downNavigateGroup.y = q.fullh - SCREEN_BOTTOM

  upNavigateGroup = display.newGroup()
  uiGroup:insert(upNavigateGroup)

  local buttons = {}
  local names = {
    "home",
    "lesson",
    "sqare",
    "profile",
  }
  do -- Н А В И Г А Ц И Я -- D O W N
    local downBack = display.newRoundedRect(downNavigateGroup, q.cx, q.fullh-80, q.fullw-80, 150, 15)
    downBack.anchorY = 1
    downBack.fill = c.blank

    -- local Vshadow = display.newImageRect( downNavigateGroup, "img/shadow.png", q.fullw, q.fullw*.0611 )
    -- Vshadow.x = q.cx
    -- Vshadow.y = q.fullh-downBack.height
    -- Vshadow.anchorY=1
    
    local spase = 20
    local size = downBack.height - spase - 16
    local buttonY = downBack.y-spase

    
    local diff = {
      [1] = 40,
      [2] = 20,
      [3] = -10,
      [4] = -40,
    }

    for k,name in pairs(names) do
      buttons[name] = {}
      local button, scale
      for j=0, 1 do

        button = display.newImage( downNavigateGroup, "img/downbar/"..name..j..".png" )
        scale = 65/button.height
        button.xScale, button.yScale = scale, scale

        -- local button = display.newImageRect( downNavigateGroup, "img/downbar/"..name..j..".png", size, size*.9 )
        button.y = buttonY-20
        button.anchorY = 1
        button.x = q.fullw/(#names)*(k-.5) + (diff[k] or 0)
        -- button.name = name
        buttons[name][j] = button
      end
      local button = display.newRect( downNavigateGroup, button.x, button.y+30, 100, button.height*scale+50 )
      button.fill = c.hideButtons
      -- button.alpha = 0
      button.anchorY = 1
      button.name = name
      q.event.add("to"..name, button, menuButtonsListener, "downBar")
      buttons[name][3] = button
      
      buttons[name][1].alpha = 0
    end
    buttons.home[0].alpha = 0
    buttons.home[1].alpha = 1
  end

  do -- Н А В И Г А Ц И Я -- U P
    -- local upBack = display.newRect(upNavigateGroup, q.cx, 0, q.fullw, 100)
    -- upBack.anchorY = 0
    -- upBack.fill = {1}

    local coinCount = display.newText( {
      parent = upNavigateGroup,
      x = q.fullw-30,
      y = 50,
      text = account.coins,
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 48
    })
    coinCount:setFillColor(unpack(c.main))
    coinCount.anchorX = 1

    local coin = display.newImageRect(upNavigateGroup, "img/coin.png", 60, 60)
    coin.x, coin.y = coinCount.x-coinCount.width-10, coinCount.y
    coin.anchorX = 1

    -- local createPostButtons = display.newImageRect(upNavigateGroup, "img/create.png",84*2.5,27.1*2.5)
    -- createPostButtons.x, createPostButtons.y = q.fullw-30, upBack.height*.5
    -- createPostButtons.anchorX = 1
    q.event.add("createPost", coin, createPost, "upBar")
  end


  -- -- ======= М Е Н Ю ========= --
  do

    topMain = display.newGroup()
    -- scrollView:insert(topMain)
    mainGroup:insert( topMain )

    local logo = display.newImageRect( topMain, "img/logo.png",85*2,85*2 )
    logo.x, logo.y = 18*2 + 10, 18*2 - 20
    logo.anchorX = 1
    logo.anchorY = 1
    logo.alpha = .01

    q.event.add("nothing",logo, function()
    end, "home-popUp")

    local mainLabel = display.newText({
      parent = topMain,
      x = q.cx,
      y = 60,
      text = "Обучение",
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 48
    })
    mainLabel:setFillColor( 0,0,0 )

    local backLessons = display.newRoundedRect( topMain, q.cx, 120, q.fullw-80, 640, 10 )
    backLessons:setFillColor( unpack(c.blank) )
    backLessons.anchorY=0

    local bear = display.newImageRect( topMain, "img/bear1.png", 300, 250)
    bear.x, bear.y = q.cx, backLessons.y+50
    bear.anchorY = 0

    local lessonsLabel = display.newText({
      parent = topMain,
      x = q.cx,
      y = bear.y+bear.height+40,
      text = "Уроки",
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 48
    })
    lessonsLabel.anchorY = 0
    lessonsLabel:setFillColor( 0,0,0 )

    local lessonsDisc = display.newText({
      parent = topMain,
      x = q.cx,
      y = lessonsLabel.y+lessonsLabel.height,
      text = "Демостранционные версии\nзаданий",
      align = "center",
      font = "fonts/sah_roboto_r.ttf",
      fontSize = 48
    })
    lessonsDisc:setFillColor( 0,0,0 )
    lessonsDisc.anchorY = 0

    local goToLessons = display.newRoundedRect( topMain, q.cx, backLessons.y+backLessons.height, q.fullw-80, 100, 10)
    goToLessons.anchorY = 1
    goToLessons:setFillColor( unpack(c.main) )


    q.event.add("toLessons", goToLessons, lessonsListPopUp, "home-popUp" )
    
    local goLabel = display.newText({
      parent = topMain,
      x = q.cx,
      y = goToLessons.y-goToLessons.height*.5,
      text = "перейти к урокам",
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 48
    })
    goLabel:setFillColor( 0,0,0 )

    -- ===============
    local p = {
      {"создать","img/bear1.png",q.round, 40,"Онлайн-викторина", createRoom},
      {"Грамматика","img/bear1.png",q.round, q.fullw-40,""},
    }
    for i=1, 2 do
      local p = p[i]
      local backLessons = display.newRoundedRect( topMain, p[4], 820, (q.fullw-80)*.5-20, 440, 10 )
      backLessons:setFillColor( unpack(c.blank) )
      backLessons.anchorX = i-1
      backLessons.anchorY = 0

      local bear = display.newImageRect( topMain, p[2], 300*.7, 250*.7)
      bear.x, bear.y = backLessons.x+backLessons.width*.5*(1-(i-1)*2), backLessons.y+50
      bear.anchorY = 0

      local lessonsDisc = display.newText({
        parent = topMain,
        x = bear.x,
        y = bear.y+bear.height+30,
        text = p[5],
        align = "center",
        font = "fonts/sah_roboto_r.ttf",
        fontSize = 40
      })
      lessonsDisc:setFillColor( 0,0,0 )
      lessonsDisc.anchorY = 0

      local goToLessons = display.newRoundedRect( topMain, bear.x, backLessons.y+backLessons.height, backLessons.width, 100, 10)
      goToLessons.anchorY = 1
      goToLessons:setFillColor( unpack(c.main) )

      if p[6] then
        q.event.add("miniButtonsTo"..i, goToLessons, p[6], "home-popUp" )
      end

      local goLabel = display.newText({
        parent = topMain,
        x = bear.x,
        y = goToLessons.y-goToLessons.height*.5,
        text = p[1],
        font = "fonts/sah_roboto_b.ttf",
        fontSize = 48
      })
      goLabel:setFillColor( 0,0,0 )

      q.event.add("toRazdel"..i, goToLessons, p[3], "home-popUp")


    end

    pps.addMainScene("home", topMain, {
      onShow = function()
        for i=1, #names do
          buttons[names[i]][0].alpha = 1
          buttons[names[i]][1].alpha = 0
        end
        buttons.home[0].alpha = 0
        buttons.home[1].alpha = 1
      end,
      onHide = function()
        -- if homeListCroll then
        --   local x, y = homeListCroll:getContentPosition()
        --   homeListY = y
        -- end
      end,
      reload = function()
        -- print(allUsers)
        -- if allUsers==nil then
        --   network.request( jsonLink, "GET", loadAllUsers )
        -- else
        --   createAllInstaPost()
        -- end
      end
    })
  end
  q.event.group.on("home-popUp")

  -- -- ======= П О Д П И С К И ========= --
  do
    local back = display.newRect( subGroup, q.cx, q.cy, q.fullw, q.fullh)
    back.fill = c.backGround
    
    q.event.add("nothing",back, function()
    end, "lesson-popUp")

    pps.addMainScene( "lesson", subGroup, {
      onShow = function()
        for i=1, #names do
          buttons[names[i]][0].alpha = 1
          buttons[names[i]][1].alpha = 0
        end
        buttons.lesson[0].alpha = 0
        buttons.lesson[1].alpha = 1
      end,
      onHide = function()
        -- pps.removePop()
      end,
      -- onChangeMain = reloadHomeList
    })
    q.event.group.on("lesson-popUp")
  end

  -- -- ======= К О С Т Ё Р ========== --
  do
    local back = display.newRect( fireGroup, q.cx, q.cy, q.fullw, q.fullh)
    back.fill = c.backGround

    local logo = display.newImageRect( fireGroup, "img/logo.png",85*2,85*2 )
    logo.x, logo.y = 18*2 + 210, 18*2 - 20
    logo.anchorX = 0
    logo.anchorY = 0

    q.event.add("sqare",logo, function()
    end, "sqare-popUp")

    pps.addMainScene( "sqare", fireGroup, {
      onShow = function()
        for i=1, #names do
          buttons[names[i]][0].alpha = 1
          buttons[names[i]][1].alpha = 0
        end
        buttons.sqare[0].alpha = 0
        buttons.sqare[1].alpha = 1
      end
    })
    q.event.group.on("sqare-popUp")
  end

  -- -- ======== П Р О Ф И Л Ь ========== --
  do
    local back = display.newRect( profileGroup, q.cx, q.cy, q.fullw, q.fullh)
    back.fill = c.backGround

    local avatarGroup = display.newGroup()
    profileGroup:insert(avatarGroup)

    inProfilePhoto = display.newCircle( avatarGroup, 160, 270-30, 90 )
    inProfilePhoto.fill = {
      type = "image",
      filename = account.nick:lower().."_logo.png",
      baseDir = system.DocumentsDirectory
    }

    local backPen = display.newCircle( profileGroup, 160+inProfilePhoto.width*.35, 270-30+inProfilePhoto.height*.35, 30 )
    backPen.fill = {.9}

    local penIcon = display.newImageRect( profileGroup, "img/pen.png", 50*.8, 50*.8 )
    penIcon.x = backPen.x
    penIcon.y = backPen.y

    if profilePhotoSelect then
      q.event.add("changeAvatar", avatarGroup, profilePhotoSelect, "profile-popUp" )
    end

    local userName = q.subBySpaces(account.nick)
    userName = (#userName==1) and userName[1] or (userName[1].." "..userName[2])
    local nameLabel = textWithLetterSpacing({
      parent = profileGroup,
      x=290,
      y=inProfilePhoto.y-20,
      text = userName,
      font = "ubuntu_m.ttf",
      fontSize = 16*2,
      color = c.black,
      }, 15)

    local sityLabel = textWithLetterSpacing({
      parent = profileGroup,
      x=290,
      y=inProfilePhoto.y+20,
      text = "0 подписчиков",
      font = "ubuntu_r.ttf",
      fontSize = 16*2,
      color = c.gray,
      }, 15)

    local line = display.newRect( profileGroup, q.cx, 380, q.fullw-100, 6 )
    line.fill = c.gray2

    local infoLabel = display.newText( {
      parent = profileGroup,
      text = "Данные",
      x=70,
      y=line.y+70,
      font = "ubuntu_m.ttf",
      fontSize = 16*2} )
    infoLabel.fill = c.black
    infoLabel.anchorX = 0

    local date = os.date("*t",tonumber(account.signupdate))
    local infoShow = {
      {date.day.."."..date.month.."."..date.year,"Дата регистрации"},
      {"1","ID"},
    }

    for i=1, #infoShow do
      local infoLabel = display.newText( {
      parent = profileGroup,
      text = infoShow[i][2],
      x=70,
      y=510+50*(i-1),
      font = "ubuntu_m.ttf",
      fontSize = 16*2} )
      infoLabel.anchorX = 0
      infoLabel.fill = c.gray

      local infoLabel = display.newText( {
      parent = profileGroup,
      text = infoShow[i][1],
      x=q.fullw-70,
      y=510+50*(i-1),
      font = "ubuntu_r.ttf",
      fontSize = 16*2} )
      infoLabel.anchorX = 1
      infoLabel.fill = c.black
    end

    local line = display.newRect( profileGroup, q.cx,510+50*(#infoShow-1)+70, q.fullw-100, 6 )
    line.fill = c.gray2

    local lastY = line.y + 160
    local space = 130

    local change, cLabel = createButton(profileGroup, "МОЙ ПРОФИЛЬ", lastY) lastY = lastY + space
    local logOut, lLabel = createButton(profileGroup, "ВЫЙТИ",lastY) lastY = lastY + space
    
    q.event.add("logout", logOut, function()
      q.saveLogin({needGoogleOut=account.google})
      composer.gotoScene( "signin" )
      composer.removeScene( "menu" )
    end, "profile-popUp")

    -- q.event.add("changepass", change, function()
    --   change.alpha=0
    --   logOut.alpha=0
    --   local changePassLayer = display.newGroup()
    --   profileGroup:insert(changePassLayer)

    --   local back = display.newRoundedRect(changePassLayer, 50, 865-125*2+30, q.fullw-50*2, 80, 6)
    --   back.fill = c.gray2
    --   back.anchorX = 0

    --   local oldPass = native.newTextField(back.x+30, back.y, back.width-30*2, 90)
    --   changePassLayer:insert( oldPass )
    --   oldPass.anchorX=0
    --   oldPass.pos = {x=oldPass.x, y=oldPass.y}
    --   oldPass.isEditable=true
    --   oldPass.hasBackground = false
    --   oldPass.placeholder = "Текущий пароль"
    --   oldPass.font = native.newFont( "ubuntu_r.ttf",16*2)
    --   oldPass:resizeHeightToFitFont()
    --   oldPass:setTextColor( 0, 0, 0 )


    --   local back = display.newRoundedRect(changePassLayer, 50, back.y+100, q.fullw-50*2, 80, 6)
    --   back.fill = c.gray2
    --   back.anchorX = 0

    --   local newPass = native.newTextField(back.x+30, back.y, back.width-30*2, 90)
    --   changePassLayer:insert( newPass )
    --   newPass.anchorX=0
    --   newPass.pos = {x=oldPass.x, y=oldPass.y}
    --   newPass.isEditable=true
    --   newPass.hasBackground = false
    --   newPass.placeholder = "Новый пароль"
    --   newPass.font = native.newFont( "ubuntu_r.ttf",16*2)
    --   newPass:resizeHeightToFitFont()
    --   newPass:setTextColor( 0, 0, 0 )

      
      

    --   local okButton = createButton(changePassLayer, "ОК", lastY) lastY = lastY + space
    --   okButton:addEventListener( "tap", function()
    --     okButton.fill = q.CL"4d327a"
    --     local r,g,b = unpack( c.appColor )
    --     timer.performWithDelay( 400, 
    --     function()
    --       transition.to(okButton.fill,{r=r,g=g,b=b,time=300} )
    --     end)

    --     local textOldPass, textNewPass = oldPass.text, newPass.text
    --     if #textOldPass==0 then
    --       showPassWarning("Введите текущий пароль")
    --     elseif #textNewPass==0 then
    --       showPassWarning("Введите новый пароль")
    --     elseif #textOldPass<8 or #textNewPass<8 then
    --       showPassWarning("Пароли от 8 символов")
    --     elseif textOldPass==textNewPass then
    --       showPassWarning("Пароли не могут совпадать")
    --     else
    --       network.request( "http://"..server.."/dashboard/changePassword.php?oldpassword="..oldPass.text.."&newpassword="..newPass.text.."&email="..account.mail, "GET", changeResponder )
    --     end

    --   end )

    --   closePCMenu = function()
    --     display.remove(changePassLayer)
    --     change.alpha=1
    --     logOut.alpha=1
    --     if changeWorkButton then
    --       changeWorkButton.alpha=1
    --     end
    --     if adminBut then
    --       adminBut.alpha=1
    --     end
    --   end
    --   local cancelButton = createButton(changePassLayer, "ОТМЕНА", lastY) lastY = lastY + space
    --   cancelButton:addEventListener( "tap", closePCMenu )

    --   incorrectChange = display.newText({
    --     parent = changePassLayer,
    --     text = "Ошибка!",
    --     x=50,
    --     y=cancelButton.y+50,
    --     font = "ubuntu_m.ttf",
    --     fontSize = 16*2} )
    --   incorrectChange:setFillColor( unpack( q.CL"e07682") )
    --   incorrectChange.anchorX=0
    --   incorrectChange.alpha=0
    -- end, "profile-popUp")

    pps.addMainScene( "profile", profileGroup, {
      onShow = function()
        for i=1, #names do
          buttons[names[i]][0].alpha = 1
          buttons[names[i]][1].alpha = 0
        end
        buttons.profile[0].alpha = 0
        buttons.profile[1].alpha = 1
      end
    })
    q.event.group.on("profile-popUp")
  end

  

  q.event.group.on"downBar"
  q.event.group.on"upBar"
  Runtime:addEventListener( "key", onKeyEvent )

  -- adreessToHotWords()
  -- adreessToHotWords = nil

end


function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

  print("menu state: "..phase:upper().."-SHOW")
	if ( phase == "will" ) then
    
	elseif ( phase == "did" ) then
    local tasks = {}
    for i=1, 5 do
      tasks[i] = tasksGenerator.wrongCorrect()
    end
    print(q.printTable(tasks))
    -- createPost()
    -- pps.mainScene("subcribes")
	end
end


function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

  print("menu state: "..phase:upper().."-HIDE")
	if ( phase == "will" ) then
    Runtime:removeEventListener( "key", onKeyEvent )
    pps.reset()

	elseif ( phase == "did" ) then
    -- q.event.group.off()
    -- composer.removeScene( "menu" )
    -- print("scene hide")
	end
end


function scene:destroy( event )

  print("menu state: DESTROY")
	local sceneGroup = self.view
  chat.reset()

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
