pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--sushi dodger
--marcus w
function _init()
	level=1
	nexlev=false--this is to play level transition
	g=0.025 --gravity
	life=0 --so no extra lives
	numen= {10,16,20,22,24,55,47,42,35,30} --this is how many sushi spawn and likelhood of special sushi
	blink_start() --blink table
	p={}
	p.alive=false
	start_seq=true
end

function start_game()
	make_player()
	enemies={} --makes enemy table
	slow=false --ice enemy hasn't been hit
	winseq={0,0} --win sequence, this is an array, the first didgt = winseq[1] as calls first didgt, and does the maths on it
	music(1,30,0)--starts music
	for i=1,10 do --make 10 enemies
		make_enemy(rnd(128),rnd(128))
	end --in random places
	clouds={} --make cloud table
	for i=1,rndb(4,10) do --make clouds, random # of clouds
		make_cloud(rnd(128),rndb(0,100))
	end --in random position
end

function blink_start()
	blink=5 --blink/flashing code
	rainbow=8--colour when starts rainbow
	blink_i=1--position in seqence
	rainbow_i=1
	blinkframe=0--counts when called
	blinkspeed=17--how many times it should change colour, so ~10 times per second it blinks
	ice=12--same as above
	ice_i=1
	iceframe=0
	icespeed=25
	golden=9
	gold_i=1
	bow=8
	bow_i=1
end

function next_level(r) --when next level, r checks if level restart
	if btn(5) or r == true then
		p.alive=true--tells game p is alive
		if not r then
			level+=1--progress 1 level
		end
		nexlev=false--stops repeating this code
		make_player() --make player
		enemies={} --reset enemy table
		music(-1,0,0)--stops prexisting music
		music(1,30,0)--starts music
		for i=1,numen[level] do --spawn a differnet number of sushi each level
			make_enemy(rnd(128),rnd(128))
		end
		clouds={} --cloud code
		for i=1,rndb(4,10) do
			make_cloud(rnd(128),rndb(0,100))
		end
	else
		nexlev=true
		p.alive=false
	end
end

function make_player()
	p={} --p value
	p.x=60 --where p(layer) is 
	p.y=8
	p.dx=0 --in which directions
	p.dy=0
	p.sprite=1 --what spritep is 
	p.alive=true --p is alive
	p.thrust=0.075 --p's thrust/movement
	p.space=15 --so enemies don't spawn on it
	p.score=0 --this is the number of enemies
	win=false --p hasn't won
	slowtimer=0 --timer for slow
end

function make_enemy(x,y)
	local e={} --local function of e(nemies)
	e.x=x --where e is
	e.y=y
	e.f = false
	if level < 5 then --chance of being a special sushi
		e.s=flr(rnd(numen[(level+5)]))--the calculation of being special
	
	end
	if e.y > (p.y-p.space) and e.y < (p.y+p.space) 
	and e.x > (p.x-p.space) and e.x < (p.x+p.space) then
		make_enemy(rnd(128),rnd(128)) --this code makes sure
 --that enemy doen't spawn on player
	else --if enemies won't spawn on p
		if e.s == 1 then
			e.sprite=35--if chance of special tells it to be a life
		elseif e.s == 2 then
			e.sprite=49--random # says be a ice sushi
		else
			e.sprite=(rndb(4,8))+(16*(level-1))--just be normal
		end
			add(enemies,e)--make sushi, add to table
			p.score+=1--tells p how many sushi there are
	end
end

function make_cloud(x,y)
	local c={}--local c(loud)
	c.x=x--where c is
	c.y=y
	c.t=0 --c's timer moves 10 times per second
	add(clouds,c)--make c
end

function _update()
	if start_seq then
		if btn(5) then
			start_seq=false
			start_game()--starts game when 'x' pressed
			sfx(8)
		end
	end
	for i=1, 6 do--loop 6 times
		doblink()--code for flashing sushi
	end
	if (p.alive == true) then--if p alive
		foreach(enemies,update_enemy)--move e
		move_player()--move p
		foreach(clouds,update_cloud)--move c
		timer()--time
	end
	if not start_seq then
		if nexlev then--if play transition, keep reapeating
			next_level(false)
		else
			check_win()--see if game has been won
		end
	end
end

function move_player()
	if (p.alive) then--if p alive
		p.dy+=g--p is effected by gravity
		thrust()--sees if p is being moved
		p.x+=p.dx--so move p in that way
		p.y+=p.dy
		stay_on_screen()--so p won't go off screen
	end
