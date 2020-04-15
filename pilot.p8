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
end

function menu_update()
	if btnp(5) then run_level() end
end

function menu_draw()
	cls()
 color(3)
 print('welcome to: the pilot')
 print('\n')
 print('press <- and -> to move')
 print('avoid the walls')
 print('\n')
	print('press x to start')
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
 wall_gap = 25
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
 dialogue_blinker_increment_time = 1
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
 
 create_barriers()

 move_walls()

 check_and_increase_difficulty()

 manage_messages()

 check_difficulty_and_reset_wave()

 -- check_player_hit()

 check_player_lives()

 check_win()
end

--game-draw------------------------------------------------------------------------------------------
--game-draw------------------------------------------------------------------------------------------
--game-draw------------------------------------------------------------------------------------------
--game-draw------------------------------------------------------------------------------------------
--game-draw------------------------------------------------------------------------------------------
--game-draw------------------------------------------------------------------------------------------

function level_draw()
 cls()
 rect(0,0,127,127,7) --border
 
 line(0,117,127,117,7) -- console border
 print('this is mission control', 2, 120, 7)
 if time() > dialogue_blinker_start_time then
  print('>', 122, 120, 7)
  if time() > dialogue_blinker_start_time + dialogue_blinker_increment_time then
   dialogue_blinker_start_time += dialogue_blinker_increment_time + 1
  end
 end

 -- print('lives:'..player.lives, 90, 120, 7)
 -- print('wave:'..wave, 8, 120, 7)
 
 spr(player.sprite,player.x,player.y)

 display_messages()
 
 for wall in all(walls) do
  rectfill(wall.x,wall.y,wall.x + wall.width - 1,wall.y + wall.height - 1,wall.col)
 end
end

