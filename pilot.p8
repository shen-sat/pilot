pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
	game = {}
	show_menu()

end

function _update()
	game.update()
end

function _draw()
	game.draw() 
end

--menu-----------------------------------
--menu-----------------------------------

function show_menu()
	game.update = menu_update
	game.draw = menu_draw

 dialogue_blinker_start_time = 0
 dialogue_blinker_stop_time = 0
 blinking = true
 softer_world_flag = true
end

function menu_update()
 if btnp(5) then
  softer_world_flag = false
  run_intro_level() 
 end
end

function menu_draw()
	cls()
  
  print("i'm afraid of this mission.")
  print("i'm scared of what's out there.")
  print("\nbut when i tried...")
  print("...to tell my mother...")
  print("...she smiled so wide and said:")
  print(  "\n'my son, the pilot'.")

  display_blinker()
end

function run_intro_level()
 game.update = intro_level_update
 game.draw = intro_level_draw

 player = {
  x = 60,
  y = 100,
  width = 8,
  height = 7,
  sprite = 0,
  lives = 1,
  hit = false,
  hittable = true,
  recovery_time = 3
 }

 stars = {}
 initial_stars()
 generate_star_time = 0

 hq_start_dialogue_lines = {
  'this is hq speaking.',
  'before your mission...',
  '...you must pass this test.',
  'avoid the walls.',
  'good luck.'
 }

 dialogue_blinker_start_time = 0
 dialogue_blinker_stop_time = 0
 hq_start_dialogue_index = 1
 hq_start_dialogue_start_time = 0
 hq_start_show_dialogue = true
 blinking = true
end

function intro_level_update()
 if hq_start_dialogue_index > #hq_start_dialogue_lines then
  run_level()
 end

 if btnp(5) then 
  hq_start_dialogue_index += 1
 end

 generate_stars()

 move_stars()

 manage_hq_start_dialogue()

end

function intro_level_draw()
 cls()
 rectfill(0,0,127,127,0) -- background
 rect(0,0,127,127,7) --border
 line(0,117,127,117,7) -- console border

 display_hq_start_dialogue()

 spr(player.sprite,player.x,player.y)

 for star in all(stars) do
  pset(star.x, star.y, 1)
 end

end
--game------------------------------------------------------------------------------------------
--game------------------------------------------------------------------------------------------
--game------------------------------------------------------------------------------------------
--game------------------------------------------------------------------------------------------
--game------------------------------------------------------------------------------------------
--game------------------------------------------------------------------------------------------
function run_level() 
 player = {
  x = 60,
  y = 100,
  width = 8,
  height = 7,
  sprite = 0,
  lives = 1,
  hit = false,
  hittable = true,
  recovery_time = 3
 }
 walls = {}
 barrier_time = time() + 3
 barrier_time_modifier = 2.5
 barrier_time_modifier_original = 2.5
 barrier_time_pause = 1
 barrier_counter = 0
 wall_gap = 35
 difficulty = 0
 wave = 1
 prev_wave = wave
 next_wave = false

 message_lines = {
  "143 789 5643 94?",
  "c43 you h64r 94?",
  "c4n you h6ar u4?",
  "can you hear us?",
 }
 message_lines_index = 1
 message_colors = {1,5,3,11}
 message_color_index = 0
 message_color_counter = 2
 message_on = false

	game.update = level_update
	game.draw = level_draw

 dialogue_blinker_start_time = 0
 dialogue_blinker_stop_time = 0
 hq_start_dialogue_index = 1
 hq_start_dialogue_start_time = 0
 hq_start_show_dialogue = true
 blinking = true

 -- stars = {}
 -- initial_stars()
 generate_star_time = 0

 switch_color = true
 switch_time_start = 0
 switch_time_end = 0
 switch_time_on_lengths = { 0.05, 0.2, 0.05, 20 }
 switch_time_off_lengths = { 1.5, 0.2, 0.2, 0 }
 switch_time_lengths_index = 1
end

--game-update------------------------------------------------------------------------------------------
--game-update------------------------------------------------------------------------------------------
--game-update------------------------------------------------------------------------------------------
--game-update------------------------------------------------------------------------------------------
--game-update------------------------------------------------------------------------------------------
--game-update------------------------------------------------------------------------------------------

function level_update()

	if btn(0) then player.x-=3 end
 if btn(1) then player.x+=3 end
 
 if btnp(5) then hq_start_dialogue_index += 1 end
 generate_stars()

 move_stars()
 
 create_barriers()

 move_walls()

 check_and_increase_difficulty()

 manage_messages()

 check_difficulty_and_reset_wave()

 

 -- check_player_hit()

 check_player_lives()

 check_win()

 if (wave > 3) and (difficulty > 4) then do_flicker = true end

