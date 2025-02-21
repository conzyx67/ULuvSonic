local Physics = require('core.physics')

local Player = {
    x = 100,
    y = 100,
    width = 32,
    height = 48,
    
    velocityX = 0,
    velocityY = 0,
    acceleration = Physics.DEFAULT_ACCELERATION,
    deceleration = Physics.DEFAULT_DECELERATION,
    maxSpeed = Physics.DEFAULT_MAX_SPEED,
    jumpForce = Physics.DEFAULT_JUMP_FORCE,
    maxJumpForce = Physics.DEFAULT_MAX_JUMP_FORCE,
    jumpHoldTime = 0,
    maxJumpHoldTime = Physics.DEFAULT_MAX_JUMP_HOLD_TIME,
    slopeAcceleration = Physics.DEFAULT_SLOPE_ACCELERATION,
    
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
    
    Physics:updateHorizontalMovement(self, input, dt)
    local nextX, nextY = Physics:updateVerticalMovement(self, dt)
    
    self.x = nextX
    self.y = nextY
    
    self:updateAnimation(dt)
    
    Physics:checkGroundCollision(self)
end

function Player:jump()
    Physics:handleJump(self, love.timer.getDelta())
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