end

function update_enemy(e)
	if slowtimer >= 148 then
		e.f=true--if a ice sushi has been hit, freeze
	elseif slowtimer == 0 then
		e.f = false--if time for being frozen run out, thaw
	end
	
	if not e.f or e.sprite == 35 or e.sprite == 49 then
		if e.x <= p.x then
			e.x+=rnd(2)-rndb(0.6,1.2)
		end--if player is to left, bias left
		if e.x > p.x then
			e.x+=rnd(2)-rndb(0.8,1.4)
		end--if player is to right, bias right
		if e.y > p.y or p.x == 0 then
			e.y+=rnd(2)-rndb(0.8,1.4)
		end--if player is above, bias up
		if e.y < p.y or p.x == 128 then
			e.y+=rnd(2)-rndb(0.6,1.2)
		end--if player is bellow, bias down
	end
		

	if (e.x<-1 or e.x>120 
		or e.y<-1 or e.y>120) then
		if e.sprite == 35 or e.sprite == 49 then
			if e.x <-1 then--stops special e
				e.x=119--from killing itself
			end
			if e.x >120 then--or running 
				e.x=0--off edge of map
			end
			if e.y<-1 then--so spawn on otherside
				e.y=119
			end
			if e.y>120 then
				e.y=0
			end
		else
			del(enemies,e)--if other enemies
			p.score-=1--run off edge of map
			make_enemy(rnd(128),rnd(128))--del and remake
		end
	end
	if (e.y)<=p.y and (e.y+6)>=p.y and --p has hit e
	((e.x-6)<p.x and (e.x+6>p.x)) and 
	(p.dy<=0) then--player is also going up 
		if e.sprite == 35 then--if life give life when hit
			del(enemies,e)--kill e
			sfx(6)--sound 6
			life+=1--extra life
			p.score-=1--tell p that e is dead
		elseif e.sprite == 49 then--if ice when hit make
			del(enemies,e)--kill e
			sfx(8)--sound 8
			slowtimer+=150--add ~5 secounds to timer, of frozen
			p.score-=1--tell p that e is dead
		else--normal enemy
			del(enemies,e)--kill e
			p.score-=1--tell p that e is dead
			sfx(5)--play sound 5
		end
	elseif ((e.y-5)<p.y and (e.y+5)>p.y) and 
	   ((e.x-5)<p.x and (e.x+5)>p.x)  then
		if e.sprite == 35 then--if special e act like p has killed it
			del(enemies,e)--kill e
			sfx(6)
			life+=1
			p.score-=1
		elseif e.sprite == 49 then
			del(enemies,e)
			sfx(9)
			slowtimer+=150
			p.score-=1
		elseif life == 0 and not e.f then--if no more lives and not slow
			game_over()--game ends
		elseif e.f then--if not special e and is slow
			e.f = false--the enemy can now move normaly
			del(enemies,e)--despawn
			p.score-=1
			make_enemy(e.x,e.y)--respawn in same place, if not spawn on p
		else--if there are lives
			del(enemies,e)--kill e
			sfx(7)--play sound 7
			life-=1--lost a life
			p.score-=1
		end
	end

end

function doblink()--this code is from Breakout
	local c_seq = {8,6,12,6}--this sequence of colours it will play through when it blinks
	local r_seq = {8,9,10,11,12,14}
	local i_seq = {12,1,13}
	local g_seq = {9,9,9,9,10}
	local b_seq = {8,9,10,11,11,10,9}
	blinkframe+=1--every time repeated counted number of times repeated
	iceframe+=1--for ice's frame as well, as they have a slower blink
	if blinkframe>blinkspeed then --repeated until blinkspped
		blinkframe=0--then reset
		blink_i+=1--go up once through the sequence
		rainbow_i+=1
		if blink_i>#c_seq then
			blink_i=1--when reach end of sequence start again
		end
		if rainbow_i>#r_seq then
			rainbow_i=1
		end
		blink=c_seq[blink_i]--blink = blink_i's number's positon in the seqence
		rainbow=r_seq[rainbow_i]
		
	end
	if iceframe>icespeed then--ice has a different speed from the other two
		iceframe=0--start this loop again
		ice_i+=1--move up the seqence
		gold_i+=1
		bow_i+=1
		if ice_i>#i_seq then
			ice_i=1--reset the movement up the seqence
		end 
		if gold_i>#g_seq then
			gold_i=1
		end
		if bow_i>#b_seq then
			bow_i=1
		end
		ice=i_seq[ice_i]
		golden=g_seq[gold_i]
		bow=b_seq[bow_i]
	end
