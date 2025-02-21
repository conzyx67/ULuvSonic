local Collision = {}

Collision.slopes = {
    slopes = {}
}

function Collision.slopes:checkCollision(x, y)
    for _, slope in ipairs(self.slopes) do
        if x >= slope.x1 - 5 and x <= slope.x2 + 5 then
            local progress = (x - slope.x1) / (slope.x2 - slope.x1)
            local slopeY = slope.y1 + (slope.y2 - slope.y1) * progress
            
            local verticalTolerance = 5
            local distanceToSlope = math.abs(y - slopeY)
            
            if distanceToSlope <= verticalTolerance then
                local angle = math.atan2(slope.y2 - slope.y1, slope.x2 - slope.x1)
                local adjustedY = slopeY
                
                if angle ~= 0 then
                    local slopeNormalY = -math.sin(angle)
                    adjustedY = slopeY - (verticalTolerance * 0.5)
                end
                
                return true, adjustedY, slope.type, angle
            end
        end
    end
    return false, nil, nil, nil
end

function Collision.slopes:addSlope(x1, y1, x2, y2, slopeType)
    table.insert(self.slopes, {
        x1 = x1,
        y1 = y1,
        x2 = x2,
        y2 = y2,
        type = slopeType or "normal"
    })
end

function Collision:checkMapCollision(nextX, nextY, player, scale, collisionMapData)
    local mapX = math.floor(nextX / scale)
    local mapY = math.floor((nextY + player.height) / scale)
    
    local canMove = true
    if mapX >= 0 and mapX < collisionMapData:getWidth() and mapY >= 0 and mapY < collisionMapData:getHeight() then
        local r, g, b, a = collisionMapData:getPixel(mapX, mapY)
        if r > 0 then
            canMove = false
            player.isGrounded = true
            player.velocityY = 0
            nextY = (mapY * scale) - player.height
        else
            player.isGrounded = false
        end
    end
    
    if canMove then
        player.isGrounded = false
    end
    
    return nextX, nextY
end

return Collision
