local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 600
local GAME_TITLE = "ULuvSonic"

local gameState = {
    current = "play"
}

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.window.setTitle(GAME_TITLE)
    love.graphics.setDefaultFilter("nearest", "nearest")
    
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
    if gameState.current == "play" then
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

function love.draw()
    if gameState.current == "play" then
        love.graphics.setColor(0.2, 0.2, 0.2)
        for i = 0, WINDOW_WIDTH, 50 do
            love.graphics.line(i, 0, i, 500)
        end
        for i = 0, 500, 50 do
            love.graphics.line(0, i, WINDOW_WIDTH, i)
        end
        
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", 0, 500, WINDOW_WIDTH, WINDOW_HEIGHT - 500)
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.line(0, 500, WINDOW_WIDTH, 500)
        
        love.graphics.setColor(0.3, 0.3, 0.3)
        for _, slope in ipairs(collision.slopes.slopes) do
            love.graphics.line(slope.x1, slope.y1, slope.x2, slope.y2)
        end
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("ULuvSonic Engine - Development in Progress", 10, 10)
        
        player:draw()
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
