-- title:  Pixman
-- author: sroccaserra
-- desc:   Pix FTW!
-- script: lua

local must_init = true

function TIC()
    if must_init then
        _init()
        must_init = false
    end
    _draw()
    _update()
end

function _init()
    music(0)
    world:init()
    pixman:init()
end

function _update()
    world:update()
    pixman:update(world)
end

function _draw()
    world:draw()
    pixman:draw()
end

-->8
-- world logic

world = {
    width = 240,
    height = 136,
    layer_x_position = 0,
    layer_y_position = 0,
    has_gravity = false,
    score = 0,
    coins = {}
}

function world:init()
    table.insert(self.coins, coin_prototype:new(81, 39))
    for x = 45, 81, 9 do
        for y = 60, 110, 10 do
            table.insert(self.coins, coin_prototype:new(x, y))
        end
    end
end

function world:update()
    for i, coin in ipairs(self.coins) do
        if coin.visible and distance(pixman, coin) < 8 then
            self.has_gravity = true
            self.score = self.score + 1
            coin:hide()
        end
        coin:update(self)
    end

    self:update_background_layer_position()
end

function world:update_background_layer_position()
    self.layer_x_position = self.layer_x_position + .5
    self.layer_x_position = self.layer_x_position % self.width
    self.layer_y_position = self.layer_y_position + .5
    self.layer_y_position = self.layer_y_position % self.height
end

function world:draw()
    local sx = self.layer_x_position
    local sy = self.layer_y_position
    map(0, 0, 30, 17, sx, sy)
    map(0, 0, 30, 17, sx - self.width, sy - self.height)
    map(0, 0, 30, 17, sx, sy - self.height)
    map(0, 0, 30, 17, sx - self.width, sy)
    map(0, 17, 30, 17, 0, 0, 0)

    for i, coin in ipairs(self.coins) do
        coin:draw()
    end
    print('SCORE: ' .. self.score, 11, 11, 2)
    print('SCORE: ' .. self.score, 10, 10, 8)
end

-->8
-- animation prototype

animation_prototype = {}

function animation_prototype:new(frames, flip, ticks_by_frames)
    local o = {
        frames = frames,
        flip = flip,
        n_frame = 1,
        tick_count = 0,
        ticks_by_frames = ticks_by_frames or 4
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function animation_prototype:tick()
    self.tick_count = self.tick_count + 1
    if self.tick_count % self.ticks_by_frames == 0 then
        self:advance_frame()
    end
end

function animation_prototype:advance_frame()
    self.n_frame = self.n_frame + 1
    if self.n_frame > #self.frames then
        self.n_frame = 1
    end
end

function animation_prototype:sprite_number()
    return self.frames[self.n_frame]
end

-->8
-- pixman

pixman = {
    animations = {
        up = animation_prototype:new({272, 273, 274, 273}, 2),
        down = animation_prototype:new({272, 273, 274, 273}, 0),
        left = animation_prototype:new({256, 257, 258, 257}, 1),
        right = animation_prototype:new({256, 257, 258, 257}, 0)
    },
    speed = 1,
}

function pixman:init()
    self.x = 40
    self.y = 39
    self.dx = 0
    self.dy = 0
    local direction = 'right'
    self.direction = direction
    self.animation = self.animations[direction]
end

function pixman:update(world)
    self:update_pos(world)
    self:update_sprite()
end

function pixman:update_pos(world)
    self.dx = 0
    self.dy = 0
    if btn(2) then
        self.direction = 'left'
        self.dx = -self.speed
    elseif btn(3) then
        self.direction = 'right'
        self.dx = self.speed
    elseif btn(0) then
        self.direction = 'up'
        self.dy = -self.speed
    elseif btn(1) then
        self.direction = 'down'
        self.dy = self.speed
    end
    self.x = self.x + self.dx
    self.y = self.y + self.dy
    self:clamp(world)
end

function pixman:clamp(world)
    if self.x >= world.width then
        self.x = 0
    end
    if self.x < 0 then
        self.x = world.width
    end
    if self.y >= world.height then
        self.y = 0
    end
    if self.y < 0 then
        self.y = world.height
    end
end

function pixman:update_sprite()
    if self.dx ~= 0 or self.dy ~= 0 then
        self.animation = self.animations[self.direction]
        self.animation:tick()
    end
end

function pixman:draw()
    local flip = self.animation.flip
    local sprite_number = self.animation:sprite_number()
    pal(8, 2)
    pal(9, 2)
    spr(sprite_number, self.x + 1, self.y + 1, 0, 1, flip)
    pal()
    spr(sprite_number, self.x, self.y, 0, 1, flip)
end

-->8
-- coin prototpye

coin_prototype = {
    v_inc = 0.25
}

function coin_prototype:new(x, y)
    local o = {
        x = x,
        y = y,
        v_x = 0,
        v_y = 0,
        visible = true,
        animation = animation_prototype:new({259, 260, 261, 262}, 0, 6)
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function coin_prototype:update(world)
    if world.has_gravity then
        self:update_position()
        self:update_velocity()
    end
    self.animation:tick()
end

function coin_prototype:update_position()
    self.x = self.x + self.v_x
    self.y = self.y + self.v_y
end

function coin_prototype:get_gravity_direction()
    local direction_x = pixman.x - self.x
    local direction_y = pixman.y - self.y
    local length = norm(direction_x, direction_y)
    direction_x = direction_x / length
    direction_y = direction_y / length
    return direction_x, direction_y
end

function coin_prototype:update_velocity()
    local g_direction_x, g_direction_y = self:get_gravity_direction()
    self.v_x = self.v_x + self.v_inc*g_direction_x
    self.v_y = self.v_y + self.v_inc*g_direction_y
end

function coin_prototype:draw()
    if not self.visible then
        return
    end
    local sprite_number = self.animation:sprite_number()
    pal(4, 2)
    pal(9, 2)
    pal(14, 2)
    spr(sprite_number, self.x+1, self.y+1, 0)
    pal()
    spr(sprite_number, self.x, self.y, 0)
end

function coin_prototype:hide()
    if self.visible then
        self.visible = false
        -- sfx(3)
    end
end

-->8
-- math

function norm(x, y)
    return math.sqrt(x^2 + y^2)
end

function distance(point_a, point_b)
    return norm(point_b.x - point_a.x, point_b.y - point_a.y)
end

-->8
-- mem

-- swap c0 and c1 colors, call pal() to reset
function pal(c0,c1)
    if(c0==nil and c1==nil)then for i=0,15 do poke4(0x3FF0*2+i,i)end
    else poke4(0x3FF0*2+c0,c1)end
end