end

function timer()--this is for the slow timer
	if slowtimer > 0 then--if timer is over 0
		slowtimer-=1--count down
		slow=true--slow is true
	else
		slow=false
	end
end

function update_cloud(c)--this moves the cloud
	if c.t == 3 then
		c.t = 0
		c.x-=0.3--move c, 10 times per second
	elseif c.t < 3 then -- if c's timer is below 3
		c.t+=1 --add 1
	end
	
	if c.x <-10 then
		c.x=127--when reach end of screen reset
	end
end

function thrust()--this sees if p is being moved by arrow keys, from lander
	if(btn(0)) then
		p.dx-=p.thrust--go up
		sfx(1)
	end

	if(btn(1)) then
		p.dx+=p.thrust--go right
		sfx(1)
	end
	
	if (btn(3)) then
		p.dy+=p.thrust--go down
	end

	if(btn(2)) then
		p.dy-=p.thrust--go left
		sfx(0)
	end
end

function stay_on_screen()
	if (p.x<0) then --left side
		p.x=0--block any more movement
		p.dx=0--to left
	end
	if (p.x>119) then --right side
		p.x=119--block any more movement
		p.dx=0--to right
	end
	if (p.y<0) then --top side
		p.y=0
		p.dy=0
	end
	if (p.y>119) then --bottom
		p.y=119--block any more movement
		p.dy=0--to right
	end
end

function check_win()--check if won
	if p.score <= 0 then
		win=true--if there are no more enemies
		game_over()--call sound effects
	end
	if (p.alive == false) and (win == false) then--if p died and there are still e's
		endgame()--game lost
	end
	if (p.alive == false) and (win == true)--if p isn't alive, but all e's were killed
				and level == 5 then--level is also 5
			game_won()--game won
	end 
	if  (p.alive == false) and (win == true)--if p not alive and all e's killed
		and level < 5 then--level is also bellow 5
			next_level(false)--this calls next level
	end
	if level > 5 and (win == false) then --stops levels going over 5
		level = 5
		next_level(false)
	end
		
end

function game_over()--if all e's killed 
	p.alive=false--then p isn't alive
	music(-1,0,0)--stops music
	if win == true then--if p won
		sfx(4)
	else--if p didn't win
		sfx(3)
	end
end

function endgame()--if game was lost
	cls()--clear screen
	print("you died",48,50,8)--this is the shadow
	print("you died",48,48,1)--of this
	spr(33,50,40)--place the grey hat on top of text
	print("press ❎ to restart",30,62,blink) --ask if controller wants to restrat, in red, blue and grey colours(blink)
	music(-1,0,0)--stops music
	if btn(5) then--if ❎ pressed restart
		next_level(true)--start from the same level they were on
	end
end

function _draw() --this is like update, but for drawing
	if start_seq then
		draw_start()
	end
	if (p.alive) then--if p is alive 
		cls()--clear screen, all this layered unto of each other the high in the code, the more on top
		background()--draw background
		foreach(enemies,draw_enemy)--draw enemoes
		draw_player()--draw player
	end
	if nexlev then --draw level transition
		draw_level()
	end
end

