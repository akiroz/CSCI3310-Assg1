local physics = require("physics")
local composer = require( "composer" )

physics.start()
physics.setGravity(0,12)
--physics.pause()

local debug = false
local scrollSpeed = -120

local scene = composer.newScene()

function scene:create(sceneCreateEvent)
  local sceneGroup = self.view
  -- swipe to restart
  -- ###################################################################################
  function renderSwipeToRestart()
    display.newText(
      sceneGroup,
      "Swipe to restart",
      display.contentCenterX,
      display.contentCenterY,
      native.newFont())
    local r = display.newRect(
      sceneGroup,
      display.screenOriginX,
      display.screenOriginY,
      display.pixelWidth,
      display.pixelWidth)
    r.fill = {0,0,0,0.01}
    r.anchorX = 0
    r.anchorY = 0
    local function onTouch(e)
      if e.phase == "moved" then
        composer.removeScene("game")
        composer.gotoScene("game")
      end
    end
    r:addEventListener("touch", onTouch)
  end

  -- background
  -- ###################################################################################
  local backdrop = display.newRect(sceneGroup, 0, 0, display.pixelHeight, display.pixelWidth)
  backdrop:setFillColor(0.42, 0.37, 1)

  local scrollGroup = display.newGroup()
  sceneGroup:insert(scrollGroup)
  physics.addBody(scrollGroup, "kinematic")
  scrollGroup:setLinearVelocity(scrollSpeed, 0)

  local function createMountain(color, x)
    local vs = {0,0 , 200,-220 , 400,0}
    local m = display.newPolygon(scrollGroup, x, 220, vs)
    m.fill = color
  end
  local function createMountainRange(length)
    for i = 0, 360*length, 360 do
      createMountain({0.11, 0.34, 0.13}, i)
    end
    for i = -180, 360*length, 360 do
      createMountain({0.05, 0.24, 0.14}, i)
    end
  end

  -- obstacles
  -- ###################################################################################
  local function createLineSensor(x, color)
    local s = display.newRect(sceneGroup, 0, 0, 1, -10 * display.pixelHeight)
    s.x = x
    s.y = display.pixelHeight
    s.fill = {0,0,0,0}
    physics.addBody(s, "kinematic", { isSensor=true })
    s:setLinearVelocity(scrollSpeed, 0)
    if debug then s.fill = color end
    return s
  end

  local function createObstacle(img, w, h, x, y)
    local o = display.newImageRect(sceneGroup, img, w, h)
    o.x = x
    o.y = y
    o.role = "obstacle"
    physics.addBody(o, "kinematic", { isSensor=true })
    o:setLinearVelocity(scrollSpeed, 0)
    local s = createLineSensor(x, {0,0,1})
    s.role = "score"
    if debug then
      o.stroke = {1,0,0}
      o.strokeWidth = 1
    end
  end
  local function createHighrise(x)
    createObstacle("asset/highrise.png", 40, 140, x, 250)
  end
  local function createTower(x)
    createObstacle("asset/watertower_na.png", 60, 110, x, 270)
  end

  -- goal
  -- ###################################################################################
  local function createGoal(x)
    local g = createLineSensor(x, {0,1,0})
    g.role = "goal"
  end


  -- player
  -- ###################################################################################
  local function createPhoenix()
    local p = display.newImageRect(sceneGroup, "asset/CU-phoenix.png", 50, 50)
    p.x = display.contentCenterX
    p.y = display.contentCenterY
    physics.addBody(p)
    function p:tap()
      p:applyForce(0, -30, p.x, p.y)
    end
    function p:collision(event)
      local r = event.other.role
      if r == "score" then
        if event.phase == "ended" then
          incScore(1)
        end
      end
      if r == "obstacle" then
        physics.pause()
        p.isVisible = false
        local t = display.newText(
          sceneGroup,
          "Game Over",
          display.contentCenterX,
          display.screenOriginY + 30,
          native.newFont())
        t.fill = {1,0,0}
        renderSwipeToRestart()
      end
      if r == "goal" then
        physics.pause()
        local t = display.newText(
          sceneGroup,
          "You Win!",
          display.contentCenterX,
          display.screenOriginY + 30,
          native.newFont())
        t.fill = {0,0,1}
      end
    end
    p:addEventListener("tap")
    p:addEventListener("collision")
    if debug then
      p.stroke = {1,0,0}
      p.strokeWidth = 1
    end
  end

  -- floor
  -- ###################################################################################
  do
    local f = display.newRect(sceneGroup, 0, 0, display.pixelWidth, 1)
    f.anchorX = 0
    f.x = display.screenOriginX
    f.y = display.viewableContentHeight
    f.role = "obstacle"
    physics.addBody(f, "static")
    f.fill = {0,0,0,0}
    if debug then f.fill = {1,0,0} end
  end

  -- score
  -- ###################################################################################
  do
    local x = display.screenOriginX+40
    local y = display.screenOriginY+40
    local bg = display.newCircle(sceneGroup, x, y, 15)
    bg.fill = {0.2, 0.2, 0.2}
    score = display.newText(sceneGroup, 0, x+1, y-1, native.newFont())
    score.fill = {0.48, 1, 0.22}
  end
  function incScore(n)
    score.text = score.text + n
  end

  -- stage setup
  -- ###################################################################################

  createMountainRange(30)

  createHighrise(500)
  createTower(800)
  createHighrise(1200)
  createHighrise(1300)
  createTower(1600)
  createGoal(5000)

  createPhoenix()
end

scene:addEventListener( "create", scene )
return scene
