local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 600
local GAME_TITLE = "ULuvSonic"

local gameState = {
    current = "title",
    titleAlpha = 1,
    titleY = WINDOW_HEIGHT / 2,
    transitionTimer = 0
}

local titlecard
local collisionMap
local collisionMapData

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.window.setTitle(GAME_TITLE)
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    titlecard = love.graphics.newImage("assets/titlecard/titlecard.png")
    collisionMap = love.graphics.newImage("assets/collisionmap/collision1.png")
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    local imageData = love.image.newImageData("assets/collisionmap/collision1.png")
    collisionMapData = imageData
    
    Player = require('core.player')
    Slopes = require('core.slopes')
    Collision = require('core.collision')
    player = Player:new()
    slopes = Slopes
    collision = Collision
end

function love.update(dt)
    if gameState.current == "title" then
        gameState.transitionTimer = gameState.transitionTimer + dt
        
        if gameState.transitionTimer >= 2 then
            gameState.titleAlpha = math.max(0, gameState.titleAlpha - dt)
            gameState.titleY = gameState.titleY - 200 * dt
            
            if gameState.titleAlpha <= 0 then
                gameState.current = "play"
            end
        end
    elseif gameState.current == "play" then
        if gameState.titleAlpha <= 0 then
            player:update(dt)
            
            local nextX = player.x + player.velocityX * dt
            local nextY = player.y + player.velocityY * dt
            
            local scale = math.min(WINDOW_WIDTH / collisionMap:getWidth(), WINDOW_HEIGHT / collisionMap:getHeight())
            nextX, nextY = collision:checkMapCollision(nextX, nextY, player, scale, collisionMapData)
            
            player.x = nextX
            player.y = nextY
        
            if love.keyboard.isDown('space') then
                player:jump()
            end
        end
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    local scale = math.min(WINDOW_WIDTH / collisionMap:getWidth(), WINDOW_HEIGHT / collisionMap:getHeight())
    love.graphics.draw(collisionMap, 0, 0, 0, scale, scale)
    
    love.graphics.setColor(1, 1, 1)
    player:draw()
    
    if gameState.current == "title" or gameState.titleAlpha > 0 then
        love.graphics.setColor(0, 0, 0, gameState.titleAlpha)
        love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
        
        love.graphics.setColor(1, 1, 1, gameState.titleAlpha)
        
        local scale = math.min(WINDOW_WIDTH / titlecard:getWidth(), WINDOW_HEIGHT / titlecard:getHeight())
        local scaledWidth = titlecard:getWidth() * scale
        local scaledHeight = titlecard:getHeight() * scale
        local titleX = (WINDOW_WIDTH - scaledWidth) / 2
        local titleY = gameState.titleY - scaledHeight / 2
        
        love.graphics.draw(titlecard, titleX, titleY, 0, scale, scale)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