end

--game-draw------------------------------------------------------------------------------------------
--game-draw------------------------------------------------------------------------------------------
--game-draw------------------------------------------------------------------------------------------
--game-draw------------------------------------------------------------------------------------------
--game-draw------------------------------------------------------------------------------------------
--game-draw------------------------------------------------------------------------------------------

function level_draw()
 cls()
 rectfill(0,0,127,127,0) -- background
 rect(0,0,127,127,7) --border
 line(0,117,127,117,7) -- console border
 
 spr(player.sprite,player.x,player.y)

 print('wave:'..wave, 8, 120, 7)
 print('lives:'..player.lives, 90, 120, 7)

 display_messages()
 
 for wall in all(walls) do
  rectfill(wall.x,wall.y,wall.x + wall.width - 1,wall.y + wall.height - 1,wall.col)
 end

 for star in all(stars) do
  pset(star.x, star.y, 1)
 end

if do_flicker then start_flicker() end

end

--game-functions------------------------------------------------------------------------------------------
--game-functions------------------------------------------------------------------------------------------
--game-functions------------------------------------------------------------------------------------------
--game-functions------------------------------------------------------------------------------------------
--game-functions------------------------------------------------------------------------------------------
--game-functions------------------------------------------------------------------------------------------
function start_flicker()
 pal()
 if time() > switch_time_start then
  pal(0,7)
  pal(7,0)
  sfx(4)
  sspr(8,0,32,24,49,30)
  if switch_color then
   switch_color = false
   switch_time_end = time() + switch_time_on_lengths[switch_time_lengths_index]
  end
  if time() > switch_time_end then
   sfx(4, -2)
   switch_color = true
   switch_time_start = time() + switch_time_off_lengths[switch_time_lengths_index]
   switch_time_lengths_index += 1
  end
 end
end

function generate_stars()
 if time() > generate_star_time then
  star = {
   x = flr(rnd(128)),
   y = -1
  }
  add(stars, star)
  if hyperjump then
   if time() > hyperjump_time + 4 then
    generate_star_time = time() + 0.04
   else
    generate_star_time = time() + 0.05
   end
  else 
   generate_star_time = time() + 0.1
  end
 end
end

function move_stars()
 for star in all(stars) do
   if hyperjump then
    if time() > hyperjump_time + 4 then
     sfx(3, 1)
     star.y += 10
    elseif time() > hyperjump_time + 2 then
     sfx(2, 1)
     star.y += 5
    else
     sfx(1, 1)
     star.y += 2
    end
   else
    star.y += 1
   end
   if star.y > 138 then
    del(stars, star)
   end
 end
end


function initial_stars()
 my_arr = {}
 for i=0,127 do
  add(my_arr, i)
 end

 for i=1,10 do
  point_x = flr(rnd(128))
  point_y = flr(rnd(128))
  star = {
   x = point_x,
   y = point_y
  }
  add(stars, star)
 end
end

function manage_hq_start_dialogue()
 if hq_start_dialogue_index > #hq_start_dialogue_lines then hq_start_show_dialogue = false end
end

function display_hq_start_dialogue()
 if hq_start_show_dialogue then
  print(hq_start_dialogue_lines[hq_start_dialogue_index], 2, 120, 7)
  display_blinker()
 end
end

function display_blinker()
 if time() > dialogue_blinker_start_time then
  if softer_world_flag then
   print('press x to advance >', 46, 120, 7)
  else
   print('>', 122, 120, 7)
  end
  if blinking then
   blinking = false
   dialogue_blinker_stop_time = time() + 1
  end
  if time() > dialogue_blinker_stop_time then
   blinking = true
   dialogue_blinker_start_time = dialogue_blinker_stop_time + 1
  end
 end
end

function display_messages()
 if message_on == false then
  message_on = true
  print(message_lines[message_lines_index],58,64,message_colors[message_color_index])
 else
  message_on = false
  print(message_lines[message_lines_index],58,64,message_colors[message_color_index - 1])
 end
end

function wave_increased()
 if wave > prev_wave then
  prev_wave = wave
  return true
 else
  return false
 end
end

function create_barriers()
	if time() > barrier_time then
		create_barrier()
		barrier_time += barrier_time_modifier
  if next_wave == true then
   next_wave = false
   wave += 1
  end
	end
