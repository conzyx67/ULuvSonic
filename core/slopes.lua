local Slopes = {
    slopes = {
        {
            x1 = 100,
            y1 = 500,
            x2 = 300,
            y2 = 400,
            type = "gentle"
        },
        {
            x1 = 400,
            y1 = 500,
            x2 = 600,
            y2 = 350,
            type = "steep"
        }
    }
}

function Slopes:getAngleAt(x, y)
    for _, slope in ipairs(self.slopes) do
        if x >= slope.x1 and x <= slope.x2 then
            local progress = (x - slope.x1) / (slope.x2 - slope.x1)
            local slopeY = slope.y1 + (slope.y2 - slope.y1) * progress
            
            if math.abs(y - slopeY) < 10 then
                local dy = slope.y2 - slope.y1
                local dx = slope.x2 - slope.x1
                local angle = math.atan2(dy, dx)
                
                while angle > math.pi/2 do angle = angle - math.pi end
                while angle < -math.pi/2 do angle = angle + math.pi end
                
                return angle, slope.type
            end
        end
    end
    return nil
end

function Slopes:checkCollision(x, y)
    for _, slope in ipairs(self.slopes) do
        if x >= slope.x1 - 5 and x <= slope.x2 + 5 then
            local progress = (x - slope.x1) / (slope.x2 - slope.x1)
            local slopeY = slope.y1 + (slope.y2 - slope.y1) * progress
            
            local verticalTolerance = 10
            local distanceToSlope = math.abs(y - slopeY)
            
            if distanceToSlope <= verticalTolerance then
                local angle = math.atan2(slope.y2 - slope.y1, slope.x2 - slope.x1)
                local adjustedY = slopeY
                
                if angle ~= 0 then
                    local slopeNormalY = -math.sin(angle)
                    adjustedY = slopeY + (slopeNormalY * 2)
                end
                
                return true, adjustedY, slope.type
            end
        end
    end
    return false, nil, nil
end

function Slopes:draw()
    love.graphics.setColor(0.5, 0.5, 0.5)
    for _, slope in ipairs(self.slopes) do
        love.graphics.line(slope.x1, slope.y1, slope.x2, slope.y2)
    end
    love.graphics.setColor(1, 1, 1)
end

return Slopes
