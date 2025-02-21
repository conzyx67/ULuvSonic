local Physics = {
    -- Constants
    GRAVITY = 2000,
    GROUND_Y = 500,
    
    -- Movement constants
    DEFAULT_ACCELERATION = 800,
    DEFAULT_DECELERATION = 1200,
    DEFAULT_MAX_SPEED = 800,
    DEFAULT_JUMP_FORCE = -600,
    DEFAULT_MAX_JUMP_FORCE = -700,
    DEFAULT_SLOPE_ACCELERATION = 400,
    
    -- Jump settings
    DEFAULT_MAX_JUMP_HOLD_TIME = 0.15
}

function Physics:updateHorizontalMovement(entity, input, dt)
    if input ~= 0 then
        -- Check if input direction is opposite to current movement
        local isOppositeDirection = (input > 0 and entity.velocityX < 0) or (input < 0 and entity.velocityX > 0)
        
        if isOppositeDirection then
            -- Apply stronger deceleration when moving in opposite direction
            local oppositeDecel = entity.deceleration * 2 * dt
            entity.velocityX = entity.velocityX + (input * oppositeDecel)
        else
            -- Normal acceleration
            entity.velocityX = entity.velocityX + input * entity.acceleration * dt
        end
        entity.facingRight = input > 0
    else
        local currentSpeed = math.abs(entity.velocityX)
        local decel = math.max(currentSpeed * 4, entity.deceleration) * dt
        if math.abs(entity.velocityX) <= decel then
            entity.velocityX = 0
        else
            entity.velocityX = entity.velocityX - (entity.velocityX > 0 and decel or -decel)
        end
    end
    
    entity.velocityX = math.min(math.max(entity.velocityX, -entity.maxSpeed), entity.maxSpeed)
end

function Physics:updateVerticalMovement(entity, dt)
    if not entity.isGrounded then
        entity.velocityY = entity.velocityY + self.GRAVITY * dt
    end
    
    local nextX = entity.x + entity.velocityX * dt
    local nextY = entity.y + entity.velocityY * dt
    
    return nextX, nextY
end

function Physics:handleJump(entity, dt)
    if entity.isGrounded then
        entity.velocityY = entity.jumpForce
        entity.isGrounded = false
        entity.jumpHoldTime = 0
    elseif entity.jumpHoldTime < entity.maxJumpHoldTime and entity.velocityY < 0 then
        local jumpBoost = (entity.maxJumpForce - entity.jumpForce) * 
                         (entity.jumpHoldTime / entity.maxJumpHoldTime)
        entity.velocityY = entity.jumpForce + jumpBoost
        entity.jumpHoldTime = entity.jumpHoldTime + dt
    end
end

function Physics:handleSlopeMovement(entity, angle, slopeType, dt)
    if angle then
        local slopeDirection = (angle > 0) and -1 or 1
        local slopeForce = math.abs(math.sin(angle)) * entity.slopeAcceleration
        
        if slopeType == "steep" then
            slopeForce = slopeForce * 2
        end
        
        entity.velocityX = entity.velocityX + (slopeForce * slopeDirection) * dt
        
        local slopeAngleY = math.cos(angle)
        entity.velocityY = math.abs(entity.velocityX) * slopeAngleY
        entity.velocityY = entity.velocityY + (100 * slopeAngleY * dt)
    end
end

function Physics:checkGroundCollision(entity)
    if entity.y > self.GROUND_Y then
        entity.y = self.GROUND_Y
        entity.velocityY = 0
        entity.isGrounded = true
        return true
    end
    return false
end

return Physics