end

function create_barrier()
 sfx(0)
 barrier_counter += 1
 wall_one_width = flr(rnd(128 - wall_gap))
 wall_two_x = wall_one_width + wall_gap
 wall_two_width = 128-wall_two_x

 wall_one = {
  x = 0,
  y = 0,
  width = wall_one_width,
  height = 5,
  col = 7,
  start = time() + barrier_time_pause
 }
 wall_two = {
  x = wall_two_x,
  y = 1,
  width = wall_two_width,
  height = 5,
  col = 7,
  start = time() + barrier_time_pause
 }
 add(walls, wall_one)
 add(walls, wall_two)
end

function check_difficulty_and_reset_wave()
 if difficulty > 5 then
  next_wave = true
  barrier_time = time() + 3
  barrier_time_modifier = barrier_time_modifier_original * 0.67
  barrier_counter = 0
  difficulty = 0
 end
end

function wall_collision(player, wall)
 x_1 = player.x
 x_2 = player.x + player.width
 y_1 = player.y
 y_2 = player.y + player.height 

 wall_x_1 = wall.x
 wall_x_2 = wall.x + wall.width
 wall_y_1 = wall.y
 wall_y_2 = wall.y + wall.height

 x_points = { x_1, x_2 }
 y_points = { y_1, y_2 }
  
 for x_point in all(x_points) do
  if x_point > wall_x_1 and x_point < wall_x_2 then
   for y_point in all(y_points) do
    if y_point > wall_y_1 and y_point < wall_y_2 then
     if player.hittable == true then player.hit = true end
    end
   end
  end
 end
end

function check_player_hit()
 if player.hit == true then
  player.lives -= 1
  player.hittable = false
  time_to_recover = time() + player.recovery_time
  player.hit = false 
 end 
 if player.hittable == false and time() > time_to_recover then
  player.hittable = true
  time_to_recover = 0
 end
end

function check_player_lives()
 if player.lives < 1 then show_game_over() end
end

function move_walls()
 for wall in all(walls) do
  if time() > wall.start then
   wall.y += 3
   if wall.y > 138 then
    del(walls, wall)
   end
   wall_collision(player, wall)
  end
 end
end

function check_and_increase_difficulty()
 if barrier_counter == 2 then
  barrier_counter = 0
  difficulty += 1
  barrier_time_modifier = barrier_time_modifier * 0.85 
 end
end

function manage_messages()
 set_next_message_content_and_reset_color()

 increase_message_color_index()

 wipe_message_from_screen_as_last_barrier_passes()
end

function wipe_message_from_screen_as_last_barrier_passes()
 if next_wave == true and #walls == 2 then
  if walls[1].y > 64 then message_color_index = 0 end
 end
end

function set_next_message_content_and_reset_color()
 if wave_increased() == true then
  message_color_index = 0
  message_color_counter = 2
  message_lines_index += 1
 end
end

function increase_message_color_index()
 if difficulty > message_color_counter then
  message_color_counter = difficulty
  message_color_index += 1
 end
end

function check_win()
 if wave > 4 then
  run_win()
  sfx(0, -2)
 end
end

function show_game_over()
 game.update = game_over_update
 game.draw = game_over_draw
end
--win------------------------------------------------------------------------------------------
--win------------------------------------------------------------------------------------------
--win------------------------------------------------------------------------------------------
--win------------------------------------------------------------------------------------------
--win------------------------------------------------------------------------------------------
--win------------------------------------------------------------------------------------------

function run_win()
 game.update = win_update
 game.draw = win_draw

 sfx(4, -2)

 hq_win_dialogue_lines = {
  'congratulations.',
  'you have passed.',
  'you can hyperjump...',
  '...and return to base...',
  '...by pressing z.'
 }

 hq_win_show_dialogue = true
 hq_win_dialogue_index = 1

 blinking = true

 hyperjump = false
 hyperjump_time = 0
 x_shake = 0
 y_shake = 0
end

function win_update()
 calculate_shake()

 if btn(4) and hyperjump == false and hq_win_show_dialogue == false then 
  hyperjump = true
  hyperjump_time = time()
 end

 generate_stars()

 move_stars()

 manage_hq_win_dialogue()
end

