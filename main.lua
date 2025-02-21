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

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.window.setTitle(GAME_TITLE)
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    titlecard = love.graphics.newImage("assets/titlecard/titlecard.png")
    
    Player = require('core.player')
    Slopes = require('core.slopes')
    Collision = require('core.collision')
    player = Player:new()
    slopes = Slopes
    collision = Collision
    
    collision.slopes:addSlope(100, 400, 300, 300, "normal")
    collision.slopes:addSlope(300, 300, 500, 400, "normal")
    collision.slopes:addSlope(550, 500, 650, 350, "steep")
    collision.slopes:addSlope(650, 350, 750, 500, "steep")
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
        -- Only update player if transition is complete
        if gameState.titleAlpha <= 0 then
            player:update(dt)
            
            local onSlope, slopeY, slopeType, currentAngle = collision.slopes:checkCollision(player.x, player.y + player.height)
            
            local nextX = player.x + player.velocityX * dt
            local nextY = player.y + player.velocityY * dt
            local willBeOnSlope, nextSlopeY, nextSlopeType, nextAngle = collision.slopes:checkCollision(nextX, nextY + player.height)
        
        if onSlope or (willBeOnSlope and player.velocityY >= 0) then
            local targetY = willBeOnSlope and nextSlopeY or slopeY
            local targetType = willBeOnSlope and nextSlopeType or slopeType
            local angle = willBeOnSlope and nextAngle or currentAngle
            
            player.y = targetY - player.height
            player.isGrounded = true
            
            if angle then
                local slopeDirection = (angle > 0) and -1 or 1
                local slopeForce = math.abs(math.sin(angle)) * player.slopeAcceleration
                
                if targetType == "steep" then
                    slopeForce = slopeForce * 2
                end
                
                player.velocityX = player.velocityX + (slopeForce * slopeDirection) * dt
                
                local slopeAngleY = math.cos(angle)
                player.velocityY = math.abs(player.velocityX) * slopeAngleY
                
                player.velocityY = player.velocityY + (100 * slopeAngleY * dt)
            end
        else
            if player.y + player.height < 500 then
                player.isGrounded = false
            end
        end
        
        if love.keyboard.isDown('space') then
            player:jump()
        end
    end
end
end

function love.draw()
    -- Draw grid background
    love.graphics.setColor(0.2, 0.2, 0.2)
    for i = 0, WINDOW_WIDTH, 32 do
        love.graphics.line(i, 0, i, WINDOW_HEIGHT)
    end
    for i = 0, WINDOW_HEIGHT, 32 do
        love.graphics.line(0, i, WINDOW_WIDTH, i)
    end
    
    -- Draw ground cube
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", 0, 500, WINDOW_WIDTH, WINDOW_HEIGHT - 500)
    
    -- Draw game elements
    love.graphics.setColor(1, 1, 1)
    slopes:draw()
    player:draw()
    
    if gameState.current == "title" or gameState.titleAlpha > 0 then
        -- Draw black background with fade
        love.graphics.setColor(0, 0, 0, gameState.titleAlpha)
        love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
        
        -- Draw title card with fade
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
