pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- delivery
-- by flavipix and emans

-- const
game_states = {menu=1,menu_to_game=2,game=3,game_over=4}
title = 1 -- 1 or 2
hit_stop = 20

-- var
state = game_states.menu
gm = {}
pm = {}
e = {}
p = {}
local music_on = false

-- change the values down here  
-- in the function reset_var()
-- game var
local game_start = 0
local game_start_frm = 0
local hit_stop_frm

-- menu to game var
local menu_to_game_dur = 30
local menu_to_game_frm = 0

-- menu-var
local show_start = 20 
local not_show_start = 20
local menu_frm = 0
-- bisegnax menu
local t_cols = {10,1}
local t_col_i = 1
local t_frm = 0
local t_col_dur = 30
local t_col_dur_on_start = 3

-- game-over-var
local show_go_to_menu = 20
local not_show_go_to_menu = 20
local game_over_frm = 0
-- bisegnax game-over
local go_cols = {10,1}
local go_col_i = 1
local go_frm = 0
local go_col_dur = 30
-- debug


function _init()
	cartdata("delivery-1")
 high_score=dget(0)
	poke(0x5f2d,1)
 poke(0x5f5c,255)
	reset_var()
end

function _update()
	if state == game_states.menu then
		update_menu()
	elseif state == game_states.menu_to_game then
		update_menu_to_game()
	elseif state == game_states.game then
		update_game()
	elseif state == game_states.game_over then
		update_game_over()
	end
end

function _draw()
	if state == game_states.menu 
		or state == game_states.menu_to_game then
		draw_menu()
	elseif state == game_states.game then
		draw_game()
	elseif state == game_states.game_over then
		draw_game_over()
	end
end

function update_game()
	if gm.p_hit_enemy then
		hit_stop_frm += 1
		if hit_stop_frm >= hit_stop then 
			if not gm.game_over then
				gm.p_hit_enemy = false 
				p:move(player_sp)
			else
				state = game_states.game_over
			end
			hit_stop_frm = 0
		end
		return
	end
	game_start_frm += 1
	if game_start_frm < game_start then 
		return end
	start_music()
	gm:update()
	pm:update()
	for k,v in pairs(e) do
		v:update()
	end
	p:update()
end

function update_menu_to_game()
	menu_to_game_frm += 1
	if menu_to_game_frm > menu_to_game_dur then
		state = game_states.game 
		reset_var()
		sfx(4)
	end
	menu_frm += 1
	t_frm += 1
end

function update_menu()
	if btnp(🅾️) or btnp(❎) then
		state = game_states.menu_to_game 
		t_col_dur = t_col_dur_on_start
		--t_frm = 0
		--reset_var()
		sfx(10)
		--sfx(4)
	end
	menu_frm += 1
	t_frm += 1
end

function update_game_over()
	if btnp(🅾️) or btnp(❎) then
		state = game_states.menu 
		sfx(10)
	end
	game_over_frm += 1
	go_frm += 1
end

function draw_game()
	cls()
	map(0,0,0,0,16,16)
	gm:draw()
	for k,v in pairs(e) do
		v:draw()
	end
	p:draw()
	pm:draw()
	local s = ""..curr_timer
	print_ctr_w(s,3,10)
	spr(61,48,1)
end

function draw_menu()
	cls()
	--map(16,0,0,0,16,16)
	
	-- bisegnax
 local larghezza_totale = 103
 local x_centro = (128 - larghezza_totale) / 2
 local y_centro = 40 
		
	if t_frm <= t_col_dur then
		t_col_i = 1 
	elseif t_frm <= t_col_dur*2 then
		t_col_i = 2
	else
		t_frm = 0 
	end
	
	if title == 1 then
		disegna_parola_solida("delivery",x_centro+1,y_centro+1,9) -- bg
	 disegna_parola_solida("delivery",x_centro,y_centro,t_cols[t_col_i]) -- fg
 elseif title == 2 then
	 if t_col_i == 1 then
	 	disegna_parola_solida("delivery",x_centro+1,y_centro+1,9) -- bg
	 	disegna_parola_solida("delivery",x_centro,y_centro,t_cols[t_col_i]) -- fg
		else
			disegna_parola_solida("delivery",x_centro+1,y_centro+1,t_cols[1]) -- bg
		end
	end
	
 rectfill(0, 45, 128, 45, 0) 
	-- end bisegnax
	
	local s = "high score: "..gm.high_score
	print_ctr_w(s,64,7)
	if menu_frm <= show_start then
		print_ctr_w("press 🅾️ to start",76,7)
	elseif menu_frm >= show_start+not_show_start then
		menu_frm = 0
	end
	print_ctr_w("pico-8 @2026",112,9)
end

function draw_game_over()
	cls()
	--map(34,0,0,0,16,16)
	
	-- bisegnax
 local larghezza_testo = 116
 local x_testo = (128-larghezza_testo) / 2 -- coordinata x: 6
 local y_testo = 30 
 
 if go_frm <= go_col_dur then
		go_col_i = 1 
	elseif go_frm <= go_col_dur*2 then
		go_col_i = 2
	else
		go_frm = 0 
	end
	
 local stringa = "game_over"
 
	disegna_parola_solida_go(stringa,x_testo+1,y_testo+1,9) -- bg
	disegna_parola_solida_go(stringa,x_testo,y_testo,go_cols[go_col_i]) -- fg
 
 rectfill(0, 35, 128, 35, 0) 
	-- end bisegnax

	local s = "score: "..gm.score
	if gm.bad_ending then
		print_ctr_w("you're done...",50,8)
		print_ctr_w(s,60,7)
		print_ctr_w("your score will",72,7)
		print_ctr_w("not be registered",80,7)
	else
		print_ctr_w("delivery done!",50,7)
		if gm.record then
			s = "new high "..s
			print_ctr_w(s,60,10)
		else
			print_ctr_w(s,60,7)
		end
	end
	if game_over_frm <= show_go_to_menu then
		print_ctr_w("press 🅾️ to go to menu",100,7)
	elseif game_over_frm >= show_go_to_menu+not_show_go_to_menu then
		game_over_frm = 0
	end
end

