pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- main --

-- const

-- var

function _init()

end

function _update()

end

function _draw()

end

function update_game()

end

function update_menu()

end

function update_game_over()

end

function draw_game()

end

function draw_menu()

end

function draw_game_over()

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

-->8
-- player --

player = {}
player.__index = player

-- const

-- var

-- base
-->8
-- obstacle --

obstacle = {}
obstacle.__index = obstacle

-- const

-- var

-- base
-->8
-- house --

house = {}
house.__index = house

-- const

-- var

-- base
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
