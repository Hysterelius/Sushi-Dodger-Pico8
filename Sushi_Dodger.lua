--sushi dodger
--Hystersis
function _init()
	level=1
	nexlev=false--this is to play level transition
	g=0.025 --gravity
	life=0 --so no extra lives
	numen= {10,16,20,22,24,55,47,42,35,30} --this is how many sushi spawn and likelihood of special sushi
	blink_start() --blink table
	p={}
	p.alive=false
	start_seq=true
end

function start_game()
	make_player()
	enemies={} --makes enemy table
	slow=false --ice enemy hasn't been hit
	winseq={0,0} --win sequence, this is an array, the first digit = winseq[1] as calls first digit, and does the maths on it
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
	blink_i=1--position in sequence
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
		music(-1,0,0)--stops preexisting music
		music(1,30,0)--starts music
		for i=1,numen[level] do --spawn a different number of sushi each level
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
 --that enemy doesn't spawn on player
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
		if nexlev then--if play transition, keep repeating
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
			e.f = false--the enemy can now move normally
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
	if blinkframe>blinkspeed then --repeated until blinkspeed
		blinkframe=0--then reset
		blink_i+=1--go up once through the sequence
		rainbow_i+=1
		if blink_i>#c_seq then
			blink_i=1--when reach end of sequence start again
		end
		if rainbow_i>#r_seq then
			rainbow_i=1
		end
		blink=c_seq[blink_i]--blink = blink_i's number's position in the sequence
		rainbow=r_seq[rainbow_i]
		
	end
	if iceframe>icespeed then--ice has a different speed from the other two
		iceframe=0--start this loop again
		ice_i+=1--move up the sequence
		gold_i+=1
		bow_i+=1
		if ice_i>#i_seq then
			ice_i=1--reset the movement up the sequence
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
		foreach(enemies,draw_enemy)--draw enemies
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
	print("(c) Hystersis, 2020",12,120,5)
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
	if winseq[1]/15 == flr(winseq[1]/15) and winseq[2] < 8 then--so hat goes down 2 times per second, until on head
		winseq[2]+=1--move hat down
	end--hat comes down
	spr(1,60,36)--print the p sprite
	spr(34,60,24+winseq[2])--this is the hat
	if winseq[2] < 9 and winseq[2] >= 0 then--this is the around outline around the hat
		rectfill(61,24+winseq[2]+6,66,24+winseq[2]+6,rainbow)--it just draws a rectangle on the hat
		rectfill(61,24+winseq[2]+7,61,24+winseq[2]+7,rainbow)
		rectfill(66,24+winseq[2]+7,66,24+winseq[2]+7,rainbow)
	end--draws a rainbow hat
	print("press ❎ to restart",28,72,rainbow)--asks if p wants to restart
	if btn(5) then
		_init()
	end
	winseq[1]+=1--this is a timer
end