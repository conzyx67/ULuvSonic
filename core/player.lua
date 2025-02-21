local Player = {
    x = 100,
    y = 100,
    width = 32,
    height = 48,
    
    velocityX = 0,
    velocityY = 0,
    acceleration = 800,
    deceleration = 1200,
    maxSpeed = 800,
    jumpForce = -600,
    maxJumpForce = -700,
    jumpHoldTime = 0,
    maxJumpHoldTime = 0.15,
    gravity = 2000,
    slopeAcceleration = 400,
    
    isGrounded = false,
    isRolling = false,
    facingRight = true,
    
    currentAnimation = "idle",
    animationTimer = 0
}

function Player:new()
    local player = setmetatable({}, { __index = self })
    return player
end

function Player:update(dt)
    local input = love.keyboard.isDown('right') and 1 or (love.keyboard.isDown('left') and -1 or 0)
    
    if input ~= 0 then
        self.velocityX = self.velocityX + input * self.acceleration * dt
        self.facingRight = input > 0
    else
        local currentSpeed = math.abs(self.velocityX)
        local decel = math.max(currentSpeed * 4, self.deceleration) * dt
        if math.abs(self.velocityX) <= decel then
            self.velocityX = 0
        else
            self.velocityX = self.velocityX - (self.velocityX > 0 and decel or -decel)
        end
    end
    
    self.velocityX = math.min(math.max(self.velocityX, -self.maxSpeed), self.maxSpeed)
    
    if not self.isGrounded then
        self.velocityY = self.velocityY + self.gravity * dt
    end
    
    local nextX = self.x + self.velocityX * dt
    local nextY = self.y + self.velocityY * dt
    
    self.x = nextX
    self.y = nextY
    
    self:updateAnimation(dt)
    
    if self.y > 500 then
        self.y = 500
        self.velocityY = 0
        self.isGrounded = true
    end
end

function Player:jump()
    if self.isGrounded then
        self.velocityY = self.jumpForce
        self.isGrounded = false
        self.jumpHoldTime = 0
    elseif self.jumpHoldTime < self.maxJumpHoldTime and self.velocityY < 0 then
        local jumpBoost = (self.maxJumpForce - self.jumpForce) * (self.jumpHoldTime / self.maxJumpHoldTime)
        self.velocityY = self.jumpForce + jumpBoost
        self.jumpHoldTime = self.jumpHoldTime + love.timer.getDelta()
    end
end

function Player:updateAnimation(dt)
    self.animationTimer = self.animationTimer + dt
    
    if not self.isGrounded then
        self.currentAnimation = "jump"
    elseif math.abs(self.velocityX) > 50 then
        self.currentAnimation = "run"
    else
        self.currentAnimation = "idle"
    end
end

function Player:draw()
    love.graphics.setColor(0, 0.5, 1)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
    
    love.graphics.print(string.format(
        "State: %s\nVel: %.1f, %.1f",
        self.currentAnimation,
        self.velocityX,
        self.velocityY
    ), self.x - 40, self.y - self.height - 40)
end

return Player