function win_draw()
  pal()
  cls()
  print('end!', 90, 90, 7)
  rect(0,0,127,127,7) -- border

  if hyperjump then
   if time() > hyperjump_time + 4 then
    num_x = x_shake + (player.x - 1)
    num_y = y_shake + (player.y - 1)
    spr(player.sprite,num_x,num_y)

    border_y = 117
    border_num_y = y_shake + (border_y - 1) 
    line(0,border_num_y,127,border_num_y,7) -- console border
   elseif time() > hyperjump_time + 2 then
    num_x = x_shake + (player.x - 1)
    num_y = y_shake + (player.y - 1)
    spr(player.sprite,num_x,num_y)

    border_y = 117
    border_num_y = y_shake + (border_y - 1) 
    line(0,border_num_y,127,border_num_y,7) -- console border
   else
    spr(player.sprite,player.x,player.y)
    line(0,117,127,117,7) -- console border
   end
  else
   spr(player.sprite,player.x,player.y)
   line(0,117,127,117,7) -- console border
  end
  

  display_hq_win_dialogue()
  
  if btnp(5) then hq_win_dialogue_index += 1 end

  for star in all(stars) do
   if hyperjump then
    if time() > hyperjump_time + 4 then
     pset(star.x, star.y - 15, 7)
     pset(star.x, star.y - 14, 7)
     pset(star.x, star.y - 13, 7)
     pset(star.x, star.y - 12, 7)
     pset(star.x, star.y - 11, 7)
     pset(star.x, star.y - 10, 7)
     pset(star.x, star.y - 9, 7)
     pset(star.x, star.y - 8, 7)
     pset(star.x, star.y - 7, 7)
     pset(star.x, star.y - 6, 7)
     pset(star.x, star.y - 5, 7)
     pset(star.x, star.y - 4, 7)
     pset(star.x, star.y - 3, 7)
     pset(star.x, star.y - 2, 7)
     pset(star.x, star.y - 1, 12)
     pset(star.x, star.y, 7)
    elseif time() > hyperjump_time + 2 then
     pset(star.x, star.y - 6, 7)
     pset(star.x, star.y - 5, 7)
     pset(star.x, star.y - 4, 7)
     pset(star.x, star.y - 3, 7)
     pset(star.x, star.y - 2, 7)
     pset(star.x, star.y - 1, 7)
     pset(star.x, star.y, 7)
    else
     pset(star.x, star.y - 2, 7)
     pset(star.x, star.y - 1, 7)
     pset(star.x, star.y, 7)
    end
   else  
    pset(star.x, star.y, 1)
   end
  end

end

function calculate_shake()
 if hyperjump then
  if time() > hyperjump_time + 4 then
   x_shake = flr(rnd(5))
   y_shake = flr(rnd(4))
  elseif time() > hyperjump_time + 2 then
   x_shake = flr(rnd(3))
   y_shake = flr(rnd(3))
  end
 end
end

function display_hq_win_dialogue()
 if hq_win_show_dialogue then
  print(hq_win_dialogue_lines[hq_win_dialogue_index], 2, 120, 7)
  display_blinker()
 else
  if hyperjump then
   dialogue_x = 2
   dialogue_y = 120
   if time() > hyperjump_time + 4 then
    num_x = x_shake + (dialogue_x - 1)
    num_y = y_shake + (dialogue_y - 1)
    print(hq_win_dialogue_lines[5], num_x, num_y, 7)
   elseif time() > hyperjump_time + 2 then
    num_x = x_shake + (dialogue_x - 1)
    num_y = y_shake + (dialogue_y - 1)
    print(hq_win_dialogue_lines[5], num_x, num_y, 7)
   else
    print(hq_win_dialogue_lines[5], 2, 120, 7)
   end
  else
   print(hq_win_dialogue_lines[5], 2, 120, 7)
  end
 end
end

function manage_hq_win_dialogue()
 if hq_win_dialogue_index == #hq_win_dialogue_lines then hq_win_show_dialogue = false end
end

--game-over------------------------------------------------------------------------------------------
--game-over------------------------------------------------------------------------------------------
--game-over------------------------------------------------------------------------------------------
--game-over------------------------------------------------------------------------------------------
--game-over------------------------------------------------------------------------------------------
--game-over------------------------------------------------------------------------------------------


function game_over_update()
	if btnp(5) then run_level() end
 if btnp(4) then show_menu() end
end

function game_over_draw()
	cls()
	print('you died! at wave:'..wave)
 print('\n')
 print('press x to restart')
 print('press z to go to menu')
