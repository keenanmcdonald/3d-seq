-- 3D sequencer for crow + just friends
-- ii -> JF
-- E1: BPM
-- E2: length of sequence (right)
-- E3: length of sequence (left)
-- K2: start/stop

m_util = require 'musicutil'
scale = m_util.generate_scale(0,"major",2)

local g = grid.connect()
local length = {4, 4}
local bpm = 100
local step = {1, 1}
local seq = {{}, {}}
local m = metro.init()
local run = false


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
  for i=1,2 do
    for j=1,3 do
      voice = j+(i*3-3)
      degree = seq[i][step[i]][j]
      if degree ~= 0 then
        print(degree)
        crow.ii.jf.play_voice(voice, scale[degree]/12-1, 1)
      end
    end
  end
  update()
end

function seq_init()
  for i=1,2 do
    for j=1,16 do
      seq[i][j] = {0,0,0}
    end
  end
end

function update()
  redraw()
  redraw_grid()
end

function redraw()
  screen.clear() 
  screen.move(4, 6)
  screen.text('bpm: ')
  screen.move(18, 6)
  screen.text(bpm)
  for i=1,2 do
    screen.move(((i-1)*60)+10, 20)
    screen.text('length: ')
    screen.move(((i-1)*60)+44, 20)
    screen.text(length[i])
    screen.move(((i-1)*60)+10, 40)
    screen.text('step: ')
    screen.move(((i-1)*60)+44, 40)
    screen.text(step[i])
  end
  screen.update()
end

function redraw_grid()
  g:all(0)
  for i=1,2 do
    for j=1,3 do
      x = 16-seq[i][step[i]][j]
      y = 8-(j+(i*3-3))
      g:led(x, y, 15)
      for k=(x+1),15 do
        g:led(k, y, 6)
      end
    end
    for j=1,length[i] do
      y = 15+i-i*8
      if (step[i] == j) then
        g:led(17-j, y, 12)
      else
        g:led(17-j, y, 3)
      end
    end
  end
  -- add length indicators on the side
  g:refresh()
end


function moveStep(v)
  for i=1,2 do
    if v==1 then
      if step[i] >= length[i] then
        step[i] = 1
      else
        step[i] = step[i] + 1
      end
    elseif v==-1 then
      if step[i] == 1 then
        step[i] = length[i]
      else
        step[i] = step[i] - 1
      end
    end
  end
end

function g.key(x, y, z)
  if y == 8 and z==1 and (17-x <= length[1]) then
    step[1] = 17-x
  elseif y == 1 and z==1 and (17-x <= length[2]) then
    step[2] = 17-x
  elseif y > 1 and y < 5 and z==1 then
    seq[2][step[2]][5-y] = 16-x
  elseif y>4 and y < 8 and z==1 then
    seq[1][step[1]][8-y] = 16-x
  end
  update()
end

function key(n, z)
  if n==2 and z==1 then
    if run then
      m:stop()
      run = false
    else
      m:start()
      run = true
    end
  end
end

function enc(n, z)
  if n==1 then
    bpm = util.clamp(bpm + z, 10, 200)
  elseif n==2 then
    length[1] = util.clamp(length[1]+z, 2, 16)
  elseif n==3 then
    length[2] = util.clamp(length[2]+z, 2, 16)
  end
  update()
end