-- resets all game variables (not high score)
function reset_var()
	gm = {}
	pm = {}
	e = {}
	p = {}
	
	gm = game_mng.new()
	pm = particle_manager:new()
	add(e,enemy.new(36,100,1,82))
	add(e,enemy.new(84,100,-1,82))
	p = player.new(player_sp)
	
	-- game var
 game_start = 110 -- 110 is perfect!
 game_start_frm = 0
 hit_stop_frm = 0
 
	-- menu-var
 show_start = 20 
 not_show_start = 20
 menu_frm = 0

	-- game-over-var
 show_go_to_menu = 20
 not_show_go_to_menu = 20
 game_over_frm = 0
 
 -- menu to game var
 menu_to_game_frm = 0

	-- bisegnax menu
 font_atari = {
  d = {1,1,0, 1,0,1, 1,0,1, 1,0,1, 1,1,0},
  e = {1,1,1, 1,0,0, 1,1,0, 1,0,0, 1,1,1},
  l = {1,0,0, 1,0,0, 1,0,0, 1,0,0, 1,1,1},
  i = {1,1,1, 0,1,0, 0,1,0, 0,1,0, 1,1,1},
  v = {1,0,1, 1,0,1, 1,0,1, 1,0,1, 0,1,0},
  r = {1,1,0, 1,0,1, 1,1,0, 1,0,1, 1,0,1},
  y = {1,0,1, 1,0,1, 0,1,0, 0,1,0, 0,1,0}
 }
 
	t_col_i = 1
	t_frm = 0
	t_col_dur = 30
	t_col_dur_on_start = 4
	
	-- bisegnax game over
 font_atari_go = {
  g = {1,1,1, 1,0,0, 1,0,1, 1,0,1, 1,1,1},
  a = {1,1,1, 1,0,1, 1,1,1, 1,0,1, 1,0,1},
  m = {1,0,1, 1,1,1, 1,0,1, 1,0,1, 1,0,1},
  e = {1,1,1, 1,0,0, 1,1,0, 1,0,0, 1,1,1},
  o = {1,1,1, 1,0,1, 1,0,1, 1,0,1, 1,1,1},
  v = {1,0,1, 1,0,1, 1,0,1, 1,0,1, 0,1,0},
  r = {1,1,0, 1,0,1, 1,1,0, 1,0,1, 1,0,1},
  ["_"] = {0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0} 
	}
	
 go_col_i = 1
 go_frm = 0
 go_col_dur = 30
end

function start_music()
	if not music_on then
		music(0)
		music_on = true
	end
end

function stop_music()
	music(-1)
	music_on = false
end

function disegna_parola_solida(testo, x, y, col)
 local cx = x
 for i=1, #testo do
  local let = sub(testo, i, i)
  local dati = font_atari[let]

  if dati != nil then
   for r=0, 4 do
    for c=0, 2 do
     local idx = r * 3 + c + 1
     if dati[idx] == 1 then
      local px = cx + c * 4
      local py = y + r * 2

      -- riempie un blocco di 4x2 pixel senza lasciare buchi
      rectfill(px, py, px + 3, py + 1, col)
     end
    end
   end
  end
  cx += 13 -- spazio fisso tra le lettere
 end
end

function disegna_parola_solida_go(testo,x,y,col)
 local cx = x
 for i=1, #testo do
  local let = sub(testo, i, i)
  local dati = font_atari_go[let]
  
  if dati != nil then
   for r=0,4 do         
    for c=0,2 do     
     local idx = r*3+c+1
     if dati[idx] == 1 then
      local px = cx+c*4
      local py = y+r*2  
      rectfill(px,py,px+3,py+1,col)
     end
    end
   end
  end
  cx += 13 
 end
end
-->8
-- vector2 --

vector2 = {}
vector2.__index = vector2

function vector2.new(x,y)
	return setmetatable({x=x,y=y},vector2)
end

function vector2.__tostring(v)
 return "("..v.x..", "..v.y..")"
end 

function vector2.__eq(v1,v2)
 return v1.x == v2.x and v1.y == v2.y
end

function vector2.__add(v1,v2)
	return vector2.new(v1.x+v2.x,v1.y+v2.y)
end

function vector2.__mul(v1,v2)
	return vector2.new(v1.x*v2.x,v1.y*v2.y)
end

function vector2:clone()
	return vector2.new(self.x,self.y)
end

-- never use ^ for pow
-- never. 
-- it breaks everything 
-- with floats
--function vector2:dist(v)
	--return sqrt(pow((self.x-v.x),2)+pow((self.y-v.y),2))
--end
function vector2:dist(v)
	dx = abs(self.x-v.x)
	dy = abs(self.y-v.y)
	ma = max(dx,dy)
	mi = min(dx,dy)
	if ma == 0 then return 0 end
	return ma*sqrt(1+(mi/ma)*(mi/ma))
end

-->8
-- utils --

