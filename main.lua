push = require 'push'

Class = require 'class'

require 'Bird'
require 'Pipe'
require 'PipePair'

--all codes related to gamestate and state machines
require 'StateMachine'
require 'states/baseState'
require 'states/playState'
require 'states/ScoreState'
require 'states/TitleScreenState'
require 'states/CountdownState'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('background.png')
local backgroundscroll = 0

local ground = love.graphics.newImage('ground.png')
local groundscroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413

local bird = Bird()

--To keep track of all the pipes we are spawning

local pipepairs = {}

local spawntimer = 0

local lastY = -PIPE_HEIGHT + math.random(80) + 20

local scrolling = true

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())
    
    love.window.setTitle('Flappy50')

     -- initialize our nice-looking retro text fonts
     smallFont = love.graphics.newFont('font.ttf', 8)
     mediumFont = love.graphics.newFont('flappy.ttf', 14)
     flappyFont = love.graphics.newFont('flappy.ttf', 28)
     hugeFont = love.graphics.newFont('flappy.ttf', 56)
     love.graphics.setFont(flappyFont)

    sounds = {
        ['jump'] = love.audio.newSource('jump.wav', 'static'),
        ['explosion'] = love.audio.newSource('explosion.wav', 'static'),
        ['hurt'] = love.audio.newSource('hurt.wav', 'static'),
        ['score'] = love.audio.newSource('score.wav', 'static'),
        ['music'] = love.audio.newSource('marios_way.mp3', 'static')
    }

    --kick of music
    sounds['music']:setLooping(true)
    sounds['music']:play()

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end        
    }
    gStateMachine:change('title')   

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)    
end

function love.keypressed(key)
    
    love.keyboard.keysPressed[key] = true   

    if key == 'escape' then
        love.event.quit()
    end    
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end 
end

function love.update(dt)
    backgroundscroll = (backgroundscroll + BACKGROUND_SCROLL_SPEED * dt)
        % BACKGROUND_LOOPING_POINT
        
    groundscroll = (groundscroll + GROUND_SCROLL_SPEED * dt)
        %VIRTUAL_WIDTH

    gStateMachine:update(dt)

    --reset input table
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    love.graphics.draw(background, -backgroundscroll, 0)

    gStateMachine:render()

    love.graphics.draw(ground, -groundscroll, VIRTUAL_HEIGHT - 16)

    push:finish()

end