--[[
main-file
local composer = require( "composer" )
display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )
composer.gotoScene( "menu" )
--]]

local socket = require( "socket" )


local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )

-- local androidFilePicker = require "plugin.androidFilePicker"

local tile = require( "tilebg" )

local myIdField

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

local timerUpdate = 100

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
  backGround = q.CL"F8F8F8",
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

  l_right = q.CL"3AD3A8",
  right = q.CL"00a576",

  l_error = q.CL"F48875",
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


---------------------

local account
local myID, toID, id1, id2, myI

local function getIntID()
  if system.getInfo("environment") == "device" then
    return tonumber(account.id)
  end

  return tonumber(myIdField.text) -- tonumber(account.id)
end

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


local function createButton(group,label,y)
  local submitButton = display.newRoundedRect(group, 50, y, q.fullw-50*2, 100, 30)
  submitButton.anchorX=0
  submitButton.anchorY=1
  submitButton.fill = c.main
  local labelContinue = textWithLetterSpacing( {
    parent = group, 
    text = label, 
    x = submitButton.x+submitButton.width*.5, 
    y = submitButton.y-submitButton.height*.5, 
    font = "fonts/sah_roboto_b.ttf", 
    fontSize = 20*2,
    color = c.text,
    }, 10, .5)

  return submitButton, labelContinue
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
    font = "fonts/sah_roboto_b.ttf", 
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
      font = "fonts/sah_roboto_b.ttf",
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
      font = "fonts/sah_roboto_b.ttf",
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


local followOnAccount = {
  -- nick = {isFollowed = false, buttons = {{clearButton, fillButton}}}
}


local homeListY
local homeListCroll


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
  sity = {
    name = "Город",
    {"машина","массыына"},
    {"снег","хаар"},
    {"дом","дьиэ"},
    {"улица","уулусса"},
  },
  ulus = {
    name = "Деревня",
    {"корова","ынах"},
    {"загон","далга"},
  },
  num = {
    name = "Цифры",
    {"один","биир"},
    {"два","икки"},
    {"три","ус"},
    {"четыре","туорт"},
    {"пять","биэс"},
  }
}
local imageAbc = {
  {"молоко","уут","milk"},
  {"дерево","мас","wood"}
}