function background()
	cls(12)--make screen all blue
	foreach(clouds,draw_cloud)--the clouds are at the back
	map(0,12,0,48,24,10)--draw the mountain from the map
	map(0,1,4,64,15,8)--same with shrine
	print((numen[level]-p.score),1,1,6)--so the score goes up
	print("level:"..level,100,1,7)--print what level p is on
	if life > 0 then--if life activated show lives
		spr(32,10,0)--heart shows
		print("x"..life,19,1,7)--with x(#of lives)
	end
	if slow then--if the game is slow
		if life > 0 then
			spr(48,30,0)--put the slow token after life sign
			print((slowtimer/60),39,1,7)--puts timer in seconds
		else
			spr(48,10,0)--same as above, but in different position
			print((slowtimer/60),19,1,7)
		end
	end
end

function draw_start()
	cls()
	map(0,1,4,64,15,8)--same with shrine
	print("press ❎ to start",28,50,rainbow)--asks if p wants to start
	print("in this game:",32,58,7)
	print("you kill sushi by using your",0,64,6)
	print("horns, by running up into them",0,70,6)
	print("(c) marcus wishart, 2020",12,120,5)
end

function draw_level() --draw level transition
	rectfill(15,40,115,80,bow)
	print("press ❎ to progress",28,58,7)--asks if p wants to progress to next level
end

function draw_player()--draws p
	if(btn(2)) then--if ❎ held, show flame under p
		spr(3,p.x,p.y+8)
		p.sprite=2--the sprite of p changes to the one with clenched feet
	else
		p.sprite=1--the sprite of p changes to one that is normal
	end
	spr(p.sprite,p.x,p.y)
end

function draw_cloud(c)--this draw both parts of the cloud
	spr(27,c.x,c.y)
	spr(28,c.x+7,c.y)
end

function rndb(low,high)-- this the random between function
	return flr(rnd(high-low+1)+low)
end

function draw_enemy(e)--this draws e
	if e.f == true and e.sprite != 35 and e.sprite != 49  then--if ice, and not special
		if level < 4 then--the rectfill is the one with small sushi
			rectfill(e.x,e.y,e.x+7,e.y+7,ice)--this puts the flashing part around the sushi
		else--for levels where e is larger
			rectfill(e.x-1,e.y-1,e.x+8,e.y+8,ice)
		end
	end
	if e.sprite == 35 then --if golden sushi
		rectfill(e.x+1,e.y+1,e.x+6,e.y+6,golden)--this puts the flashing part around the sushi
	elseif e.sprite == 49 then
		rectfill(e.x+1,e.y+1,e.x+6,e.y+6,ice)--this puts the flashing part around the sushi
	end
	spr(e.sprite,e.x,e.y)--put the sprite in front of flashing part
end

function game_won()--if game has been won
	cls()--clear screen
	music(-1,0,0)--stop music
	map(0,12,0,48,24,10)--draw mountain at back
	print("game won!",48,46,9)--saw game has been won
	if winseq[1]/15 == flr(winseq[1]/15) and winseq[2] < 8 then--so hat goes down 2 times per second, unti on head
		winseq[2]+=1--move hat down
	end--hat comes down
	spr(1,60,36)--print the p sprite
	spr(34,60,24+winseq[2])--this is the hat
	if winseq[2] < 9 and winseq[2] >= 0 then--this is the around outline around the hat
		rectfill(61,24+winseq[2]+6,66,24+winseq[2]+6,rainbow)--it just draws a rectangle on the hat
		rectfill(61,24+winseq[2]+7,61,24+winseq[2]+7,rainbow)
		rectfill(66,24+winseq[2]+7,66,24+winseq[2]+7,rainbow)
	end--draws a rainbow hat
	print("press ❎ to restart",28,72,rainbow)--asks if p wants to resart
	if btn(5) then
		_init()
	end
	winseq[1]+=1--this is a timer
end
__gfx__
000000000800008008000080008aa800000000000000000000000000000000000000000000800800000000000000000000080000000000000000000000000000
08288880080000800800008000899800055555500555555005555550055555500555555000800800000000000000000000188000000000000000000000000000
02800080008668000086680000088000057777500577775005777750057777500577775000086680000000000000000000166666666666666666660000000000
08080080066aa660066aa66000000000057eb750057ff7500579975005716750057af7500866aa66000000000000000055166566556666655566666500000000
0800808006caac6006caac6000000000057ee750057ff750057f975005716750057fa750896caac6000000000000000055155665666565666665656600000000
08000820066aa660066aa6600000000005777750057777500577775005777750057777508966aa66000000000000000000166666666666666666660000000000
08888280058888500588885000000000055555500555555005555550055555500555555008555555000000000000000000188000000000000000000000000000
00000000660000660660066000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000
00000000008888000088880000888800000000000000000000000000000000000000000000000000000000000000000000000000666666660565888000000000
00000000008888000088880000888800094994900efeeef002e22220028222200ee6e6e000000000000000550000000000000000666666665565888800000000
88888888888888880088880000888800094994900feeefe002e22d20022228200666666000000000000055550000077000000000666666665565888800000000
88888888888888880088880066666666094994900eeefee002222d20028222200e6ee6e000000000000555550007777770000000666666660565888800000000
88888888888888880088880066666666094774900ee77ef0026772200227728006e77e6000000000005555550077777770000000666666660066888800000000
88888888888888880088880066666666077777700777777007777770077777700777777000000088005555550f777777f7770000666666660005888800000000
0000000000888800008888006666666607777770077777700777777007777770077777700000088805555555fffff77777777000666666660000000000000000
0000000000888800008888006666666600000000000000000000000000000000000000000000888855555555ffffffff77777700666666660000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088856500000000000000000
08800880000000000000000000000000055555500afaaaa00eeeeee0077777700555555000000000550000000000000000000000888856550000000000000000
8ee887e8000000000000000000777700059898500afaaaf00e76677007eeee700577775000000000555500000000000000000000888856558888888800000000
8eeeee780800008008000080007a9700058989500aaafaa00e77777007777e700577775000000000555550000000000000000000888856508888888800000000
8eeeee7808000080080000800079a700059898500aaaaaa00e76777007e77e700598985000000000555555000007777777777000888866008888888800000000
088ee880008558000089980000777700058989500aaaaaa00e76667007eeee700589895000000000555555000077777777777700888850008888888800000000
00088000055555500999999000000000055555500afafaa00eeeeee0077777700555555000000000555555500777777777777770000000000088880000000000
000000000555555009aaaa9000000000000000000000000000000000000000000000000000000000555555557777777777777777000000000088880000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000555555550000000000000000777777770000000000000000
0dddddd0000000000000000000000000000770000007700000077000000770000007700000000000555555550000007777000000777777770000000000000000
0dcc7cd00077770000000000000000000077770000ffff0000779900007677000094490000000000555555550000077777700000777777770000000000000000
0dccc7d0007a97000000000000000000077777700777ff7007799770077777700449449000000000555555550007777777777000775777770000000000000000
0d1cc7d00079a700000000000000000077777777fffff77777797777777677677777777700000000555555550007777777777000775777770000000000000000
0dc1ccd000777700000000000000000077777777ff77777777799977677777777777777700000000555555550077577775777700575575578800000000000000
0dddddd000000000000000000000000077333377779999777788899777aaaa767722227700000000555555550775575775555770555575558880000000000000
0000000000000000000000000000000000333300009999000088880000aaaa000022220000000000555555555555575775555555555555558888000000000000
00000000000000000000000000000000666666666666666666666666666666666666666600000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000063999776699ee796699999f66f939f966a9a97a600000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000063b997a66997e73669ffff466f99bfb669a9a77600000000000000000000000000000000000000000000000000000000
000000000000000000000000000000006b394f966447ee3669f44f966f9f9f966999999600000000000000000000000000000000000000000000000000000000
000000000000000000000000000000006339449664f9993669ffff36693f93966a99a99600000000000000000000000000000000000000000000000000000000
000000000000000000000000000000006449977664f9779667799bb6699f99f6699a333600000000000000000000000000000000000000000000000000000000
000000000000000000000000000000006f499a7669997a9667a993b66399b9f669993bb600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000666666666666666666666666666666666666666600000000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7ccc777c7c7c777c7ccccccc77cc
c6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7ccc7ccc7c7c7ccc7cccc7ccc7cc
c666ccc77ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7ccc77cc7c7c77cc7cccccccc7cc
ccc6c77777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7ccc7ccc777c7ccc7cccc7ccc7cc
c666777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777c777cc7cc777c777ccccc777c
cccf77777f777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccfffff7777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccfffffff777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc77ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccc77777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccc777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccf77777f777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccfffff7777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccfffffff777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77cccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777ccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777777ccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccf77777f777cccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfffff7777777ccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfffffff777777cccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccc77ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc77777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccc777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccf77777f777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccc77ccccccccccccccccccccccccccfffff7777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc77777cccccccccccccccccccccccccfffffff777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccf77777f777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cfffff7777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cfffffff777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777777777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777777777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777777777777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777777777777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc77777777777777777777cccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccc7777777777777777777777ccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccc77777775777777757777777777ccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccc77777775777777757777777777ccccccccccccccccccc8cccc8cccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc7757775755755757557557757777cccccccccccccccccc8cccc8cccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc775575755557555555575557555577cccccccccccccccccc8668ccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc55555757555555555555555575555555cccccccccccccccc66aa66cccccccccccccccccccccccccc
ccccc565888ccccccccccccccccccccccccccccccccccccc55555555555555555555555555555555ccc555555ccccccc6caac6c77cccccccccccc888565ccccc
cccc55658888cccccccccccccccccccccccccccccccccc555555555555555555555555555555555555c577775ccccccc66aa667777cccccccccc88885655cccc
cccc556588888888888888888888888888888888888888888888888888888888888888888888888888857167588888885888858888888888888888885655cccc
ccccc5658888888888888888888888888888888888888888888888888888888888888888888888888885716758888886688886688888888888888888565ccccc
cccccc66888888888888888888888888888888888888888888888888555555888888888888888888888577775888888888888888888888888888888866cccccc
ccccccc588888888888888888888888888888888888888888888888857777588888888888888888888855555588888888888888888888888888888885ccccccc
cccccccccccccccccccccccccccccccccccccc8888555555555555555716755555555555555555555555558888cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccc8888555555555555555716755555555555555555555555558888cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccc8888555555555555555777755555555555555555555555558888cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccc8888555555555555555555555555555555555555555555558888cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccc55888855555555557777555555555555555555555555555555888855cccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc5558888555555555571675555555555555555555555555555558888555ccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccc555588885555555555716755555555555555555555555555555588885555cccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccc555588885555555555777755555555555555555555555555555588885555cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc55555888855555555555555555555555555555555555555555555888855555ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc5555558888555555555555555555555555555555555555555555558888555555cccccccccccccccccccccccccccccccc
ccccccccccccc565888ccccccccccccc5555558888555555555555555555555555555555555555555555558888555555ccccccccccccc888565ccccccccccccc
cccccccccccc55658888cccccccccc55555555888855557777555555555555555555555555555555555555888855555555cccccccccc88885655cccccccccccc
cccccccccccc55658888888888888888888888888888857997588888888888888888888888888888888888888888888888888888888888885655cccccccccccc
ccccccccccccc5658888888888888888888888888888857f9758888888888888888888888888888888888888888888888888888888888888565ccccccccccccc
cccccccccccccc6688888888888888888888888888888577775888888888888888888888888888888888888888888888888888888888888866cccccccccccccc
ccccccccccccccc58888888888888888888888888888855555588888888888888888888888888888888888888888888888888888888888885ccccccccccccccc
ccccc555555cccccccccccccc555555555555588885555555555555555555555555555555555555555555588885555555555555ccccccccccccccccccccccccc
ccccc577775ccccccccccccc55555555555555888855555555555555555555555555555555555555555555888855555555555555cccccccccccccccccccccccc
ccccc57af75ccccccccccccc55555555555555888855555555555555555555555555555555555555555555888855555555555555cccccccccccccccccccccccc
ccccc57fa75ccccccccccc555555555555555588885555555555555555555555555555555555555555555588885555555555555555cccccccccccccccccccccc
ccccc577775cccc77ccc5555555555555555558888555555555555555555555555555555555555555555558888555555555555555555cccccccccccccccccccc
ccccc555555cc77777c555555555555555555588885555555555555555555555555555555555555555555588885555555555555555555ccccccccccccccccccc
cccccccccccc77777755555555555555555555888855555555555555555555555555555555555555555555888855555555555555555555cccccccccccccccccc
cccccccccccf77777f55555555555555555555888855555555555555555555555555555555555555555555888855555555555555555555cccccccccccccccccc
ccccccccccfffff775555555555555555555558888555555555555555555555555555555555555555555558888555555555555555555555ccccccccccccccccc
ccccccccccffffff555555555555555555555588885555555555555555555555555555555555555555555588885555555555555555555555cccccccccccccccc
cccccccccccccccc555555555555555555555588885555555555555555555555555555555555555555555588885555555555555555555555cccccccccccccccc
cccccccccccccc5555555555555555555555558888555555555555555555555555555555555555555555558888555555555555555555555555cccccccccccccc
cccccccccccc55555555555555555555555555888855555555555555555555555555555555555555555555888855555555555555555555555555cccccccccccc
ccccccccccc5555555555555555555555555558888555555555555555555555555555555555555555555558888555555555555555555555555555ccccccccccc
cccccccccc555555555555555555555555555588885555555555555555555555555555555555555555555588885555555555555555555555555555cccccccccc
cccccccccc555555555555555555555555555588885555555555555555555555555555555555555555555588885555555555555555555555555555cccccccccc
ccccccccc55555555555555555555555555555888855555555555555555555555555555555555555555555888855555555555555555555555555555ccccccccc
cccccccc5555555555555555555555555555558888555555555555555555555555555555555555555555558888555555555555555555555555555555cccccccc
cccccccc5555555555555555555555555555558888555555555555555555555555555555555555555555558888555555555555555555555555555555cccccccc
cccccc55555555555555555555555555555555888855555555555555555555555555555555555555555555888855555555555555555555555555555555cccccc
cccc555555555555555555555555555555555588885555555555555555555555555555555555555555555588885555555555555555555555555555555555cccc
ccc55555555555555555555555555555555555888855555555555555555555555555555555555555555555888855555555555555555555555555555555555ccc
cc5555555555555555555555555555555555558888555555555555555555555555555555555555555555558888555555555555555555555555555555555555cc
cc5555555555555555555555555555555555558888555555555555555555555555555555555555555555558888555555555555555555555555555555555555cc
c555555555555555555555555555555555555588885555555555555555555555555555555555555555555588885555555555555555555555555555555555555c
55555555555555555555555555555555555555888855555555555555555555555555555555555555555555888855555555555555555555555555555555555555
55555555555555555555555555555555555555888855555555555555555555555555555555555555555555888855555555555555555555555555555555555555
55555555555555555555555555555555555555888855555555555555555555555555555555555555555555888855555555555555555555555555555555555555
55555555555555555555555555555555555555888855555555555555555555555555555555555555555555888855555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555
55555555555555555555555555555555555566666666555555555555555555555555555555555555555566666666555555555555555555555555555555555555

__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1010102e10101010102e1010102d001b1c000000000000001b1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000012000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001e10101110101010101110102d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001200000000001200000000000000001b1c000000001b1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000012000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000012000000000012000000000000000000002100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000130000000000130000000000000000000c0d0d0d0d0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001d00000000001d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000001b1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000002b2c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000003b3d3d3c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001a3a3a3a3a2a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001a3a3a3a3a3a3a2a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001a3a3a3a3a3a3a3a3a2a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001a3a3a3a3a3a3a3a3a3a3a2a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001a3a3a3a3a3a3a3a3a3a3a3a3a2a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a3a3a3a3a3a3a3a3a3a3a3a3a3a3a2a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000c0d040d06080d070d0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002401000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000571000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000037710347103071029710227101e7101e7101b7101971016710127100f7100971005710037100271000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400003a010320102f5102b5102a5102851021710197102171016510135100f5100b510065100351000510105000b5000250000000000000000000000000000000000000000000000000000000000000000000
0002000021010210102101021010210102101024010240102401024010230102301023010230102301021010210102101021010240202402024020380001b0001100028010280102f0102f0102b0102b01000000
0001000015050190501e05022050250502405021050200501f05018050110502f2001f200152001a70021700287002c700317003170034700367000000038700387003770036700347002f700237001170000000
0005000015710197201e73022740257502475021750207401f73018720117101970013700117000d7000a7000a7000c7000f70012700007000070000700007000070000700007000070000700007000070000700
00040000310502c05029050240501f050180500f0500905002040000500206001070000700007001070000700f000150001b000240002d00033000390003f0000000000000000000000000000000000000000000
01100000182551c2551c2551d255182551c255182551d2551d2551d25500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205
011000001c73324733297332a7332973320733187331473312733147333073329733237331e7331d7330000300003000030000300003000030000300003000030000300003000030000300003000030000300003
01100000234250c425234250c425214250e425214250e4251f425104251f425104251d425114251d425114251f4251f4251d4251d4251c4251c42511425114251342513425154251542517425174251a42518425
011000000c143001030c143001030c143001030c143001030c143001030c143001030c143001030c1430c143001030c1430c1430c143001030c143001030c143001030c1430c1430c14300103001030010300103
01100000101231112310123111231112310123151231712315123171231512315123151231712317123171231f1231f1231f12321123211231c123181231f1231f12321123211231c1231c123121211212118123
011000000c3250c3250e3250e3252432524325233252332524325243252332523325213252132518325183250c3250c325103251032510325213252132520325203250c3250c3251132511325103250c3251f325
01100000187221a72218722187221d7221872218722177221872217722177221872218722187221d7221d7221d722187221a7221c7221d7221f7222172223722247222472223722217221d7221c722187221f722
__music__
01 0a0b4c44
00 0c0b4344
00 0d0b4344
02 0e424344

