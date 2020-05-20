-- 3D sequencer for crow + just friends
-- ii -> JF
-- E2: Length of Sequence
-- E3: BPM
-- K2: start/stop

m_util = require 'musicutil'
scale = m_util.generate_scale(0,"major",2)


local g = grid.connect()
local length = 8
local bpm = 100
local step = 1
local seq = {}
local m = metro.init()



function init()
  seq_init()
  m.time = 60/bpm
  m.event = function()
    advance()
  end
  crow.ii.pullup(true)
  crow.ii.jf.mode(1)
  update()
end

function advance()
  moveStep(1)
  crow.ii.jf.vtrigger(0, 1)
  for i=1,6 do
    crow.ii.jf.play_voice(i, scale[seq[step][i]]/12-1,math.random(5)+1)
  end
  update()
end

function seq_init()
  for i=1,32 do
    seq[i] = {1,1,1,1,1,1}
  end
end

function update()
  redraw()
  redraw_grid()
end

function redraw()
  screen.clear() 
  screen.move(10, 20)
  screen.text('bpm: ')
  screen.move(30, 20)
  screen.text(bpm)
  screen.move(60, 20)
  screen.text('length: ')
  screen.move(90, 20)
  screen.text(length)
  screen.move(10, 40)
  screen.text('step: ')
  screen.move(32, 40)
  screen.text(step)
  screen.update()
end

function redraw_grid()
  g:all(0)
  g:led(1,1,6)
  g:led(1,8,6)
  for i=1,6 do
    x = 17-seq[step][i]
    y = 8-i
    g:led(x, y, 15)
  end
  g:refresh()
end

function moveStep(v)
  if v==1 then
    if step == length then
      step = 1
    else
      step = step + v
    end
  elseif v==-1 then
    if step == 1 then
      step = length
    else
      step = step - 1
    end
  end
end

    
  

function g.key(x, y, z)
  if x==1 and y==1 and z==1 then
    moveStep(1)
  elseif x==1 and y==8 and z==1 then
    moveStep(-1)
  elseif y > 1 and y < 8 and z==1 then
    seq[step][8-y] = 17-x
  end
  update()
end

function key(n, z)
  if n==2 and z==1 then
    m:start()
  end
end

function enc(n, z)
  if n==2 then
    bpm = util.clamp(bpm + z, 10, 200)
  elseif n==3 then
    length = util.clamp(length+z, 2, 32)
  end
  update()
end