function print_ctr_w(s,y,col)
	local x = 64-(#s*4)/2
 print(s,64-#s*2,y,col)
end

function print_ctr_h(s,x,col)
 print(s,x,61,col)
end

function print_ctr(s,col)
	print(s,64-#s*2,61,col)
end

function pow(x,a)
  if (a==0) return 1
  if (a<0) x,a=1/x,-a
  local ret,a0,xn=1,flr(a),x
  a-=a0
  while a0>=1 do
    if (a0%2>=1) ret*=xn
    xn,a0=xn*xn,shr(a0,1)
  end
  while a>0 do
    while a<1 do x,a=sqrt(x),a+a end
    ret,a=ret*x,a-1
  end
  return ret
end

-- collisions
function collide_rect(ax, ay, aw, ah, bx, by, bw, bh)
 return ax < bx + bw and
        ax + aw > bx and
        ay < by + bh and
        ay + ah > by
end

function collide_circle(x1,y1,r1,x2,y2,r2)
 local dx = x2-x1
 local dy = y2-y1
 local dist_sq = dx*dx+dy*dy
 local radius_sum = r1+r2
 return dist_sq < radius_sum*radius_sum
end
-->8
-- player --

player = {}
player.__index = player

-- const
local invincible = false
local ignore_spikes = false
local g = 0.15 --0.35
local jump_vel = -2 -- -4
local max_fall = 1.5 -- 3

local vel = 2 --3
local spd = 0
local mov_frm = 0
local sprt_helix = {4,5}
local sprt = 3
local claw_sprts = {unhooked=6,hooked=59}
-- each helix spr lasts 2 frm
local c_helix_dur = 2

local kz = {-14,115}

-- var
local helix_dur
local claw_sprt
local vel_y
local o_vel_y
-- base

function reset_var_player()
	helix_dur = c_helix_dur
	claw_sprt = claw_sprts.unhooked
	vel_y = 0
	o_vel_y = -2
end

function player.new(pos)
	reset_var_player()
	return setmetatable({pos=pos,sprt=sprt,hooked=false,box=nil,h_sprt=sprt_helix[1],h_sprt_i=1,h_timer=0,o_y=pos.y},player)
end

function player:update()
	if not self.box then 
		self:unhook()
	elseif self.box.destroy then
		self:unhook()
	end
	self:update_anim()
	self:handle_input()
	self:clamp()
	self:apply_gravity()
	self:check_collisions()
end

function player:update_anim()
	if vel_y < 0 and abs(vel_y) >= abs(jump_vel)*0.5 then
		helix_dur = 0
	elseif vel_y < 0 and abs(vel_y) >= abs(jump_vel)*0.2 then
		helix_dur = 1
	else
		helix_dur = c_helix_dur
	end
	self.h_timer += 1
	if self.h_timer > helix_dur then
		self.h_sprt_i = (self.h_sprt_i%#sprt_helix)+1
		self.h_sprt = sprt_helix[self.h_sprt_i]
		self.h_timer = 0
	end
end

-- temp
function player:handle_input()
	--[[ particles
	if btnp(❎) then 
		pm:box_destroyed(self.pos+vector2.new(4,4)) end
	if btnp(🅾️) then
		pm:box_shipped(self.pos+vector2.new(4,4)) end
	-- end particles]]
	
	self.o_y = self.pos.y
	o_vel_y = vel_y
	local lx = self.pos.x
	local ly = self.pos.y
	local x = self.pos.x
	local y = self.pos.y
	local velx = vel
	local vely = vel
	
	if btn(➡️) then
		x += vel end
	if btn(⬅️) then
		x -= vel end
	
	self:move(vector2.new(x,y))
	while self:platforms_collide() and x ~= lx do
		if x < lx then
			x += 1
		elseif x > lx then
			x -= 1
		end
		self:move(vector2.new(x,y)) 
 end
	
	
	--if btn(⬇️) then
		--y += vel end
	if btnp(🅾️) then
 	vel_y = jump_vel
	end
	y += vel_y
		
	self:move(vector2.new(x,y))
	while self:platforms_collide() and zy ~= 0 do
		if y < ly then
			y += 1
		elseif y > ly then
			y -= 1
		end
		self:move(vector2.new(x,y)) 
 end
	
	if btnp(❎) and not self.hooked then
		self:try_hook() end
end

function player:apply_gravity()
	vel_y += g

 if vel_y > max_fall then
  vel_y = max_fall end
end

-- temp
function player:shift(s)
	self.pos = self.pos+s
	if self.hooked then
		self.box.pos = self.box.pos+s end
end

function player:move(p)
	self.pos = p:clone()
	if self.hooked then
	 self.box.pos = p+vector2.new(0,10) end
end

function player:clamp()
	if self.pos.x > 120 then
		self:move(vector2.new(120,self.pos.y))
	elseif self.pos.x < 0 then
		self:move(vector2.new(0,self.pos.y))
	end
	if self.pos.y > 120 then
		self:move(vector2.new(self.pos.x,120)) 
	elseif self.pos.y < 13 then
		self:move(vector2.new(self.pos.x,13))
	end
end

function player:check_collisions()
	if not invincible and not ignore_spikes then
		if self.pos.y <= kz[1] or self.pos.y >= kz[2] then
			self:hit_spikes() 
			return 
		end
	end	
	if not invincible then
		for k,v in pairs(e) do
			if collide_circle(self.pos.x,self.pos.y,p_r,v.x,v.y,e_r) then
			 self:hit_enemy()
			 return
			end
		end
	end
end

function player:try_hook()
	for k,v in pairs(gm.boxes) do
		if collide_rect(self.pos.x,self.pos.y,8,10,v.pos.x,v.pos.y,8,8) and not v.destroy then
			self:hook(v)
			return
		end
	end
end

function player:hook(b)
	self.hooked = true
	self.box = b
	self.box:hook()
	local new_pos = vector2.new(self.pos.x,self.pos.y+10)
	self.box:move(new_pos)
	claw_sprt = claw_sprts.hooked
	sfx(0)
end

function player:unhook()
	self.hooked = false
	self.box = nil
	claw_sprt = claw_sprts.unhooked
end

function player:draw()
	--print(vel_y,30,118,10)
	spr(self.sprt,self.pos.x,self.pos.y)
	spr(claw_sprt,self.pos.x,self.pos.y+8)
	spr(self.h_sprt,self.pos.x,self.pos.y-8)
end

function player:hit_spikes()
	gm:player_hit_spikes()
end

function player:hit_enemy()
	gm:player_hit_enemy()
	if self.hooked then
		self.box:despawn() end
	-- moved in main
	--self:move(player_sp)
	vel_y = 0
end

function player:platforms_collide()
 local tl = self.pos:clone()
 local br = self.pos:clone()+vector2.new(7,7)

 local tx1 = flr(tl.x/8)
 local ty1 = flr(tl.y/8)

 local tx2 = flr(br.x/8)
 local ty2 = flr(br.y/8)

 local c1 = fget(mget(tx1,ty1),0)
 local c2 = fget(mget(tx1,ty2),0)
 local c3 = fget(mget(tx2,ty1),0)
 local c4 = fget(mget(tx2,ty2),0)

 return c1 or c2 or c3 or c4
end
-->8
-- enemy --

enemy = {}
enemy.__index = enemy

-- const
local sprt_helix = {4,5}
local helix_dur = 2 -- each helix spr lasts 2 frm
local claw_sprt = 6

function lerp(a,b,t)
 return a+(b-a)*t
end

-- ease in-out
function smoothstep(t)
 return t*t*(3-2*t)
end

function enemy.new(x,y,dir,offset)
 local top=y-offset
 local bottom=y

 local start_y
 local target_a
 local target_b

 if dir==1 then
  start_y=bottom
  target_a=bottom
  target_b=top
 else
  start_y=top
  target_a=top
  target_b=bottom
 end

 return setmetatable({
  x=x,

  y=start_y,

  from_y=target_a,
  to_y=target_b,

  t=0,
  dur=60,

  offset=offset,

  sprt=10,
  h_sprt=sprt_helix[1],
  h_sprt_i=1,
  h_timer=0
 },enemy)
end

function enemy:update()
 self.t += 1/self.dur

 if self.t>=1 then
  self.t=0

  self.from_y,self.to_y=
  self.to_y,self.from_y
 end

 local eased=smoothstep(self.t)

 self.y=lerp(
  self.from_y,
  self.to_y,
  eased
 )

 self:update_anim()
end

function enemy:update_anim()
	self.h_timer += 1
	if self.h_timer > helix_dur then
		self.h_sprt_i = (self.h_sprt_i%#sprt_helix)+1
		self.h_sprt = sprt_helix[self.h_sprt_i]
		self.h_timer = 0
	end
end

function enemy:draw()
	spr(self.sprt,self.x,self.y)
	spr(self.h_sprt,self.x,self.y-8)
	spr(claw_sprt,self.x,self.y+8)
end
-->8
-- house --

house = {}
house.__index = house

-- const 
h_coll = {{4,32},{4,64},{4,96},{60,48},{52,80},{108,32},{108,64},{108,96}}
box_sp = {{24,32},{24,64},{24,96},{48,48},{72,80},{96,32},{96,64},{96,96}}


-- var

-- base

function house.new(idx)
	return setmetatable({idx=idx,is_free=true},house)
end

function house:spawn(target)
	local b_pos = vector2.new(box_sp[self.idx][1],box_sp[self.idx][2])
	local b = box.new(b_pos,self.idx,target)
	self.is_free = false
	return b
end	

function house:free()
	self.is_free = true
end
-->8
-- box --

box = {}
box.__index = box

-- const
local inner_col = 1
local desp_time = 600 --800
local c_start_sprt = 41
local light_sprt = 49
local light_up = {{0,30},{300,20},{450,10},{520,5}}

-- var

-- base


function box.new(pos,start_col_i,target_col_i)
	local s = target_col_i+c_start_sprt-1
	return setmetatable({pos=pos,start_col_i=start_col_i,target_col_i=target_col_i,sprt=s,desp_timer=0,hooked=false,light_idx=1,destroy=false},box)
end

function box:update()
	self:update_anim()
	if self.desp_timer >= desp_time then
		sfx(3)
		self:despawn()
	end
	if not self.hooked then
		self.desp_timer += 1
	end
	self:collisions()
end

function box:update_anim()
	if self.hooked then 
		self.sprt = self.target_col_i+c_start_sprt-1
		return 
	end
	local interval = 30
	for i=#light_up,1,-1 do
		if self.desp_timer >= light_up[i][1] then
			interval = light_up[i][2]
			break
		end
	end
 if self.desp_timer%interval <= 2 then
  self.sprt = light_sprt
	else
		self.sprt = self.target_col_i+c_start_sprt-1
	end
end

function box:hook()
	self.hooked = true
end

function box:move(pos)
	self.pos = pos:clone()
end

-- check collisions with correct house
function box:collisions()
	local t = h_coll[self.target_col_i]
	if (collide_rect(self.pos.x,self.pos.y,8,8,t[1],t[2],16,8)) then
		gm:box_shipped()
		pm:box_shipped(self.pos+vector2.new(4,4))
		self:despawn()
	end
end

function box:despawn()
	self.destroy = true
end
-->8
-- globals --

-- do not change 
colors = {2,4,8,10,11,12,14,15}
high_score = 0

-- can change
-- default player_sp = 8,32
player_sp = vector2.new(60,80) -- player spawn point 
p_r = 3.8 -- player hb range
e_r = 3.8 -- enemy hb range
game_timer = 60
max_hp = 3 -- 3

-->8
-- game_manager --

game_mng = {}
game_mng.__index = game_mng

-- const
local ship_score = 100
local score_lose = 200
local spawn_freq = 20
local spawn_rate = 0.3 -- 30%
local max_boxes = 4 --4

-- var
curr_timer = game_timer
local frm = 0

-- base

function reset_var_gm()
	curr_timer = game_timer
 frm = 0
end

function game_mng.new()
	reset_var_gm()
	local hs = {}
	for i=1,#colors do
		add(hs,house.new(i))
	end
	return setmetatable({boxes={},houses=hs,score=0,high_score=high_score,record=false,sp_timer=0,hp=max_hp,bad_ending=false,p_hit_enemy=false,game_over=false},game_mng)
end

function game_mng:box_shipped(b)
	self.score += ship_score
	sfx(1)
end

function game_mng:update()
	self:try_spawn()
	-- del boxes
	for k,v in pairs(self.boxes) do
		if v.destroy then
			if not v.hooked then
				self:box_despawned() 
				pm:box_destroyed(v.pos+vector2.new(4,4))
			end
			self.houses[v.start_col_i]:free()
			del(self.boxes,v) 
		end
	end
	for k,v in pairs(self.boxes) do
		v:update()
	end
	frm += 1
	if frm >= 30 then
		self:decrease_curr_timer(1)
		frm = 0
	end
end

function game_mng:draw()
	print("score: "..gm.score,80,3,10)
	local b
	for k,v in pairs(gm.boxes) do
		if not v.destroy then
			spr(v.sprt,v.pos.x,v.pos.y) end	
			if v.hooked then
				b = v end	
	end
	if b then
		spr(b.sprt,b.pos.x,b.pos.y) end
	
	for i=0,gm.hp-1 do
		spr(60,2+i*9,1)
	end
end

function game_mng:try_spawn()
	self.sp_timer += 1
	if self.sp_timer >= spawn_freq then
		if rnd(1) < spawn_rate and #self.boxes < max_boxes then
			self:spawn() 
		end
			self.sp_timer = 0
	elseif #self.boxes == 0 then
			self:spawn()
			self.sp_timer = 0
	end
end

function game_mng:spawn()
 local house_idx 
	repeat
		house_idx = flr(rnd(#colors))+1
	until self.houses[house_idx].is_free
	local t
	repeat
		t = flr(rnd(#colors))+1
	until t ~= house_idx
	local b = self.houses[house_idx]:spawn(t)
	add(self.boxes,b)
	sfx(6)
end

p_hit_spikes = false
function game_mng:player_hit_spikes()
	--sfx(2)
	-- handle game state
	self:bad_game_over()
	-- debug
	p_hit_spikes = true
end


function game_mng:player_hit_enemy()
	-- debug
	self.p_hit_enemy = true
	self.score -= score_lose
	if self.score < 0 then
		self.score = 0 end
	if p.hooked then
		if self:remove_hp(1) <= 0 then
			self:bad_game_over() 
		else
			sfx(2)
		end
	else
		sfx(2)
	end
end

function game_mng:box_despawned()
	--sfx(3)
	--sfx(2)
	if self:remove_hp(1) <= 0 then
		self:bad_game_over() 
	else
		sfx(3)
	end
end

function game_mng:remove_hp(amount)
	self.hp -= amount
	return self.hp
end

function game_mng:decrease_curr_timer(amount)
	curr_timer -= amount
	if curr_timer <= 0 then
		self:timer_ended() end
end

function game_mng:timer_ended()
	self.p_hit_enemy = true
	self:update_score()
	self.bad_ending = false
	self.game_over = true
	pm:delete_all()
	
	stop_music()
	sfx(5)
end

function game_mng:update_score()
	if self.score > self.high_score then
		self.high_score = self.score 
		-- updates global hs so that it 
		-- is easier to reset variables
		high_score = self.score
		dset(0,high_score)
		self.record = true
	end
end

function game_mng:bad_game_over()
	self.p_hit_enemy = true
	self.bad_ending = true
	--state = game_states.game_over
	stop_music()
	self.game_over = true
	pm:delete_all()
	sfx(5)
end
-->8
-- particles --

particle = {
	x = 0,
	y = 0,
	col = 9,
	r = 0,
	velx = 0,
	vely = 0,
	weight = 1,
	l = 30,
	minvel = 0.5,
	
	new = function(self,tbl)
  local p = {}
  setmetatable(p,{__index=self})
  p.x = tbl.x or 0
  p.y = tbl.y or 0
  p.col = tbl.col or 7
  p.r = 1+rnd(4)
  p.velx = -rnd(2)+rnd(2)
  p.vely = -rnd(2)+rnd(2)
  p.weight = 0.5+rnd(1)
  p.l = 10+rnd(15)
  if abs(p.velx) < self.minvel then
   p.velx = sgn(p.velx)*self.minvel end
  if abs(p.vely) < self.minvel then
   p.vely = sgn(p.vely) * self.minvel end
  return p
	end,
}

particle_manager = {
	parts = {},
	ship_cols = {7,10,11},
	destroy_cols = {1,2},
	
	new = function(self,tbl)
		tbl = tbl or {}
		tbl.parts = {}
		setmetatable(tbl,{__index=self})
		return tbl
	end,
	
	update = function(self)
		for p in all(self.parts) do
			p.x += p.velx
			p.vely += g*p.weight
			p.y += p.vely
			p.r = max(0,p.r-0.3)
			p.l -= 1
			if p.l < 0 then
				del(self.parts,p) end
		end
	end,
	
	draw = function(self)
		for p in all(self.parts) do
			circfill(p.x,p.y,p.r,p.col)
		end
	end,
	
	box_destroyed = function(self,pos)
		for i=1,30 do
			local col = rnd(self.destroy_cols)
			add(self.parts,particle:new({x=pos.x,y=pos.y,col=col}))
		end
	end,
	
	box_shipped = function(self,pos)
		for i=1,30 do
			local col = rnd(self.ship_cols)
			add(self.parts,particle:new({x=pos.x,y=pos.y,col=col}))
		end
	end,
	
	delete_all = function(self)
		self.parts = {}
	end,
}
__gfx__
0000000000000000dddddddd00999900000000000000000000500500ddddddddd666666d777777770088880077777777dddddddddddddddddddddddd00000000
0000000000000000dddddddd09999990000000000000000005000050ddddddddd666666d777777770888888077755777dddddddddddddddddddddddd00000000
0070070000000000dddddddd99799799000000000000000000500500ddd66ddddd6666dd7777777788a88a8877555577dddddddddddddddddddddddd00000000
0007700000000000dddddddd99199199000000000000000000000000ddd66ddddd6666dd7777777788a88a8877755777ddddddddddddddddddddddddbbbbbbbb
0007700000000000dddddddd99999999000000000000000000000000dd6666ddddd66ddd777777778888888877777777ddddddddddddddddddddddddbbbbbbbb
0070070000000000dddddddd99999999666006660066660000000000dd6666ddddd66ddd555555558888888855555555ddd111111111111111111dddbbbbbbbb
0000000000000000dddddddd09999990000660000006600000000000d666666ddddddddd555555550888888055555555d1111111111111111111111dbbbbbbbb
0000000000000000dddddddd00999900006666000066660000000000d666666ddddddddd000000000088880000000000111111111111111111111111bbbbbbbb
111111118555555811111111f200000011111111b555555b1111111111111111e555555e1111111111111111f555555f11111111111111114555555411111111
1111111188855558111111118400000011111111bbb5555b1111111111111111eee5555e1111111111111111fff5555f11111111111111114445555411111111
111111118885555811111111ae00000011111111bbb5555b1111111111111111eee5555e1111111111111111fff5555f11111111111111114445555411111111
888888888555555888888888bc000000bbbbbbbbb555555bbbbbbbbbeeeeeeeee555555eeeeeeeeefffffffff555555fffffffff444444444555555444444444
88888888855555588555555800000000bbbbbbbbb555555bb555555beeeeeeeee555555ee555555efffffffff555555ff555555f444444444555555445555554
88888888855555588555555800000000bbbbbbbbb555555bb555555beeeeeeeee555555ee555555efffffffff555555ff555555f444444444555555445555554
88888888855555588555555800000000bbbbbbbbb555555bb555555beeeeeeeee555555ee555555efffffffff555555ff555555f444444444555555445555554
88888888888888888555555800000000bbbbbbbbbbbbbbbbb555555beeeeeeeeeeeeeeeee555555efffffffffffffffff555555f444444444444444445555554
11111111255555521111111111111111a555555a1111111111111111c555555c1111111107777770077777700777777007777770077777700777777007777770
11111111222555521111111111111111aaa5555a1111111111111111ccc5555c111111117222222774444447788888877aaaaaa77bbbbbb77cccccc77eeeeee7
11111111222555521111111111111111aaa5555a1111111111111111ccc5555c111111117222222774444447788888877aaaaaa77bbbbbb77cccccc77eeeeee7
222222222555555222222222aaaaaaaaa555555aaaaaaaaaccccccccc555555ccccccccc7222222774444447788888877aaaaaa77bbbbbb77cccccc77eeeeee7
222222222555555225555552aaaaaaaaa555555aa555555accccccccc555555cc555555c7222222774444447788888877aaaaaa77bbbbbb77cccccc77eeeeee7
222222222555555225555552aaaaaaaaa555555aa555555accccccccc555555cc555555c7222222774444447788888877aaaaaa77bbbbbb77cccccc77eeeeee7
222222222555555225555552aaaaaaaaa555555aa555555accccccccc555555cc555555c7222222774444447788888877aaaaaa77bbbbbb77cccccc77eeeeee7
222222222222222225555552aaaaaaaaaaaaaaaaa555555accccccccccccccccc555555c07777770077777700777777007777770077777700777777007777770
0777777007777770222222224444444488888888aaaaaaaabbbbbbbbcccccccceeeeeeeeffffffff1111111100055000000000000aaaaaa00000000000000000
7ffffff777777777222222224444444488888888aaaaaaaabbbbbbbbcccccccceeeeeeeeffffffff111111110050050000777700a777777a0000000000000000
7ffffff777777777222222224444444488888888aaaaaaaabbbbbbbbcccccccceeeeeeeeffffffff111111110005500007888870a777707adddddddd00000000
7ffffff777777777222222224444444488888888aaaaaaaabbbbbbbbcccccccceeeeeeeeffffffff111111110000000007888870a777077adddddddd00000000
7ffffff777777777222222224444444488888888aaaaaaaabbbbbbbbcccccccceeeeeeeeffffffff111111110000000007888870a700777adddddddd00000000
7ffffff777777777222222224444444488888888aaaaaaaabbbbbbbbcccccccceeeeeeeeffffffff111111110000000007888870a777777adddddddd00000000
7ffffff777777777222222224444444488888888aaaaaaaabbbbbbbbcccccccceeeeeeeeffffffff111111110000000000777700a777777adddddddd00000000
0777777007777770222222224444444488888888aaaaaaaabbbbbbbbcccccccceeeeeeeeffffffff1111111100000000000000000aaaaaa0dddddddd00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000000
00000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
00011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22aaaaaaaaaa222222aaaaaaaaaaaaa222aaaa22222222222aaaa222aaaa222222222222aaaa222aaaaaaaaaaaaa222aaaaaaaaaaa22222aaa222222222aaa22
22aaaaaaaaaa222222aaaaaaaaaaaaa222aaaa22222222222aaaa222aaaa222222222222aaaa222aaaaaaaaaaaaa222aaaaaaaaaaa22222aaa222222222aaa22
22aaa9999999222222aaaaaaaaaaaaa222aaaa22222222222aaaa222aaaa222222222222aaaa222aaaaaaaaaaaaa222aaaaaaaaaaa22222aaa222222222aaa22
22aaa2222222aaa222aaa9999999999222aaaa22222222222aaaa222aaaa222222222222aaaa222aaa9999999999222aaa99999999aaa22aaa222222222aaa22
22aaa2222222aaa222aaa2222222222222aaaa22222222222aaaa222aaaa222222222222aaaa222aaa2222222222222aaa22222222aaa22aaa222222222aaa22
22aaa2222222aaa222aaa2222222222222aaaa22222222222aaaa222aaaa222222222222aaaa222aaa2222222222222aaa22222222aaa22aaa222222222aaa22
22aaa2222222aaa222aaa2222222222222aaaa22222222222aaaa222aaaa222222222222aaaa222aaa2222222222222aaa22222222aaa22aaa222222222aaa22
22aaa2222222aaa222aaa2222222222222aaaa22222222222aaaa222aaaa222222222222aaaa222aaa2222222222222aaa22222222aaa22aaa222222222aaa22
22aaa2222222aaa222aaa2222222222222aaaa22222222222aaaa222aaaa222222222222aaaa222aaa2222222222222aaa22222222aaa22aaa222222222aaa22
22aaa2222222aaa222aaaaaaaaa2222222aaaa22222222222aaaa222aaaa222222222222aaaa222aaaaaaaaa2222222aaa22222222aaa22aaa222222222aaa22
22aaa2222222aaa222aaaaaaaaa2222222aaaa22222222222aaaa222aaaa222222222222aaaa222aaaaaaaaa2222222aaaaaaaaaaa99922999aaa222aaa99922
22aaa2222222aaa222aaaaaaaaa2222222aaaa22222222222aaaa222aaaa222222222222aaaa222aaaaaaaaa2222222aaaaaaaaaaa22222222aaa222aaa22222
22aaa2222222aaa222aaa9999992222222aaaa22222222222aaaa222aaaa222222222222aaaa222aaa9999992222222aaaaaaaaaaa22222222aaa222aaa22222
22aaa2222222aaa222aaa2222222222222aaaa22222222222aaaa222aaaa222222222222aaaa222aaa2222222222222aaa99999999aaa22222999aaa99922222
22aaa2222222aaa222aaa2222222222222aaaa22222222222aaaa2229999aaaa2222aaaa9999222aaa2222222222222aaa22222222aaa22222222aaa22222222
22aaa2222222aaa222aaa2222222222222aaaa22222222222aaaa2222222aaaa2222aaaa2222222aaa2222222222222aaa22222222aaa22222222aaa22222222
22aaa2222222aaa222aaa2222222222222aaaa22222222222aaaa2222222aaaa2222aaaa2222222aaa2222222222222aaa22222222aaa22222222aaa22222222
22aaa2222222aaa222aaa2222222222222aaaa22222222222aaaa2222222aaaa2222aaaa2222222aaa2222222222222aaa22222222aaa22222222aaa22222222
22aaa2222222999222aaaaaaaaaaaaa222aaaaaaaaaaaa222aaaa22222229999aaaa99992222222aaaaaaaaaaaaa222aaa22222222aaa22222222aaa22222222
22aaaaaaaaaa222222aaaaaaaaaaaaa222aaaaaaaaaaaa222aaaa22222222222aaaa22222222222aaaaaaaaaaaaa222aaa22222222aaa22222222aaa22222222
22aaaaaaaaaa222222aaaaaaaaaaaaa222aaaaaaaaaaaa222aaaa22222222222aaaa22222222222aaaaaaaaaaaaa222aaa22222222aaa22222222aaa22222222
22999999999922222299999999999992229999999999992229999222222222229999222222222229999999999999222999222222229992222222299922222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000aaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000
000077770000077770000077770000000000000000000000a777777a000000000000000000000000000000000000000000000000000000000000000000000000
000788887000788887000788887000000000000000000000a777707a0000aaa0aa000000000000000aa00aa00aa0aaa0aaa000000000aaa00000000000000000
000788887000788887000788887000000000000000000000a777077a0000a0000a00000000000000a000a000a0a0a0a0a0000a000000a0a00000000000000000
000788887000788887000788887000000000000000000000a700777a0000aaa00a00000000000000aaa0a000a0a0aa00aa0000000000a0a00000000000000000
000788887000788887000788887000000000000000000000a777777a000000a00a0000000000000000a0a000a0a0a0a0a0000a000000a0a00000000000000000
000077770000077770000077770000000000000000000000a777777a0000aaa0aaa0000000000000aa000aa0aa00a0a0aaa000000000aaa00000000000000000
0000000000000000000000000000000000000000000000000aaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddd6666dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddd66ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddd6666dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddd8888dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddd111111111111111111dddddddddddddddd888888dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd111111111111111111ddd
d1111111111111111111111ddddddddddddd88a88a88dddddddddd6666ddddddddddddddddddddddddddddddddddddddddddddddd1111111111111111111111d
111111111111111111111111dddddddddddd88a88a88ddddddddddd66ddddddddddddddddddddddddddddddddddddddddddddddd111111111111111111111111
111111111111111111111111dddddddddddd88888888dddddddddd6666dddddddddddddddddddddddddddddddddddddddddddddd111111111111111111111111
111111111111111111111111dddddddddddd88888888dddddddddd9999dddddddddddddddddddddddddddddddddddddddddddddd111111111111111111111111
111111111111111111111111ddddddddddddd888888dddddddddd999999ddddddddddddddddddddddddddddddddddddddddddddd111111111111111111111111
222222222222222222222222dddddddddddddd8888dddddddddd99799799ddddddddddddddddddddddddddddddddddddddddddddcccccccccccccccccccccccc
222222222555555222222222dddddddddddddd5dd5dddddddddd99199199ddddddddddddddddddddddddddddddddddddddddddddccccccccc555555ccccccccc
222222222555555222222222ddddddddddddd5dddd5ddddddddd99999999ddddddddddddddddddddddddddddddddddddddddddddccccccccc555555ccccccccc
222222222555555222222222dddddddddddddd5dd5dddddddddd99999999ddddddddddddddddddddddddddddddddddddddddddddccccccccc555555ccccccccc
222222222555555222222222ddddddddddddddddddddddddddddd999999dddddddddddddddddddddddddddddddddddddddddddddccccccccc555555ccccccccc
222222222555555222222222dddddddddddddddddddddddddddddd9999ddddddddddddddddddddddddddddddddddddddddddddddccccccccc555555ccccccccc
222222222225555222222222ddddddddddddddddddddddddddddddd55dddddddddddddddddddddddddddddddddddddddddddddddccccccccccc5555ccccccccc
222222222225555222222222dddddddddddddddddddddddddddddd5dd5ddddddddddddddddddddddddddddddddddddddddddddddccccccccccc5555ccccccccc
222222222555555222222222ddddddddddddddddddddddddddddd775577dddddddddddddddddddddddddddddddddddddddddddddccccccccc555555ccccccccc
222222222555555222222222dddddddddddddddddddddddddddd7eeeeee7ddddddddddddddddddddddddddddddddddddddddddddccccccccc555555ccccccccc
222222222555555222222222dddddddddddddddddddddddddddd7eeeeee711111111111111111dddddddddddddddddddddddddddccccccccc555555ccccccccc
222222222555555222222222dddddddddddddddddddddddddddd7eeeeee71111111111111111111dddddddddddddddddddddddddccccccccc555555ccccccccc
222222222222222222222222dddddddddddddddddddddddddddd7eeeeee711111111111111111111ddddddddddddddddddddddddcccccccccccccccccccccccc
77777777777777777777777777777777dddddddddddddddddddd7eeeeee711111111111111111111dddddddddddddddd77777777777777777777777777777777
77777777777777777777777777755777dddddddddddddddddddd7eeeeee711111111111111111111dddddddddddddddd77755777777777777777777777777777
77777777777777777777777777555577ddddddddddddddddddddd777777111111111111111111111dddddddddddddddd77555577777777777777777777777777
77777777777777777777777777755777ddddddddddddddddddddddddaaaaaaaaaaaaaaaaaaaaaaaadddddddddddddddd77755777777777777777777777777777
77777777777777777777777777777777ddddddddddddddddddddddddaaaaaaaaa555555aaaaaaaaadddddddddddddddd77777777777777777777777777777777
55555555555555555555555555555555ddddddddddddddddddddddddaaaaaaaaa555555aaaaaaaaadddddddddddddddd55555555555555555555555555555555
55555555555555555555555555555555ddddddddddddddddddddddddaaaaaaaaa555555aaaaaaaaadddddddddddddddd55555555555555555555555555555555
00000000000000000000000000000000ddddddddddddddddddddddddaaaaaaaaa555555aaaaaaaaadddddddddddddddd00000000000000000000000000000000
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddaaaaaaaaa555555aaaaaaaaadddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddaaaaaaaaaaa5555aaaaaaaaadddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddaaaaaaaaaaa5555aaaaaaaaadddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddaaaaaaaaa555555aaaaaaaaadddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddaaaaaaaaa555555aaaaaaaaadddddddddddddddddddddddddddddddddddddddddddddddd
ddd111111111111111111dddddddddddddddddddddddddddddddddddaaaaaaaaa555555aaaaaaaaaddddddddddddddddddddddddddd111111111111111111ddd
d1111111111111111111111dddddddddddddddddddddddddddddddddaaaaaaaaa555555aaaaaaaaaddddddddddddddddddddddddd1111111111111111111111d
111111111111111111111111ddddddddddddddddddddddddddddddddaaaaaaaaaaaaaaaaaaaaaaaadddddddddddddddddddddddd111111111111111111111111
111111111111111111111111dddddddddddddddddddddddd77777777777777777777777777777777dddddddddddddddddddddddd111111111111111111111111
111111111111111111111111dddddddddddddddddddddddd77755777777777777777777777777777dddddddddddddddddddddddd111111111111111111111111
111111111111111111111111dddddddddddddddddddddddd77555577777777777777777777777777dddddddddddddddddddddddd111111111111111111111111
444444444444444444444444dddddddddddddddddddddddd77755777777777777777777777777777ddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeee
444444444555555444444444dddddddddddddddddddddddd77777777777777777777777777777777ddddddddddddddddddddddddeeeeeeeee555555eeeeeeeee
444444444555555444444444dddddddddddddddddddddddd55555555555555555555555555555555ddddddddddddddddddddddddeeeeeeeee555555eeeeeeeee
444444444555555444444444dddddddddddddddddddddddd55555555555555555555555555555555ddddddddddddddddddddddddeeeeeeeee555555eeeeeeeee
444444444555555444444444dddddddddddddddddddddddd00000000000000000000000000000000ddddddddddddddddddddddddeeeeeeeee555555eeeeeeeee
444444444555555444444444ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd777777deeeeeeeee555555eeeeeeeee
444444444445555444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd78888887eeeeeeeeeee5555eeeeeeeee
444444444445555444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd78888887eeeeeeeeeee5555eeeeeeeee
444444444555555444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd78888887eeeeeeeee555555eeeeeeeee
444444444555555444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd78888887eeeeeeeee555555eeeeeeeee
444444444555555444444444ddddddddddddddddddddddddddd111111111111111111ddddddddddddddddddddddddddd78888887eeeeeeeee555555eeeeeeeee
444444444555555444444444ddddddddddddddddddddddddd1111111111111111111111ddddddddddddddddddddddddd78888887eeeeeeeee555555eeeeeeeee
444444444444444444444444dddddddddddddddddddddddd111111111111111111111111ddddddddddddddddddddddddd777777deeeeeeeeeeeeeeeeeeeeeeee
77777777777777777777777777777777dddddddddddddddd111111111111111111111111dddddddddddddddddddddddd77777777777777777777777777777777
77777777777777777777777777755777dddddddddddddddd111111111111111111111111dddddddddddddddddddddddd77755777777777777777777777777777
77777777777777777777777777555577dddddddddddddddd111111111111111111111111dddddddddddddddddddddddd77555577777777777777777777777777
77777777777777777777777777755777ddddddddddddddddbbbbbbbbbbbbbbbbbbbbbbbbdddddddddddddddddddddddd77755777777777777777777777777777
77777777777777777777777777777777ddddddddddddddddbbbbbbbbb555555bbbbbbbbbdddddddddddddddddddddddd77777777777777777777777777777777
55555555555555555555555555555555ddddddddddddddddbbbbbbbbb555555bbbbbbbbbdddddddddddddddddddddddd55555555555555555555555555555555
55555555555555555555555555555555ddddddddddddddddbbbbbbbbb555555bbbbbbbbbdddddddddddddddddddddddd55555555555555555555555555555555
00000000000000000000000000000000ddddddddddddddddbbbbbbbbb555555bbbbbbbbbdddddddddddddddddddddddd00000000000000000000000000000000
ddddddddddddddddddddddddddddddddddddddddddddddddbbbbbbbbb555555bbbbbbbbbd777777ddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddbbbbbbbbbbb5555bbbbbbbbb7ffffff7dddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddbbbbbbbbbbb5555bbbbbbbbb7ffffff7dddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddbbbbbbbbb555555bbbbbbbbb7ffffff7dddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddbbbbbbbbb555555bbbbbbbbb7ffffff7dddddddddddddddddddddddddddddddddddddddddddddddd
ddd111111111111111111dddddddddddddddddddddddddddbbbbbbbbb555555bbbbbbbbb7ffffff7ddddddddddddddddddddddddddd111111111111111111ddd
d1111111111111111111111dddddddddddddddddddddddddbbbbbbbbb555555bbbbbbbbb7ffffff7ddddddddddddddddddddddddd1111111111111111111111d
111111111111111111111111ddddddddddddddddddddddddbbbbbbbbbbbbbbbbbbbbbbbbd777777ddddddddddddddddddddddddd111111111111111111111111
111111111111111111111111dddddddddddddddddddddddd77777777777777777777777777777777dddddddddddddddddddddddd111111111111111111111111
111111111111111111111111dddddddddddddddddddddddd77777777777777777777777777755777dddddddddddddddddddddddd111111111111111111111111
111111111111111111111111dddddddddddddddddddddddd77777777777777777777777777555577dddddddddddddddddddddddd111111111111111111111111
888888888888888888888888dddddddddddddddddddddddd77777777777777777777777777755777ddddddddddddddddddddddddffffffffffffffffffffffff
888888888555555888888888dddddddddddddddddddddddd77777777777777777777777777777777ddddddddddddddddddddddddfffffffff555555fffffffff
888888888555555888888888dddddddddddddddddddddddd55555555555555555555555555555555ddddddddddddddddddddddddfffffffff555555fffffffff
888888888555555888888888dddddddddddddddddddddddd55555555555555555555555555555555dddddd6666ddddddddddddddfffffffff555555fffffffff
888888888555555888888888dddddddddddddddddddddddd00000000000000000000000000000000ddddddd66dddddddddddddddfffffffff555555fffffffff
888888888555555888888888dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd6666ddddddd777777dfffffffff555555fffffffff
888888888885555888888888dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd8888dddddd7cccccc7fffffffffff5555fffffffff
888888888885555888888888ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd888888ddddd7cccccc7fffffffffff5555fffffffff
888888888555555888888888dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd88a88a88dddd7cccccc7fffffffff555555fffffffff
888888888555555888888888dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd88a88a88dddd7cccccc7fffffffff555555fffffffff
888888888555555888888888dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd88888888dddd7cccccc7fffffffff555555fffffffff
888888888555555888888888dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd88888888dddd7cccccc7fffffffff555555fffffffff
888888888888888888888888ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd888888dddddd777777dffffffffffffffffffffffff
77777777777777777777777777777777dddddddddddddddddddddddddddddddddddddddddddddddddddddd8888dddddd77777777777777777777777777777777
77777777777777777777777777755777dddddddddddddddddddddddddddddddddddddddddddddddddddddd5dd5dddddd77755777777777777777777777777777
77777777777777777777777777555577ddddddddddddddddddddddddddddddddddddddddddddddddddddd5dddd5ddddd77555577777777777777777777777777
77777777777777777777777777755777dddddddddddddddddddddddddddddddddddddddddddddddddddddd5dd5dddddd77755777777777777777777777777777
77777777777777777777777777777777dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd77777777777777777777777777777777
55555555555555555555555555555555dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd55555555555555555555555555555555
55555555555555555555555555555555dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd55555555555555555555555555555555
00000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66ddd
ddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddd66ddd
dd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dd
dd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dd
d666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666d
d666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666dd666666d

__gff__
0000000000000000000100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010101010101010101010101010101010101101001010101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e01010101010101010101010101010101101001010101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0e020202020202020202020c0d0e01010101010101010101010101010101101001010101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2022200202020202020202020226282640414d4d4d4d4d4d4d4d4d4d4d4d4e4f101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
322132020202020c0d0e020202372737505152535455565758595a5b5c5d5e5f101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090b02020223252302020b090909606162636465566768696a6b6c6d6e6f101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0e020202023524350202020c0d0e707172737475767778797a7b7c7d7e7f101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1f1d0202020b09090902020217191701010101010101010101010101010101101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
331e330202020c0d0e0202020238183801010101010101010101010101010101101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090b02021416140202020b09090901010101010101010101010101010101101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0e020202361536020202020c0d0e01010101010101010101010101010101101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1012100202020909090b0202021a1c1a01010101010101010101010101010101101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
34113402020202020202020202391b3901010101010101010101010101010101101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090b02020202020202020b09090901010101010101010101010101010101101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020201010101010101010101010101010101101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070701010101010101010101010101010101101001010101010101010101010101010101100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010110101010101010101010101010101010101010101010101010101010101010101010100202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000014420134201242012420124201342014420154201642017420194201b4201c4201d4202142024420284202b4202d4202f420200001d0001d0001c0001c0001c0000000000000000000000000000
0002000007750097500a7500c7501075014750177500955009550095500955009550107501975022750227502a7503075034750347003470034700347001050013500175001e500245002a500325000000000000
0003000000000000001833013330113300f3300d3300c3300a3300833006330053300433002360003600036000360043000000000000000000000000000000000000000000000000000000000000000000000000
0003000000000000002b0402b0402b0401a54018540155401554015540191401514014140131400c5400a5400954009540095400b140071400514002540005400054000540005400f1000e1000b1000810000000
000d0000307502f750307503275036000360501e7001e7501a750197501a0502e7002e7503075032750307502a0002a0502a000013001a7501c7501a7501e750257002a7502d7003075030700287003605036700
00030000000002005020050200501e0501a050170501305018050180501805012050100500e0500c0500b0500a050090500e0500e0500e0500b05009050070500605004050020500105000050000500050002500
0003000000000000000e0400e0400e04003540045400854008540085400d1400e140111401514019540195401954019540195402014024140271402d5402d540325403a5003a5000f1000e1000b1000810000000
001000000c0433c2153c6150c0430c043000003c6150c0430c0433c2153c6150c0430c043000003c6150c0430c0433c2153c6150c0430c043000000c0433c2153c6150c0430c043000003c6150c0433c2153c615
001100000014000135000000012004140041350000004120051400513500000051100414004135000000412002140021350000002110001400013500000001350714007135041000911507145051450414502145
001000002804527045280452b0452404523045240452b0452d0452c0452d045300452b0452a0452b045280452904528045290452604528045270452804524045260452404523045210451f04521045230451f045
00020000000001605019050220502405024050280502b050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 07080944