end
__gfx__
0007700000000000000000000000000000000000d101000b33000000029900013006100000000000000000000000000000000000000000000000000000000000
0707707007777700000000777700000000777770160c00bbb0030002999a0013b00d6100001ddddd0dddddddddddddddddddd511001ddddd0ddddddddddddddd
77700777077777000000777777770000007777701d6c103bb00b30299aaa013bb000d6d601d7777d077777777777677777776d5001d777770777777777776777
7770077707777700000777777777700000777770d661c10330bb3099a9aa0333bd100d660d77666d0666666666666666666666501d7766660666666666666666
777777770777770007777777777777700077777012dc0c010bbbb29aaa9913bb3ddd16d60d766ddd0dddddddddddddddddddddd01d766ddd0ddddddddddddddd
7777777700777770777777777777777707777700166cc000bb1b399aaaaa333bb16ddd210d76dd11011111313b3bbbbbbbbb3b301d76dd110111111111111111
0770077000777777777777777777777777777700d10cc1003b11b44009aa3213b66106220d76d1110000000000000000000000001db6d1110000000000000000
00000000000777777777777777777777777770001d0c100033b8b441809a128136600d660d76d1100000000000000000000000001d76d1100000000000000000
1771707700000077000777777777700077000000d1000101033bb494114411221666d100000000000666d6d00666d6d00666d6d0001000000666d6d000000000
9a79b0bb000000770000777777770000770000001600c003b0311249449913b33d66d0000076d110677111dd677111dd677111dd13b6d110677000dd0000dda0
89980000000000770000077777700000770000001d6c103bbb01322444441331316d10000076d110677cc11d677bb11d6779911d13b6d1106700400d00055080
2822b0bb00000077700770777707700777000000d661c1bbb000002220000133106dd0000076d11061cccc1d61bbbb1d6199991d13b6d1106020000d00565500
008000000000007777007707707700777700000012dc0c3bbb30001333100013101d10000076d110d1cccc1dd1bbbb1dd199991d13b6d110d040420d05666510
0200303300000777770000000000007777700000166cc013b300003bb3300001000000000076d110611cc11d611bb11d6119911d13b6d1106000240d05565510
0020000000007777777007777770077777770000d10cc1000299203bb3300000000000000076d110dd1111dddd1111dddd1111dd13b6d110dd0000dd00555100
0000000000077777777077777777077777777000d00c100029aa90333310000000000000000000000dddddd00dddddd00dddddd0001000000dddddd000011000
02aaaa2000777777770777777777707777777700959500009aa944131100b000000000000d76d1100000000000000000000000001d76d1100000000000000000
2aa77aa200777777770777777777707777777700551511009994a4000000001b00b000a00d76dd110000000000000000000000001db6dd110000000000000000
aa7777aa077777777707777777777077777777705155511029999400000000b3007000700d776ddd0ddddd3d3b3bbbbbbbbb3b301d776ddd0ddddddddddddddd
a777777a00777777700777777777700777777700555955100244420000000000007000700d67777d0777767777777777677776501d6777770777777777776777
a777777a000777770000777777770000777770005555551000008800880000000030009001d6666d066666666666666666666d5001d666660666666666666666
aa7777aa00007770000077777777000007770000555551100008ee8888800bb00000000001155555055555555555555555555511001ddddd0ddddddddddddddd
2aa77aa200000700000777777777700000700000955111000008e8888880b7130070007000111111011111111111111111111111100111110111111111111111
02aaaa200000000000000000000000000000000011110000000888888280b1130b370a9700000000000000000000000000000000000000000000000000000000
00000000000000005511100011155551111000000000995550008888280003300b370a9700000000000000000000000000001333333b31113bb0000000000000
005001c77c1000000111000001111111111000099999555551000882800000000070007000000b00000000000003bb300000011333b311813333000000000000
00501c77cdc10000000000000011111111009995555555515110008800000000000000000000b7b300000000033bbbb000000011331118813bbb000000000000
0051ccccdddc10000009551000000111100995555555551591100000000bbb000bb00aa00003b3bbb300000033bb77b001001111111111133333300000000000
0dd67766666d6dd0009155510000000000095511551115511110000000b7b130b33ba99a003b3b77bb00000033bb77b0031333333118813bbbbbb30000000000
dd6776666666d6dd005555510000000000055155911111111100000000bb1130b3bba9aa0133bbb77b10000013377b300b333bbb331813bbbbbbb30000000000
0282002882002820001555100000000000015511110000000000000000b11b300bb00aa000133bbb773111133b3000000b1b3bbbb31133bb777bbb3000000000
000000000000000000011100000000000000111100000000000000000003330000000000000333bbb33b3311330000000737b777b3133bb77777bb3000000000
__sfx__
000c00001d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000010055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000010855000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000011355000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000010561000600006000760013600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