--game-functions------------------------------------------------------------------------------------------
--game-functions------------------------------------------------------------------------------------------
--game-functions------------------------------------------------------------------------------------------
--game-functions------------------------------------------------------------------------------------------
--game-functions------------------------------------------------------------------------------------------
--game-functions------------------------------------------------------------------------------------------

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
 barrier_counter += 1
 wall_one_width = flr(rnd(128 - wall_gap))
 wall_two_x = wall_one_width + wall_gap
 wall_two_width = 128-wall_two_x

 wall_one = {
  x = 0,
  y = 0,
  width = wall_one_width,
  height = 5,
  col = 3,
  start = time() + barrier_time_pause
 }
 wall_two = {
  x = wall_two_x,
  y = 1,
  width = wall_two_width,
  height = 5,
  col = 3,
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
 if wave > 1 then
  game.update = win_update
  game.draw = win_draw
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

function win_update()
end

function win_draw()
  cls()
  print('win!', 90, 90, 7)
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
000dd000000000000b3000298028013009a002e1d101000b33000000029900013006100000000000000000000000000000000000000000000000000000000000
0d17c150000dd000b300029a228e03b09aa02ef0160c00bbb0030002999a0013b00d6100001ddddd0dddddddddddddddddddd511001ddddd0ddddddddddddddd
dd27c1550017c1d033bb0499088813b49190effd1d6c103bb00b30299aaa013bb000d6d601d7777d077777777777677777776d5001d777770777777777776777
d6dcc1d50557c2dd0b1b041402021239a9a0f1e6d661c10330bb3099a9aa0333bd100d660d77666d0666666666666666666666501d7766660666666666666666
d6d511d505dcc26d0b8b02492812013a90a02ef612dc0c010bbbb29aaa9913bb3ddd16d60d766ddd0dddddddddddddddddddddd01d766ddd0ddddddddddddddd
1d5dd55105d5216d3b330000880831090000e1f6166cc000bb1b399aaaaa333bb16ddd210d76dd11011111313b3bbbbbbbbb3b301d76dd110111111111111111
01100110015dd5d1b1000940820030049040e1e1d10cc1003b11b44009aa3213b66106220d76d1110000000000000000000000001db6d1110000000000000000
00000000001001103bb004202820130040002e201d0c100033b8b441809a128136600d660d76d1100000000000000000000000001d76d1100000000000000000
1771707707c00aa0b30000290028013009a002e1d1000101033bb494114411221666d100000000000666d6d00666d6d00666d6d0001000000666d6d000000000
9a79b0bb0cc007a0b300029a228e03b09aa02ef01600c003b0311249449913b33d66d0000076d110677111dd677111dd677111dd13b6d110677000dd0000dda0
899800000110022033bb0499888813b49190effd1d6c103bbb01322444441331316d10000076d110677cc11d677bb11d6779911d13b6d1106700400d00055080
2822b0bb000000000b1b041402021239a9a0f1e6d661c1bbb000002220000133106dd0000076d11061cccc1d61bbbb1d6199991d13b6d1106020000d00565500
008000001cc12aa20b8b02492812013a90a02ef612dc0c3bbb30001333100013101d10000076d110d1cccc1dd1bbbb1dd199991d13b6d110d040420d05666510
02003033c77ca77a3b330000880831090040e1f6166cc013b300003bb3300001000000000076d110611cc11d611bb11d6119911d13b6d1106000240d05565510
00200000c77ca77ab1009400822030049400e1e1d10cc1000299203bb3300000000000000076d110dd1111dddd1111dddd1111dd13b6d110dd0000dd00555100
000000001cc12aa23b3042002800100000021021d00c100029aa90333310000000000000000000000dddddd00dddddd00dddddd0001000000dddddd000011000
02aaaa2001cccc1003b77b300999951000000009959500009aa944131100b000000000000d76d1100000000000000000000000001d76d1100000000000000000
2aa77aa21cc77cc1003bb3009955555100000099551511009994a4000000001b00b000a00d76dd110000000000000000000000001db6dd110000000000000000
aa7777aacc7777cc0003300995555555100009955155511029999400000000b3007000700d776ddd0ddddd3d3b3bbbbbbbbb3b301d776ddd0ddddddddddddddd
a777777ac777777c005995095155511551009955555955100244420000000000007000700d67777d0777767777777777677776501d6777770777777777776777
a777777ac777777c0591551555951559550095115555551000008800880000000030009001d6666d066666666666666666666d5001d666660666666666666666
aa7777aacc7777cc091551155555155955105155555551100008ee8888800bb00000000001155555055555555555555555555511001ddddd0ddddddddddddddd
2aa77aa21cc77cc1955551105555599555100155955111000008e8888880b7130070007000111111011111111111111111111111100111110111111111111111
02aaaa2001cccc1095551100155555555110001111110000000888888280b1130b370a9700000000000000000000000000000000000000000000000000000000
00000000000000005511100011155551111000000000995550008888280003300b370a9700000000000000000000000000001333333b31113bb0000000000000
005001c77c1000000111000001111111111000099999555551000882800000000070007000000b00000000000003bb300000011333b311813333000000000000
00501c77cdc10000000000000011111111009995555555515110008800000000000000000000b7b300000000033bbbb000000011331118813bbb000000000000
0051ccccdddc10000009551000000111100995555555551591100000000bbb000bb00aa00003b3bbb300000033bb77b001001111111111133333300000000000
0dd67766666d6dd0009155510000000000095511551115511110000000b7b130b33ba99a003b3b77bb00000033bb77b0031333333118813bbbbbb30000000000
dd6776666666d6dd005555510000000000055155911111111100000000bb1130b3bba9aa0133bbb77b10000013377b300b333bbb331813bbbbbbb30000000000
0282002882002820001555100000000000015511110000000000000000b11b300bb00aa000133bbb773111133b3000000b1b3bbbb31133bb777bbb3000000000
000000000000000000011100000000000000111100000000000000000003330000000000000333bbb33b3311330000000737b777b3133bb77777bb3000000000
