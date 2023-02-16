local nowScene = ""
local mainScenes = {}
local scenes = {}
local eventSystem

local function changeLayer(toScene, group)

  if nowScene==toScene then return end

    -- print("hiding from "..nowScene.." to "..toScene)
    native.setKeyboardFocus( nil )
		
    eventSystem.event.group.off(nowScene.."-popUp")
    if scenes[#scenes-1].onHide then --!!! 
      -- print(scenes[#scenes-1].name,"ONHIDE")
      scenes[#scenes-1].onHide()
    end
    if scenes[#scenes].onShow then
      scenes[#scenes].onShow()
    end
    
    nowScene = toScene
end 

local to = {}
local loaders = {}
to.removePop = function()
  if #scenes==1 then return end

  local removingScene = scenes[#scenes]
  if removingScene.onHide then
    removingScene.onHide()
  end

  eventSystem.event.group.remove(removingScene.name.."-popUp")
  
  display.remove(removingScene.group)

  scenes[#scenes] = nil
  
  
  nowScene = scenes[#scenes].name
  eventSystem.event.group.on(nowScene.."-popUp")

  timer.performWithDelay( 1, function()

    native.setKeyboardFocus( nil )

  end )

  if #scenes==1 and scenes[1].reload then
    scenes[1].reload()
  end
  if scenes[#scenes].onShow then
    scenes[#scenes].onShow()
  end
end

to.addMainScene = function( name, group, eventsFunction )
  if mainScenes[name]~=nil then error("Main scene '"..name.."' already exsist") end
  mainScenes[name] = eventsFunction or {}
  mainScenes[name].group = group
  mainScenes[name].name = name
  if nowScene=="" then 
    nowScene=name 
    -- print("PREEI",name)
    scenes={mainScenes[name]}  
    if eventsFunction.reload then print("REKIADDD") eventsFunction.reload() end
  end
  -- print(scenes[1].name.." = {")
  for k, v in pairs(mainScenes) do
    -- print("  ",k,"!!",v.group)
  end
  -- print("}")
end

function to.getName( groupName )
  local i = 1
  local doo = true
  
  while doo do
    local noFound = true
    for j=1, #scenes do
      -- print(j.."# "..scenes[j].name.." /"..#scenes)
      if groupName..tostring(i) == scenes[j].name then
        -- print("занято")
        i = i + 1
        noFound = false
        break
      end
    end
    if noFound then doo = false 
      -- print( groupName..tostring(i),"свободен")  
    end

  end
  return groupName..tostring(i)
end

local function removeLoaded()
  -- print("loader clear",#loaders[1].events)
  for i=1, #loaders[1].events do
    -- print("loader clear")
    eventSystem.event.remove(loaders[1].events[i], loaders[1].name.."-loader")
  end
  eventSystem.event.group.remove(loaders[1].name.."-loader")
  display.remove(loaders[1].group)
  loaders = {}
end 

function to.reload( mainName, group )
  if scenes[1].name~=mainName then error("Reload non active mainscene") end
  local NumName = to.getName( mainName )
  if mainScenes[NumName]~=nil or mainScenes[realName]~=nil then error("PopUp has the same name with mainscen: "..realName) end
  scenes[1].group:insert(group)
  
  
  loaders[#loaders+1] = {}
  loaders[#loaders].group=group
  loaders[#loaders].name=NumName
  local events = {}
  loaders[#loaders].events = events
  -- print("add loader", NumName, #loaders)
  
  eventSystem.event.group.add( mainName.."-loader",{})

  return NumName.."-loader", events
end

function to.mainScene( name )
  for i=1, #scenes-1 do
    to.removePop()
  end
  -- print("hide main",scenes[1].name)
  if #loaders~=0 then removeLoaded() end
  if scenes[1].name==name then if scenes[1].reload then scenes[1].reload() end return end
  if scenes[1].onHide then scenes[1].onHide() end
  scenes[1].group.alpha = 0
  
  scenes[1] = mainScenes[name]
  -- print("change main to",name)
  scenes[1].group.alpha = 1
  if scenes[1].onShow then scenes[1].onShow() end
  nowScene = name
  if scenes[1].reload then scenes[1].reload() end
end



function to.popUp( realName, group, eventsFunction )
  local NumName = to.getName( realName )
  
  if group==nil then error("PopUp group is nil: "..realName) end
  if mainScenes[NumName]~=nil or mainScenes[realName]~=nil then error("PopUp has the same name with mainscen: "..realName) end
  if #loaders~=0 and #scenes==1 then removeLoaded() end
  scenes[1].group:insert(group)
  
  scenes[#scenes+1] = eventsFunction or {}
  scenes[#scenes].name=NumName
  scenes[#scenes].group=group
  -- print("add scene", NumName, #scenes)
  
  changeLayer(NumName, group)
  eventSystem.event.group.add(NumName.."-popUp",{})

  return NumName.."-popUp"
end
function to.init(q)
  if eventSystem~=nil then error("Can use two eventSystem") end 
  eventSystem = q
end
function to.reset()
  -- print("reset")
  for k,v in pairs(mainScenes) do
    -- print("removig ",k,v)
    display.remove(v.group)
    eventSystem.event.group.remove(v.name.."-popUp")
  end
  eventSystem.event.clearAll()

  nowScene = ""
  mainScenes = {}
  scenes = {}
  eventSystem = nil
end


return to

--- П Р И М Е Р Ы ---
--[[ 

-- Создание главной сцены без загрузки из интернета
function scene:create( event )

  local sceneGroup = self.view

  mainGroup = display.newGroup()
  sceneGroup:insert(mainGroup)

  do

    topMain = display.newGroup()
    mainGroup:insert( topMain )

    local logo = display.newImageRect( topMain, "img/logo.png",85*2,85*2 )
    logo.x, logo.y = 18*2 + 10, 18*2 - 20

    pps.addMainScene("home", topMain, {
      onShow = function()
      end
    })
    q.event.group.on("home-popUp") -- АКТИВАЦИЯ ПРИ ДОБАВЛЕНИИ ВСЕХ ОБЪЕКТОВ
  end

end

-- -- --
-- Создание главной сцены с единоразовой загрузкой из интернета
local data
local function responser(event)
  date = event.response
  
  local logo = display.newImageRect( topMain, "img/logo.png",85*2,85*2 )
  logo.x, logo.y = 18*2 + 10, date.x 

  q.event.group.on("home-popUp") -- запуск после получения данных
end

function scene:create( event )

  local sceneGroup = self.view

  mainGroup = display.newGroup() -- Группа основного экрана
  sceneGroup:insert(mainGroup)

  do

    topMain = display.newGroup()
    mainGroup:insert( topMain )

    local logo = display.newImageRect( topMain, "img/logo.png",85*2,85*2 )
    logo.x, logo.y = 18*2 + 10, 18*2 - 20


    pps.addMainScene("home", topMain, {
      onShow = function()
      end
    })
    
  end

  https.request( url, "GET", responser)

end

-- -- --
-- Создание главной сцены с изменяемыми кнопками
local data
local function responser(event)
  date = event.response
  
  local logo = display.newImageRect( topMain, "img/logo.png",85*2,85*2 )
  logo.x, logo.y = 18*2 + 10, date.x 

  q.event.group.on("home-popUp") -- запуск после получения данных
end

function scene:create( event )

  local sceneGroup = self.view

  mainGroup = display.newGroup() -- Группа основного экрана
  sceneGroup:insert(mainGroup)

  do

    topMain = display.newGroup()
    mainGroup:insert( topMain )

    local logo = display.newImageRect( topMain, "img/logo.png",85*2,85*2 )
    logo.x, logo.y = 18*2 + 10, 18*2 - 20


    pps.addMainScene("home", topMain, {
      onShow = function()
      end
    })
    
  end

  https.request( url, "GET", responser)

end
]]