local function getWordsByThemes( themes )
  if themes==nil then
    themes = {}
    for k,v in pairs(abc) do
      themes[#themes+1] = k
    end
  end
  local out = {}
  for i=1, #themes do
    local group = abc[themes[i]]
    for j=1, #group do
      out[#out+1] = group[j]
    end
  end
  return out
end

local tasksGenerator = {
  choseCorrect = function(themes)
    local abc = getWordsByThemes(themes)
    local out =  {}
    out.type = "choseCorrect"

    local i = math.random(#abc)
    local myWords = abc[i]
    
    out.inWord = myWords[2]
    out.outWord = myWords[1]

    local canChoose = {}
    for i=1, #abc do
      canChoose[i] = i
    end
    table.remove(canChoose,i)

    out.words = {}
    for i=1, 4 do
      local j = math.random(#canChoose)
      out.words[i] = abc[canChoose[j]][1]
      table.remove(canChoose,j)
    end

    out.words[math.random(4)] = myWords[1]

    return out
  end,
  imageCorrect = function(themes)
    local abc = getWordsByThemes(themes)
    local out =  {}
    out.type = "imageCorrect"

    local i = math.random(1, #imageAbc)
    local myWords = imageAbc[i]
    
    out.inWord = myWords[1]
    out.outWord = myWords[2]
    out.image = myWords[3]

    local canChoose = {}
    for i=1, #abc do
      canChoose[i] = i
    end

    out.words = {}
    for i=1, 4 do
      local j = math.random(#canChoose)
      out.words[i] = abc[canChoose[j]][2]
      table.remove(canChoose,j)
    end

    out.words[math.random(4)] = myWords[2]

    return out
  end,
  wrongCorrect = function(themes)
    local abc = getWordsByThemes(themes)

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
    elseif task.type == "choseCorrect" then
      answers[i] = task.outWord
    elseif task.type == "imageCorrect" then
      answers[i] = task.outWord
    end
  end
  return answers
end

local function choseCorrectCorrect(task,userAnswerTable, eventGroupName)
  local group = display.newGroup()

  local discription = display.newText({
    parent = group,
    text = "Выбери\nправильный перевод",
    x = q.cx,
    y = 320,
    align = "center",
    font = "fonts/sah_roboto_b.ttf",
    fontSize = 45,
  })
  discription:setFillColor( unpack(c.text) )

  -- local taskLanel = display.newText({
  --   parent = group,
  --   text = task.outWord.." = "..task.inWord,
  --   x = q.cx,
  --   y = discription.y+150,
  --   align = "center",
  --   font = "fonts/sah_roboto_r.ttf",
  --   fontSize = 79,
  -- })
  -- taskLanel:setFillColor( unpack(c.text) )

  local bear = display.newImageRect( group, "img/bear_palka.png", 350, 350+20 )
  bear.x, bear.y = 40, discription.y+100
  bear.anchorX, bear.anchorY = 0, 0

  local inBack = display.newRoundedRect( group, bear.x+bear.width, bear.y+180, 350, 120, 20)
  inBack.anchorX = 0
  inBack:setFillColor( unpack(q.CL"F7F3E0") )

  local inLabel = display.newText( group, task.inWord, inBack.x+inBack.width*.5, inBack.y, "font/sah_roboto_r.ttf", 42 )
  inLabel:setFillColor( unpack(c.text) )


  local back1 = display.newRoundedRect( group, q.fullw*.25+10, bear.y+bear.height+150, q.cx-40, 140, 20)
  local label1 = display.newText( group, task.words[1], back1.x, back1.y, "font/sah_roboto_r.ttf", 42 )
  label1:setFillColor( unpack(c.text) )

  local back2 = display.newRoundedRect( group, q.fullw*.75-10, bear.y+bear.height+150, q.cx-40, 140, 20)
  local label2 = display.newText( group, task.words[2], back2.x, back2.y, "font/sah_roboto_r.ttf", 42 )
  label2:setFillColor( unpack(c.text) )

  local back3 = display.newRoundedRect( group, q.fullw*.25+10, bear.y+bear.height+150*2, q.cx-40, 140, 20)
  local label3 = display.newText( group, task.words[3], back3.x, back3.y, "font/sah_roboto_r.ttf", 42 )
  label3:setFillColor( unpack(c.text) )

  local back4 = display.newRoundedRect( group, q.fullw*.75-10, bear.y+bear.height+150*2, q.cx-40, 140, 20)
  local label4 = display.newText( group, task.words[4], back4.x, back4.y, "font/sah_roboto_r.ttf", 42 )
  label4:setFillColor( unpack(c.text) )

  userAnswerTable[1] = nil

  q.event.add("answ1",back1, function()
    userAnswerTable[1] = task.words[1]
    back1:setFillColor( unpack(c.main) )
    back2:setFillColor( 1)
    back3:setFillColor( 1 )
    back4:setFillColor( 1 )
  end, eventGroupName)
  q.event.on("answ1_"..eventGroupName)

  q.event.add("answ2",back2, function()
    userAnswerTable[1] = task.words[2]
    back1:setFillColor( 1)
    back2:setFillColor( unpack(c.main) )
    back3:setFillColor( 1 )
    back4:setFillColor( 1 )
  end, eventGroupName)
  q.event.on("answ2_"..eventGroupName)


  q.event.add("answ3",back3, function()
    userAnswerTable[1] = task.words[3]
    back1:setFillColor( 1 )
    back2:setFillColor( 1)
    back3:setFillColor( unpack(c.main) )
    back4:setFillColor( 1 )
  end, eventGroupName)
  q.event.on("answ3_"..eventGroupName)


  q.event.add("answ4",back4, function()
    userAnswerTable[1] = task.words[4]
    back1:setFillColor( 1 )
    back2:setFillColor( 1)
    back3:setFillColor( 1 )
    back4:setFillColor( unpack(c.main) )
  end, eventGroupName)
  q.event.on("answ4_"..eventGroupName)



  return group
end

local function choseImageCorrect(task,userAnswerTable, eventGroupName)
  local group = display.newGroup()

  local discription = display.newText({
    parent = group,
    text = "Выбери\nправильный перевод",
    x = q.cx,
    y = 320,
    align = "center",
    font = "fonts/sah_roboto_b.ttf",
    fontSize = 45,
  })
  discription:setFillColor( unpack(c.text) )

  -- local taskLanel = display.newText({
  --   parent = group,
  --   text = task.outWord.." = "..task.inWord,
  --   x = q.cx,
  --   y = discription.y+150,
  --   align = "center",
  --   font = "fonts/sah_roboto_r.ttf",
  --   fontSize = 79,
  -- })
  -- taskLanel:setFillColor( unpack(c.text) )

  local bear = display.newImageRect( group, "img/bear_palka.png", 350, 350+20 )
  bear.x, bear.y = 40, discription.y+100
  bear.anchorX, bear.anchorY = 0, 0

  local inBack = display.newRoundedRect( group, bear.x+bear.width, bear.y+180, 350, 350, 20)
  inBack.anchorX = 0
  inBack:setFillColor( unpack(q.CL"F7F3E0") )

  local inImage = display.newImageRect( group, "img/imagetask/"..task.image..".png", 300, 300 )
  inImage.x, inImage.y = inBack.x+inBack.width*.5, inBack.y
  -- local inLabel = display.newText( group, task.inWord, inBack.x+inBack.width*.5, inBack.y, "font/sah_roboto_r.ttf", 42 )
  -- inLabel:setFillColor( unpack(c.text) )


  local back1 = display.newRoundedRect( group, q.fullw*.25+10, bear.y+bear.height+150, q.cx-40, 140, 20)
  local label1 = display.newText( group, task.words[1], back1.x, back1.y, "font/sah_roboto_r.ttf", 42 )
  label1:setFillColor( unpack(c.text) )

  local back2 = display.newRoundedRect( group, q.fullw*.75-10, bear.y+bear.height+150, q.cx-40, 140, 20)
  local label2 = display.newText( group, task.words[2], back2.x, back2.y, "font/sah_roboto_r.ttf", 42 )
  label2:setFillColor( unpack(c.text) )

  local back3 = display.newRoundedRect( group, q.fullw*.25+10, bear.y+bear.height+150*2, q.cx-40, 140, 20)
  local label3 = display.newText( group, task.words[3], back3.x, back3.y, "font/sah_roboto_r.ttf", 42 )
  label3:setFillColor( unpack(c.text) )

  local back4 = display.newRoundedRect( group, q.fullw*.75-10, bear.y+bear.height+150*2, q.cx-40, 140, 20)
  local label4 = display.newText( group, task.words[4], back4.x, back4.y, "font/sah_roboto_r.ttf", 42 )
  label4:setFillColor( unpack(c.text) )

  userAnswerTable[1] = nil

  q.event.add("answ1",back1, function()
    userAnswerTable[1] = task.words[1]
    back1:setFillColor( unpack(c.main) )
    back2:setFillColor( 1)
    back3:setFillColor( 1 )
    back4:setFillColor( 1 )
  end, eventGroupName)
  q.event.on("answ1_"..eventGroupName)

  q.event.add("answ2",back2, function()
    userAnswerTable[1] = task.words[2]
    back1:setFillColor( 1)
    back2:setFillColor( unpack(c.main) )
    back3:setFillColor( 1 )
    back4:setFillColor( 1 )
  end, eventGroupName)
  q.event.on("answ2_"..eventGroupName)


  q.event.add("answ3",back3, function()
    userAnswerTable[1] = task.words[3]
    back1:setFillColor( 1 )
    back2:setFillColor( 1)
    back3:setFillColor( unpack(c.main) )
    back4:setFillColor( 1 )
  end, eventGroupName)
  q.event.on("answ3_"..eventGroupName)


  q.event.add("answ4",back4, function()
    userAnswerTable[1] = task.words[4]
    back1:setFillColor( 1 )
    back2:setFillColor( 1)
    back3:setFillColor( 1 )
    back4:setFillColor( unpack(c.main) )
  end, eventGroupName)
  q.event.on("answ4_"..eventGroupName)



  return group
end

local function vievWrongCorrect(task,userAnswerTable, eventGroupName)
  local group = display.newGroup()

  local discription = display.newText({
    parent = group,
    text = "Правильный ли это\nперевод?",
    x = q.cx,
    y = 320,
    align = "center",
    font = "fonts/sah_roboto_b.ttf",
    fontSize = 38,
  })
  discription:setFillColor( unpack(c.text) )

  local taskLanel = display.newText({
    parent = group,
    text = task.outWord.." = "..task.inWord,
    x = q.cx,
    y = discription.y+150,
    align = "center",
    font = "fonts/sah_roboto_r.ttf",
    fontSize = 79,
  })
  taskLanel:setFillColor( unpack(c.text) )

  local bear = display.newImageRect( group, "img/bear_think.png", 350, 350+20 )
  bear.x, bear.y = 40, taskLanel.y+130
  bear.anchorX, bear.anchorY = 0, 0

  local noButton = display.newRoundedRect( group, q.fullw*.75, bear.y+80, 300, 120, 20)
  noButton:setFillColor( unpack(c.gray2) )

  local noLabel = display.newText( group, "Нет", noButton.x, noButton.y, "font/sah_roboto_r.ttf", 42 )
  noLabel:setFillColor( unpack(c.text) )


  local yesButton = display.newRoundedRect( group, q.fullw*.75, noButton.y+180, 300, 120, 20)
  yesButton:setFillColor( unpack(c.gray2) )

  local yesLabel = display.newText( group, "Да", yesButton.x, yesButton.y, "font/sah_roboto_r.ttf", 42 )
  yesLabel:setFillColor( unpack(c.text) )

  userAnswerTable[1] = nil
  q.event.add("noAnswer",noButton, function()
    userAnswerTable[1] = false
    noButton:setFillColor( unpack(c.main) )
    yesButton:setFillColor( unpack(c.gray2) )
  end, eventGroupName)
  q.event.on("noAnswer_"..eventGroupName)

  q.event.add("yesAnswer",yesButton, function()
    userAnswerTable[1] = true
    noButton:setFillColor( unpack(c.gray2) )
    yesButton:setFillColor( unpack(c.main) )
  end, eventGroupName)
  q.event.on("yesAnswer_"..eventGroupName)


  return group
end

local coinLabel, coinIcon

local function changeAmountCoin(amount)
  account.coins = account.coins+amount
  coinLabel.text = account.coins
  coinIcon.x = coinLabel.x-coinLabel.width-10

  network.request("https://getlet.ru/updateStat"..json.encode({
    user_id = tonumber( getIntID() ),
    type = "coins",
    amount = amount,
  }),"GET")
  q.saveLogin(account)
end

local function backgroundGame(gameGroup)
  local backBlack = display.newRect(gameGroup,q.cx,q.cy,q.fullw,q.fullh)
  backBlack.fill = c.backGround

  local mainLabel = display.newText(gameGroup, "Упражнения", q.cx, 70, "fonts/sah_roboto_b.ttf", 52)
  mainLabel:setFillColor( unpack(c.text) )

  local backProgress = display.newRoundedRect(gameGroup, q.cx, 170, q.fullw-200, 15,  10)
  backProgress:setFillColor(unpack(q.CL"E5E5E5"))

  local frontProgress = display.newRoundedRect(gameGroup, backProgress.x-backProgress.width*.5, backProgress.y, q.fullw-200, 15,  10)
  frontProgress:setFillColor(unpack(c.right))
  frontProgress.anchorX = 0
  frontProgress.allwidth = frontProgress.width
  frontProgress.width = backProgress.width*.1

  local checkAnswerButton = display.newRoundedRect(gameGroup, q.cx, q.fullh-130, q.fullw-80, 130, 40)
  checkAnswerButton:setFillColor(unpack(c.main))

  local checkAnswerLabel = display.newText(gameGroup, "Проверить", q.cx, checkAnswerButton.y, "fonts/sah_roboto_b.ttf", 40)
  checkAnswerLabel:setFillColor(unpack(c.text))

  local slideUpGroup = display.newGroup()
  gameGroup:insert(slideUpGroup)
  slideUpGroup.y = 350

  local back = display.newRoundedRect(slideUpGroup, q.cx, q.fullh-130, q.fullw, 400, 50)
  back:setFillColor( unpack(c.right) )

  local yourAnswerIsLabel = display.newText(slideUpGroup, "Правильно", q.cx, q.fullh-260, "fonts/sah_roboto_b.ttf", 50)

  local nextButton = display.newRoundedRect(slideUpGroup, q.cx, q.fullh-130, q.fullw-80, 130, 40)
  nextButton:setFillColor(unpack(c.main))

  local nextLabel = display.newText(slideUpGroup, "Далее", q.cx, nextButton.y, "fonts/sah_roboto_b.ttf", 40)
  nextLabel:setFillColor(unpack(c.text))

  -- local out = {
  --   slideUpGroup = slideUpGroup,
  --   nextButton = nextButton,
  -- }

  return slideUpGroup, nextButton, checkAnswerButton, yourAnswerIsLabel, back, frontProgress, nextLabel
end

local function drawEnd(gameGroup, getCoins, eventGroupName)
    
  local endLabel = display.newText(gameGroup, "Конец урока!", q.cx, q.cy-350, "fonts/sah_roboto_b.ttf", 52)
  endLabel:setFillColor( unpack(c.text) )

  local bear = display.newImageRect( gameGroup, "img/bear_googles.png", 318*1.5, 330*1.5 )
  bear.x, bear.y = q.cx, q.cy

  local winBack = display.newRoundedRect( gameGroup, q.cx, q.cy+400, q.fullw-80, 180, 30)

  local winLabel = display.newText(gameGroup, "Вы набрали", q.cx, winBack.y-40, "fonts/sah_roboto_b.ttf", 40)
  winLabel:setFillColor( unpack(c.text) )

  local winCountLabel = display.newText(gameGroup, getCoins, q.cx, winBack.y+30, "fonts/sah_roboto_b.ttf", 55)
  winCountLabel:setFillColor( unpack(c.main) )

  local coinIcon = display.newImageRect( gameGroup, "img/coin.png", 50, 50 )
  coinIcon.x = winCountLabel.x - winCountLabel.width*.5-10
  coinIcon.y = winCountLabel.y
  coinIcon.anchorX = 1

  local closeButton = display.newRoundedRect(gameGroup, q.cx, q.fullh-130, q.fullw-80, 130, 40)
  closeButton:setFillColor(unpack(c.main))

  local closeLabel = display.newText(gameGroup, "Забрать", q.cx, closeButton.y, "fonts/sah_roboto_b.ttf", 40)
  closeLabel:setFillColor(unpack(c.text))

  q.event.add("endLesson",closeButton, function() changeAmountCoin(getCoins) pps.removePop() end, eventGroupName )
  q.event.on("endLesson_"..eventGroupName)
end


local task_ui = {
  remove = function(taskType, eventGroupName)
    if taskType=="correctOrWrong" then 
      q.event.remove("yesAnswer_"..eventGroupName,eventGroupName)
      q.event.remove("noAnswer_"..eventGroupName,eventGroupName)
    elseif taskType=="choseCorrect" then
      q.event.remove("answ1_"..eventGroupName,eventGroupName)
      q.event.remove("answ2_"..eventGroupName,eventGroupName)
      q.event.remove("answ3_"..eventGroupName,eventGroupName)
      q.event.remove("answ4_"..eventGroupName,eventGroupName)
    elseif taskType=="imageCorrect" then
      q.event.remove("answ1_"..eventGroupName,eventGroupName)
      q.event.remove("answ2_"..eventGroupName,eventGroupName)
      q.event.remove("answ3_"..eventGroupName,eventGroupName)
      q.event.remove("answ4_"..eventGroupName,eventGroupName)
    end
  end,
  draw = function(task, eventGroupName, answersTable)
    local group
    if task.type=="correctOrWrong" then 
      group = vievWrongCorrect(task,answersTable,eventGroupName)
    elseif task.type=="choseCorrect" then
      group = choseCorrectCorrect(task,answersTable,eventGroupName)
    elseif task.type=="imageCorrect" then
      group = choseImageCorrect(task,answersTable,eventGroupName)
    end
    return group
  end,
}



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

  local slideUpGroup, nextButton, checkAnswerButton, yourAnswerIsLabel, back, frontProgress = backgroundGame(gameGroup)
  local answers = getAnswersTable(tasks)

  local userAnswers = {}
  local succesTsks = 0
  local curretTaskIndex = 1
  local lastTaskGroup

  local canNext = false

  q.event.add("checkAnswers",checkAnswerButton, function()
    if canNext then return end
    if userAnswers[curretTaskIndex][1] == nil then return end
    print(userAnswers[curretTaskIndex][1], answers[curretTaskIndex])
    if userAnswers[curretTaskIndex][1] == answers[curretTaskIndex] then
      succesTsks = succesTsks + 1
      -- print("Right!")
      yourAnswerIsLabel.text = "Правильно"
      back:setFillColor( unpack(c.right) )
    else
      yourAnswerIsLabel.text = "Неправильно"
      back:setFillColor( unpack(c.error) )
    end
    canNext = true
    

    transition.to( slideUpGroup, {y=0, time=300} )
  end, eventGroupName)

  q.event.add("nextQuest",nextButton, function()
    transition.to( slideUpGroup, {y=350, time=300} )
    
    curretTaskIndex = curretTaskIndex + 1
    
    if curretTaskIndex<=#tasks then
      
      local task = tasks[curretTaskIndex]
      if lastTaskGroup~=nil then
        display.remove(lastTaskGroup)
        lastTaskGroup = nil
        task_ui.remove(tasks[curretTaskIndex-1].type, eventGroupName)
      end
      transition.to( frontProgress, {width = frontProgress.allwidth*(curretTaskIndex/#tasks),time=200} )
      
      userAnswers[curretTaskIndex] = {}

      lastTaskGroup = task_ui.draw(task, eventGroupName, userAnswers[curretTaskIndex])
      gameGroup:insert(lastTaskGroup)

    else
      checkAnswerButton.alpha = 0
      display.remove(lastTaskGroup)
      lastTaskGroup = nil
      task_ui.remove(tasks[#tasks].type, eventGroupName)

      local getCoins = succesTsks*5

      drawEnd(gameGroup, getCoins, eventGroupName)
    end

    timer.performWithDelay( 1, function()
      canNext = false
    end )

  end, eventGroupName)
  
  q.event.group.on(eventGroupName)

  userAnswers[1] = {}
  lastTaskGroup = task_ui.draw(tasks[1], eventGroupName, userAnswers[1])
  gameGroup:insert(lastTaskGroup)

end

local function onlineGame(tasks, room_code)
  local gameGroup = display.newGroup()
  local eventGroupName = pps.popUp("onlineGame", gameGroup, {
    onShow = function()
      downNavigateGroup.alpha = 0
    end,
    onHide = function()
      downNavigateGroup.alpha = 1
    end,
  })
  
  gameGroup.alpha = 0
  transition.to(gameGroup, {alpha = 1, time=200})

  local slideUpGroup, nextButton, checkAnswerButton, yourAnswerIsLabel, back, frontProgress, nextLabel = backgroundGame(gameGroup)
  -- nextButton:setFillColor( unpack(c.gray2) )
  nextButton.fill = c.gray2

  local backDeadline = display.newRoundedRect(gameGroup, q.cx, 190, q.fullw-200, 10,  10)
  backDeadline:setFillColor(unpack(q.CL"E5E5E5"))

  local frontDeadline = display.newRoundedRect(gameGroup, backDeadline.x-backDeadline.width*.5, backDeadline.y, q.fullw-200, backDeadline.height,  10)
  frontDeadline:setFillColor(unpack(c.error))
  frontDeadline.anchorX = 0
  frontDeadline.allwidth = frontDeadline.width
  frontDeadline.width = 10

  local frontNextline = display.newRoundedRect(slideUpGroup, backDeadline.x-backDeadline.width*.5, nextButton.y+80, q.fullw-200, 7,  10)
  frontNextline.anchorX = 0
  frontNextline.allwidth = frontNextline.width
  frontNextline.width = 10

  local answers = getAnswersTable(tasks)

  local userAnswers = {}
  local succesTsks = 0
  local curretTaskIndex = 1
  local lastTaskGroup
  
  local canGo = false
  local canNext = false


  local function checkUserAnswer()
    if canNext then return end
    print("canNext")
    if userAnswers[curretTaskIndex][1] == nil then return end
    print("answer not nil")



    if userAnswers[curretTaskIndex][1] == answers[curretTaskIndex] then
      succesTsks = succesTsks + 1

      yourAnswerIsLabel.text = "Правильно"
      back:setFillColor( unpack(c.right) )
    else
      yourAnswerIsLabel.text = "Неправильно"
      back:setFillColor( unpack(c.error) )
    end
    canNext = true
    

    transition.to( slideUpGroup, {y=0, time=300} )
    transition.cancel("deadline")
    

    local answerToThis = userAnswers[curretTaskIndex][1]

    if answerToThis==false then answerToThis=1
    elseif answerToThis==true then answerToThis=2
    end

    network.request( "https://getlet.ru/userAnswer/"..json.encode({
      room_code = room_code,
      user_id = tonumber(getIntID()),
      key = curretTaskIndex,
      answer = answerToThis,
    }), "GET")
  end

  local r,g,b = unpack(c.main)
  local toNextQuest
  local function resetTimeOuts()
    nextLabel.text = "Ждем остальных.."
    frontDeadline.width = 10
    transition.to( frontDeadline, {width=frontDeadline.allwidth, time=5000, onComplete=function()
      local myAnswer = (userAnswers[curretTaskIndex] and userAnswers[curretTaskIndex][1]) or "no answer: timeout"
      userAnswers[curretTaskIndex][1] = (myAnswer and myAnswer) or "no answer: timeout"

      -- canNext = true
      checkUserAnswer()
    end, tag = "deadline"} )

    nextButton.fill = c.gray2
    frontNextline.width = 10
    transition.to( frontNextline, {width=frontNextline.allwidth, time=8000, onComplete=function()
      canGo = true
      nextLabel.text = "Запускаем"
      transition.to(nextButton.fill,{r=r,g=g,b=b,time=200})
      transition.to(frontNextline,{width=10,time=2000, onComplete=toNextQuest, tag = "nextdeadline"})
    end, tag = "nextline"} )

  end

  toNextQuest = function()
    if canGo==false then return end
    canGo = false
    transition.to( slideUpGroup, {y=350, time=300} )
    transition.cancel("nextline")
    transition.cancel("nextdeadline")
    
    curretTaskIndex = curretTaskIndex + 1
    
    if curretTaskIndex<=#tasks then
      
      resetTimeOuts()

      if lastTaskGroup~=nil then
        display.remove(lastTaskGroup)
        lastTaskGroup = nil
        task_ui.remove(tasks[curretTaskIndex-1].type, eventGroupName)
      end
      local task = tasks[curretTaskIndex]
      transition.to( frontProgress, {width = frontProgress.allwidth*(curretTaskIndex/#tasks),time=200} )
      
      userAnswers[curretTaskIndex] = {}

      lastTaskGroup = task_ui.draw(task, eventGroupName, userAnswers[curretTaskIndex])
      gameGroup:insert(lastTaskGroup)

    else
      backDeadline.alpha = 0
      frontDeadline.alpha = 0

      checkAnswerButton.alpha = 0
      display.remove(lastTaskGroup)
      lastTaskGroup = nil
      task_ui.remove(tasks[#tasks].type, eventGroupName)

      local getCoins = succesTsks*5

      drawEnd(gameGroup, getCoins, eventGroupName)
    end

    timer.performWithDelay( 1, function()
      canNext = false
    end )
  end

  

  q.event.add("checkAnswers",checkAnswerButton, checkUserAnswer, eventGroupName)
  -- q.event.add("nextQuest",nextButton, toNextQuest, eventGroupName)

  
  q.event.group.on(eventGroupName)

  resetTimeOuts()

  userAnswers[1] = {}
  lastTaskGroup = task_ui.draw(tasks[1], eventGroupName, userAnswers[1])
  gameGroup:insert(lastTaskGroup)

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
    {"Выбери перевод", function()
      local tasks = {}
      for i=1, 5 do
        tasks[i] = tasksGenerator.choseCorrect()
      end
      inLocalGame(tasks) 
    end},
    {"Что на картинке?", function()
      local tasks = {}
      for i=1, 5 do
        tasks[i] = tasksGenerator.imageCorrect()
      end
      inLocalGame(tasks) 
    end}
  }
  for i=1, #buttons do
    local button = createWideBlankButton(q.fullw-80, 115, i, buttons[i][1])
    lessonsListGroup:insert(button)
    button.x, button.y = q.cx, 200+(i-1)*(button.height+46)


    q.event.add("saveDiscription"..i, button, buttons[i][2], eventGroupName)
  end

  q.event.group.on(eventGroupName)
end

local function createRoom()
  local onlineRoomGroup = display.newGroup()
  local waiting = true
  local eventGroupName = pps.popUp("createRoom", onlineRoomGroup, {
    onShow = function()
      downNavigateGroup.alpha = 0
    end,
    onHide = function()
      waiting = false
      downNavigateGroup.alpha = 1
    end,
  })
  
  onlineRoomGroup.alpha = 0
  transition.to(onlineRoomGroup, {alpha = 1, time=200})

  local backBlack = display.newRect(onlineRoomGroup,q.cx,q.cy,q.fullw,q.fullh)

  local mainLabel = display.newText(onlineRoomGroup, "Ваша комната", q.cx, 70, "fonts/sah_roboto_r.ttf", 52)
  mainLabel:setFillColor( unpack(c.text) )

  local codeLabel = display.newText(onlineRoomGroup, "КОД: -----", q.cx, 200, "fonts/sah_roboto_r.ttf", 70)
  codeLabel:setFillColor( unpack(c.text) )

  local tasks = {}
  local funcs = {}
  for k, v in pairs(tasksGenerator) do
    funcs[#funcs+1] = v
  end
  for i=1, 5 do
    tasks[i] = funcs[math.random(#funcs)]()
  end
  local answers = getAnswersTable(tasks)


  local startButton = display.newRoundedRect(onlineRoomGroup, q.cx, q.fullh-110, q.fullw-80, 110, 40)
  startButton.fill = c.gray2

  local startLabel = display.newText(onlineRoomGroup, "Запустить", q.cx, startButton.y, "fonts/sah_roboto_b.ttf", 40)
  startLabel:setFillColor(unpack(c.text))

  -- local changeButton = display.newRoundedRect(onlineRoomGroup, q.cx, q.fullh-250, q.fullw-80, 110, 20)
  -- changeButton:setFillColor(unpack(c.blank))

  -- local canChoose = {
  --   {nil, "Все задания"},
  --   {sity, "Город"},
  --   {ulus, "Село"},
  --   {num, "Цифры"},
  -- }

  -- local i = 1

  -- local changeLabel = display.newText(onlineRoomGroup, "Все задания", q.cx, changeButton.y, "fonts/sah_roboto_b.ttf", 40)
  -- changeLabel:setFillColor(unpack(c.text))

  -- q.event.add("changeTheme", changeButton, function()
  --   i = (i%#canChoose)+1
  --   changeLabel.text = canChoose[i][2]
  -- end, eventGroupName)

  local users
  local myRoom
  local connectedUIgroup
  local clientStatus = "connecting"


  local function drawConnections()
    if connectedUIgroup~=nil then
      local newUsers = false
      for k,v in pairs(users) do
        if connectedUIgroup.users[k]==nil then
          newUsers = true
          break
        end
      end
      for k,v in pairs(connectedUIgroup.users) do
        if users[k]==nil then
          newUsers = true
          break
        end
      end
      -- for i=1, #users do
      --   if users[i]~=connectedUIgroup.users[i] then
      --     newUsers = true
      --     break
      --   end
      -- end
      if newUsers==false then return end
      connectedUIgroup.users = nil
      display.remove(connectedUIgroup)
      connectedUIgroup = nil
    end    

    connectedUIgroup = display.newGroup()
    onlineRoomGroup:insert(connectedUIgroup)
    connectedUIgroup.users = users

    local xC = 0
    local y = 380
    print(users)
    print(q.printTable(users))
    for k,v in pairs(users) do
      print(k,v)
      print("in v", q.printTable(v))
      xC = xC + 1
      if xC>2 then xC=1 y = y+180 end
      local x = xC==1 and 100 or q.cx+90

      local bear = display.newImageRect(connectedUIgroup, "img/bear1.png", 160*.8,130*.8)
      bear.x, bear.y = x, y 

      local nameLabel = display.newText(connectedUIgroup, v.name, bear.x+bear.width*.5+10, bear.y, "fonts/sah_roboto_r.ttf", 52)
      nameLabel:setFillColor( unpack(c.text) )
      nameLabel.anchorX = 0
    end
  end

  local function drawScoreTable()
    if connectedUIgroup~=nil then
      display.remove(connectedUIgroup)
      connectedUIgroup = nil
    end
    local forSort = {}
    for k,v in pairs(users) do
      forSort[#forSort+1] = {v.name,tonumber(v.balls),v.answers}
    end
    -- forSort = {
    --   {"lev6",10},
    --   {"lev5",11},
    --   {"lev4",12},
    --   {"lev3",13},
    --   {"lev2",14},
    --   {"lev1",15},
    -- }
    table.sort( forSort, function(a,b)
      return a[2]>b[2]
    end )
    


    connectedUIgroup = display.newGroup()
    onlineRoomGroup:insert(connectedUIgroup)

    for i=1, math.min(#forSort,3) do
      local medal = display.newImageRect( connectedUIgroup, "img/medal"..i..".png",90*.8,130*.8 )
      medal.x = 90
      medal.y = 250+130*i
    end

    for i=4, #forSort do
      local num = display.newText( connectedUIgroup, i, 90, 250+130*i, "fonts/sah_roboto_b.ttf", 60 )
      num:setFillColor( unpack(c.main) )
    end



    for i=1, #forSort do
      local nowAnswersCount = #answers
      local correct = 0
      local userAnswers = forSort[i][3]
      
      -- print(q.printTable(userAnswers))
      for i=1, #answers do
        if userAnswers[tostring(i)]==0 then
          nowAnswersCount = i-1
          break
        end
      end
      -- print("Count",nowAnswersCount)
      for i=1, nowAnswersCount do
        local myAnswer = userAnswers[tostring(i)]
        if myAnswer==1 then
          myAnswer = false
        elseif myAnswer==2 then
          myAnswer = true
        end
        -- print("user:",myAnswer," ans:",answers[i])
        if answers[i]==myAnswer then
          correct = correct + 1
          -- print("+correct",correct)
        end

      end

      -- print(forSort[i][1].." "..forSort[i][2])
      local name = display.newText( {
        parent = connectedUIgroup,
        text = forSort[i][1],
        x=170,
        y=250+130*i,
        font="fonts/sah_roboto_b.ttf",
        fontSize = 45
      } )
      name:setFillColor( unpack(c.text) )
      name.anchorX = 0

      local perc = q.round((correct/nowAnswersCount)*100)
      -- perc = (tostring(perc)=="-nan(ind)" and 100) or perc
      perc = (tostring(perc):find("nan")~=nil and 100) or perc

      -- perc = tonumber(tostring(perc))==nil and 100) or perc
      -- perc = (tonumber(tostring(perc))==nil and 100) or perc

      local points = display.newText( {
        parent = connectedUIgroup,
        text = forSort[i][2].." очк. ("..perc.."%)",
        x=q.fullw-50,
        y=250+130*i,
        font="fonts/sah_roboto_b.ttf",
        fontSize = 45
      } )
      points:setFillColor( unpack(c.text) )
      points.anchorX = 1
    end
  end

  local updateRoomStatus
  local function roomStatusChecker()

    if clientStatus~="ended" then
      network.request( "https://getlet.ru/getRoom/"..json.encode({
        room_code = myRoom.room_code,
      }), "GET", updateRoomStatus )
      print("CHECKROOM","https://getlet.ru/getRoom/"..json.encode({
        room_code = myRoom.room_code,
      }))
      print(json.encode({
        room_code = myRoom.room_code,
      }))
    end

    if myRoom.status=="wait" then
      if clientStatus=="connecting" then
        clientStatus = "wait"

        local r, g, b = unpack(c.main)
    
        transition.to(startButton.fill, {r=r, g=g, b=b, time=400})

        startButton:setFillColor(unpack(c.main))
        codeLabel.text  = "КОД:"..myRoom.room_code

        display.remove(field)
      end
      
      drawConnections()

    elseif myRoom.status=="started" and clientStatus~="ended" then

      clientStatus = "started"

      codeLabel.text = "Таблица результатов"
      startButton.alpha = 0
      startLabel.alpha = 0

      drawScoreTable()

      for k, v in pairs(users) do
        -- print("check is ened")
        -- print(#v.answers,#answers,v.answers[tostring(#answers)])
        -- print(q.printTable(v.answers))
        if v.answers[tostring(#answers)]~=0 then
        -- if #v.answers == #answers then
          -- print("Start end timer")
          clientStatus = "ended"
          timer.performWithDelay(5000, function()
            -- print("SEND END")
            network.request( "https://getlet.ru/finishRoom/"..json.encode({
              room_code = myRoom.room_code,
            }), "GET" )
          end)
        end
        break
      end

    end
  end

  -- local url = ""
  updateRoomStatus = function( event )
    if ( event.isError)  then
      print( "Error!", event.response)
      return false
    else
      local myNewData = event.response
      -- print(myNewData)
      if myNewData==nil or myNewData=="[]" then
        print("Server read: нет ответа")
        return false
      end
      -- print(myNewData)
      myRoom = json.decode(myNewData)
      if myRoom==nil or myRoom.error~=nil then
        native.showAlert( "Ошибка подключения "..url, myNewData )
        print("Error: ",myRoom and myRoom.error or "")
        return false
      end

      -- native.showAlert( "Нет ошибки? "..url, myNewData, "OK" )
      myRoom.exercise = json.decode(myRoom.exercise)
      myRoom.exercise = json.decode(myRoom.exercise)
      -- print("Usersget,",myRoom.users)
      -- if type(myRoom.users)=="table" then
      --   users = myRoom.users
      -- else
        users = json.decode(myRoom.users)['users']
      -- end
      -- print("Formto", q.printTable(users))
      
      roomStatusChecker()
      
    end
    return true
  end



  q.event.add("startRoom", startButton, function()
    -- if myRoom==nil then return end
    print("starting")
    network.request( "https://getlet.ru/startRoom/"..json.encode({
      room_code = myRoom.room_code,
    }), "GET", function(event)
      print("START")
      print(event.response)

    end )
  end, eventGroupName)


  local rebool = q.deepcopy(answers)
  for i=1, #rebool do
    if rebool[i]==false then
      rebool[i] = 1
    elseif rebool[i]==true then
      rebool[i] = 2
    end
  end
  -- url = "https://getlet.ru/createRoom/"..q.jsonForUrl(json.encode(
  -- {
  --   teacher_id = tonumber(getIntID()),
  --   exercise = json.encode(tasks),
  --   answers = json.encode(rebool),
  -- }))
  -- print(url,"AWAKADO")
  network.request( "https://getlet.ru/createRoom/"..q.jsonForUrl(json.encode(
  {
    teacher_id = tonumber(getIntID()),
    exercise = json.encode(tasks),
    answers = json.encode(rebool),
  })), "GET", updateRoomStatus )

  q.event.group.on(eventGroupName)
end

local function joinRoom()
  local joinRoomGroup = display.newGroup()
  local eventGroupName = pps.popUp("joinRoom", joinRoomGroup, {
    onShow = function()
      downNavigateGroup.alpha = 0
    end,
    onHide = function()
      downNavigateGroup.alpha = 1
    end,
  })
  
  joinRoomGroup.alpha = 0
  transition.to(joinRoomGroup, {alpha = 1, time=200})

  local backBlack = display.newRect(joinRoomGroup,q.cx,q.cy,q.fullw,q.fullh)

  local mainLabel = display.newText(joinRoomGroup, "Подключение к комнате", q.cx, 100, "fonts/sah_roboto_r.ttf", 48)
  mainLabel:setFillColor( unpack(c.text) )

  local back = display.newRoundedRect( joinRoomGroup, q.cx, q.cy, q.fullw-250, 100, 20 )
  back.fill = c.blank

  local field = native.newTextField( q.cx, q.cy, 250, 50 )
  field.placeholder = "Код комнаты"
  field.hasBackground = false
  joinRoomGroup:insert(field)
  field:setTextColor( unpack(c.text) )

  local connectButton = display.newRoundedRect(joinRoomGroup, q.cx, q.fullh-110, q.fullw-80, 110, 40)
  connectButton:setFillColor(unpack(c.main))

  local connectLabel = display.newText(joinRoomGroup, "Подключиться", q.cx, connectButton.y, "fonts/sah_roboto_r.ttf", 40)
  connectLabel:setFillColor(unpack(c.text))

  local codeLabel = display.newText(joinRoomGroup, "КОД: -----", q.cx, 200, "fonts/sah_roboto_r.ttf", 75)
  codeLabel:setFillColor( unpack(c.text) )

  local myRoom
  local clientStatus = "connecting"
  local connectOnProcces = false

  local updateRoomStatus
  local function roomStatusChecker()
    -- print("cheking",myRoom.status)
    if myRoom.status=="wait" then
      network.request( "https://getlet.ru/getRoom/"..json.encode({
        room_code = myRoom.room_code,
      }), "GET", updateRoomStatus )
    end

    if myRoom.status=="wait" and clientStatus=="connecting" then
      clientStatus = "wait"
      codeLabel.text  = "КОД:"..myRoom.room_code

      display.remove(connectButton)
      display.remove(connectLabel)
      display.remove(back)
      -- connectButton.alpha = 0
      -- connectLabel.alpha = 0
      display.remove(field)

      local back = display.newRoundedRect( joinRoomGroup, q.cx, q.fullh-200, q.fullw-250, 110, 20 )
      back.fill = c.blank

      local label = display.newText( {
        parent = joinRoomGroup,
        text = "Вы подключены",
        x = q.cx,
        y = back.y,
        align = "center",
        font="fonts/sah_roboto_b.ttf",
        fontSize = 45,
      })
      label:setFillColor( unpack(c.text) )


    elseif myRoom.status=="started" then

      clientStatus = "started"

      local backBlack = display.newRect(joinRoomGroup,q.cx,q.cy,q.fullw,q.fullh)
      backBlack.alpha = 0
      transition.to(backBlack, {alpha = 1, time=200})
      local i = 5
      local num = display.newText( joinRoomGroup, i.."..", q.cx, q.cy, "fonts/sah_roboto_b.ttf", 60 )
      num:setFillColor( unpack( c.text ) )
      num:toFront( )

      timer.performWithDelay( 1000, function()
        i = i - 1
        num.text = i..".."
      end, 5 )
      timer.performWithDelay( 5000, function()
        pps.removePop()
        onlineGame(myRoom.exercise, myRoom.room_code)
      end)
    end
  end

  updateRoomStatus = function( event )
    if ( event.isError)  then
      print( "Error!", event.response)
      return false
    else
      local myNewData = event.response
      print(myNewData)
      if myNewData==nil or myNewData=="[]" then
        print("Server read: нет ответа")
        return false
      end

      myRoom = json.decode(myNewData)
      if myRoom.error~=nil then
        print("Error: ",myRoom.error)
        return false
      end

      myRoom.exercise = json.decode(myRoom.exercise)
      myRoom.exercise = json.decode(myRoom.exercise)
      
      roomStatusChecker()
      
    end
    return true
  end

  q.event.add("tryConnect", connectButton, function()
    if connectOnProcces then return end
    local code = field.text:gsub(" ","")
    code = code:sub(1,6)
    code = code:upper()
    field.text = code

    connectOnProcces = true
    connectButton.fill = c.gray2
    timer.performWithDelay(3000, function()
      connectOnProcces = false
      transition.to( connectButton.fill, {r=c.main[1], g=c.main[2], b=c.main[3], time=500} )

    end)
    network.request( "https://getlet.ru/joinRoom/"..json.encode({
      room_code = code,
      user_id = tonumber(getIntID()),
    }), "GET", updateRoomStatus)
  end, eventGroupName)

  q.event.group.on(eventGroupName)
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

    coinLabel = display.newText( {
      parent = upNavigateGroup,
      x = q.fullw-30,
      y = 50,
      text = account.coins,
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 48
    })
    coinLabel:setFillColor(unpack(c.main))
    coinLabel.anchorX = 1

    coinIcon = display.newImageRect(upNavigateGroup, "img/coin.png", 60, 60)
    coinIcon.x, coinIcon.y = coinLabel.x-coinLabel.width-10, coinLabel.y
    coinIcon.anchorX = 1

    -- local createPostButtons = display.newImageRect(upNavigateGroup, "img/create.png",84*2.5,27.1*2.5)
    -- createPostButtons.x, createPostButtons.y = q.fullw-30, upBack.height*.5
    -- createPostButtons.anchorX = 1
    q.event.add("createPost", coinIcon, print, "upBar")
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

    if system.getInfo("environment") ~= "device" then
      myIdField = native.newTextField( 10, 10, 100, 50 )
      topMain:insert(myIdField)
      myIdField.anchorX = 0
      myIdField.anchorY = 0
      myIdField.text = tostring(account.id)
    end


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
      font = "fonts/sah_roboto_r.ttf",
      fontSize = 48
    })
    goLabel:setFillColor( 0,0,0 )

    -- ===============
    local p = {
      {"создать","img/bear1.png",createRoom, 40,"Онлайн-викторина", },
      {"подключиться","img/bear1.png",joinRoom, q.fullw-40,"Онлайн-викторина", },
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

      if p[3] then
        q.event.add("miniButtonsTo"..i, goToLessons, p[3], "home-popUp" )
      end

      local goLabel = display.newText({
        parent = topMain,
        x = bear.x,
        y = goToLessons.y-goToLessons.height*.5,
        text = p[1],
        font = "fonts/sah_roboto_r.ttf",
        fontSize = 48
      })
      goLabel:setFillColor( 0,0,0 )



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

  -- -- ======= У Р О К И ========= --
  do
    local back = display.newRect( subGroup, q.cx, q.cy, q.fullw, q.fullh)
    back.fill = c.backGround

    local mainLabel = display.newText({
      parent = subGroup,
      x = q.cx,
      y = 60,
      text = "Уроки",
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 48
    })
    mainLabel:setFillColor( 0,0,0 )
    
    local lessonsDisc = display.newText({
      parent = subGroup,
      x = q.cx,
      y = q.cy-50,
      text = "Упс.. этот раздел\nещё в разработке",
      align = "center",
      font = "fonts/sah_roboto_r.ttf",
      fontSize = 48
    })
    lessonsDisc:setFillColor( 0,0,0 )
    lessonsDisc.anchorY = 1

    local bear = display.newImageRect( subGroup, "img/bear_think.png", 300, 300 )
    bear.x, bear.y = q.cx, q.cy+150


    q.event.add("nothing",lessonsDisc, function()
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

  -- -- ======= А Д М И Н ========== --
  do
    local back = display.newRect( fireGroup, q.cx, q.cy, q.fullw, q.fullh)
    back.fill = c.backGround

    local mainLabel = display.newText({
      parent = fireGroup,
      x = q.cx,
      y = 60,
      text = "Админ-панель",
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 48
    })
    mainLabel:setFillColor( 0,0,0 )
    
    local lessonsDisc = display.newText({
      parent = fireGroup,
      x = q.cx,
      y = q.cy-50,
      text = "Упс.. этот раздел\nещё в разработке",
      align = "center",
      font = "fonts/sah_roboto_r.ttf",
      fontSize = 48
    })
    lessonsDisc:setFillColor( 0,0,0 )
    lessonsDisc.anchorY = 1

    local bear = display.newImageRect( fireGroup, "img/bear_think.png", 300, 300 )
    bear.x, bear.y = q.cx, q.cy+150

    q.event.add("sqare",lessonsDisc, function()
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

    local mainLabel = display.newText({
      parent = profileGroup,
      x = q.cx,
      y = 60,
      text = "Профиль",
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 48
    })
    mainLabel:setFillColor( 0,0,0 )

    local avatarGroup = display.newGroup()
    profileGroup:insert(avatarGroup)

    inProfilePhoto = display.newCircle( avatarGroup, 160, 270-30, 90 )
    inProfilePhoto.fill = {
      type = "image",
      filename = account.nick:lower().."_logo.png",
      baseDir = system.DocumentsDirectory
    }

    local backPen = display.newCircle( profileGroup, 160+inProfilePhoto.width*.35, 270-30+inProfilePhoto.height*.35, 30 )
    backPen.fill = c.main

    local penIcon = display.newImageRect( profileGroup, "img/pen.png", 50*.8, 50*.8 )
    penIcon.x = backPen.x
    penIcon.y = backPen.y

    if profilePhotoSelect then
      q.event.add("changeAvatar", avatarGroup, profilePhotoSelect, "profile-popUp" )
    end

    local userName = q.subBySpaces(account.nick)
    userName = (#userName==1) and userName[1] or (userName[1].." "..userName[2])
    local nameLabel = display.newText({
      parent = profileGroup,
      x=290,
      y=inProfilePhoto.y-30,
      text = userName,
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 24*2,
    })
    nameLabel:setFillColor( unpack(c.black) )
    nameLabel.anchorX = 0

    local sityLabel = display.newText({
      parent = profileGroup,
      x=290,
      y=inProfilePhoto.y+30,
      text = "Город: Якутск",
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 24*2,
    })
    sityLabel.anchorX = 0
    sityLabel:setFillColor( unpack(c.gray) )

    local line = display.newRect( profileGroup, q.cx, 380, q.fullw-100, 6 )
    line.fill = c.gray2
    line.alpha = 0

    local infoLabel = display.newText( {
      parent = profileGroup,
      text = "Данные",
      x=70,
      y=line.y+60,
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 24*2} )
    infoLabel.fill = c.black
    infoLabel.anchorX = 0

    local date = os.date("*t",tonumber(account.signupdate))
    local day = date.day<10 and "0"..date.day or date.day 
    local month = date.month<10 and "0"..date.month or date.month 
    local infoShow = {
      {day.."."..month.."."..date.year,"Дата регистрации"},
      {"1","ID"},
    }

    for i=1, #infoShow do
      local infoLabel = display.newText( {
      parent = profileGroup,
      text = infoShow[i][2],
      x=70,
      y=510+70*(i-1),
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 24*2} )
      infoLabel.anchorX = 0
      infoLabel.fill = c.gray

      local infoLabel = display.newText( {
      parent = profileGroup,
      text = infoShow[i][1],
      x=q.fullw-70,
      y=510+70*(i-1),
      font = "fonts/sah_roboto_b.ttf",
      fontSize = 24*2} )
      infoLabel.anchorX = 1
      infoLabel.fill = c.black
    end

    local line = display.newRect( profileGroup, q.cx,510+50*(#infoShow-1)+70, q.fullw-100, 6 )
    line.fill = c.gray2
    line.alpha = 0

    local lastY = line.y + 180
    local space = 130

    local logOut, lLabel = createButton(profileGroup, "Выйти",lastY) lastY = lastY + space
    
    q.event.add("logout", logOut, function()
      q.saveLogin({needGoogleOut=account.google})
      composer.gotoScene( "signin" )
      composer.removeScene( "menu" )
    end, "profile-popUp")


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
