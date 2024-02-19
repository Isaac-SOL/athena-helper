extends Node2D

@export var other_player: PackedScene
@export var tower: PackedScene
@export var center_min_distance: float
@export var center_max_distance: float

@onready var tether_angels := %"Tether Angels".get_children()
@onready var angel_positions_A := %"Angel Positions A".get_children()
@onready var angel_positions_B := %"Angel Positions B".get_children()
@onready var cleave_angels := %"Cleave Angels".get_children()
@onready var cleave_positions_A := %"Cleave Positions A".get_children()
@onready var cleave_positions_B := %"Cleave Positions B".get_children()
@onready var tether_positions_A := %"Tether Positions A".get_children()
@onready var tether_positions_B := %"Tether Positions B".get_children()
@onready var tower_positions := %"Tower Positions".get_children()

var players: Array[Node2D] = []
var tanks: Array[Node2D] = []
var healers: Array[Node2D] = []
var supports: Array[Node2D] = []
var dps: Array[Node2D] = []
var tethered_players: Array[Node2D] = []
var light_tethered_players: Array[Node2D] = []
var dark_tethered_players: Array[Node2D] = []
var light_debuffed_players: Array[Node2D] = []
var dark_debuffed_players: Array[Node2D] = []
#  3  |  0
#  -------
#  1  |  2
var light_laser_in_your_area: Array[bool] = []
var light_towers: Array[Tower] = []
var dark_towers: Array[Tower] = []

var pattern_A: bool
var pressed_gcds: int = 0
var gcd_count: int = 0

func _ready():
	get_tree().paused = false

func _process(_delta):
	%GCDButton.set_pressable(%Athena.is_on_player())

func pick_random_player_position() -> Vector2:
	var new_pos := Vector2(randf_range(-1, 1), randf_range(-1, 1))
	new_pos = new_pos.normalized() * randf_range(center_min_distance, center_max_distance)
	return %Arena.position + new_pos

func pick_role(role: int):
	# Set player's role
	players.append(%PlayerCharacter)
	var role_arrays := [tanks, healers, dps]
	role_arrays[role].append(%PlayerCharacter)
	if role != 2:
		supports.append(%PlayerCharacter)
	%PlayerCharacter.set_role(role)
	%PlayerCharacter.global_position = pick_random_player_position()
	%PlayerCharacter.visible = true
	
	# Create other players and set their roles
	while players.size() < 8:
		var other_role: int
		if tanks.size() < 2:
			other_role = 0
		elif healers.size() < 2:
			other_role = 1
		else:
			other_role = 2
		var new_player = other_player.instantiate()
		role_arrays[other_role].append(new_player)
		if other_role != 2:
			supports.append(new_player)
		players.append(new_player)
		new_player.set_role(other_role)
		new_player.global_position = pick_random_player_position()
		%Players.add_child(new_player)
	
	%GCDButton.unfreeze()
	%SprintButton.unfreeze()
	%GCDTimer.start()
	
	# Start simulation
	timeline()

func seconds(duration):
	return get_tree().create_timer(duration).timeout

func start_cast(duration: float, cast_name: String):
	%CastBar.visible = true
	%CastLabel.text = cast_name
	%CastBar.value = 0
	var tween := get_tree().create_tween()
	tween.tween_property(%CastBar, "value", 100, duration)
	tween.tween_callback(func(): %CastBar.visible = false)

func timeline():
	await seconds(1)
	start_cast(2.8, "Paradeigma")
	await seconds(2.8)
	%Athena.squish_squash()
	await seconds(1.6)
	spawn_angels()
	await seconds(2.3)
	start_cast(3.8, "Engravement of Souls")
	await seconds(0.8)
	move_angels(true)
	await seconds(1)
	transform_angels(true)
	await seconds(1)
	move_angels(false)
	await seconds(1)
	transform_angels(false)
	%Athena.squish_squash()
	await seconds(1)
	start_tethers()
	players_move_tether()
	await seconds(1.5)
	players_move_tower()
	await seconds(8)
	shoot_lasers()
	if get_tree().paused: return
	await seconds(0.8)
	spawn_towers()
	players_move_to_tower()
	await seconds(3.7)
	if get_tree().paused: return
	towers_disappear()
	players_move_out_of_cleave()
	await seconds(2.8)
	if get_tree().paused: return
	shoot_cleaves()
	await seconds(1)
	cleaves_disappear()

func spawn_angels():
	pattern_A = randi() % 2 == 0
	for i in range(4):
		tether_angels[i].appear()
	for i in range(2):
		cleave_angels[i].appear()

func move_angels(blue: bool):
	if blue:
		var angel_targets = [angel_positions_A, angel_positions_B][0 if pattern_A else 1]
		for i in range(4):
			tether_angels[i].set_target_position(angel_targets[i].position)
	else:
		var cleave_targets = [cleave_positions_A, cleave_positions_B][0 if pattern_A else 1]
		for i in range(2):
			cleave_angels[i].set_target_position(cleave_targets[i].position)

func transform_angels(blue: bool):
	if blue:
		for i in range(4):
			tether_angels[i].transform()
	else:
		for i in range(2):
			cleave_angels[i].transform()

func start_tethers():
	# Pick random players
	var picked_players: Array[int] = []
	while picked_players.size() < 2:
		var picked = players.find(supports.pick_random())
		if picked_players.count(picked) == 0:
			picked_players.append(picked)
	while picked_players.size() < 4:
		var picked = players.find(dps.pick_random())
		if picked_players.count(picked) == 0:
			picked_players.append(picked)
	
	# Tether the players
	for i in range(4):
		var light: bool
		if light_tethered_players.size() == 2:
			light = false
		elif dark_tethered_players.size() == 2:
			light = true
		else:
			light = randi() % 2 == 0
		var tether_player := players[picked_players[i]]
		(light_tethered_players if light else dark_tethered_players).append(tether_player)
		tethered_players.append(tether_player)
		tether_angels[i].start_targeting(tether_player, light)
		light_laser_in_your_area.append(light)
	
	# Find other players
	var other_players: Array[int] = []
	for p in range(8):
		if picked_players.count(p) == 0:
			other_players.append(p)
	
	# Debuff other players
	var sl: int = 0
	var sd: int = 0
	var dl: int = 0
	var dd: int = 0
	for i in range(4):
		var light: bool
		var debuff_player = players[other_players[i]]
		if debuff_player.get_role() == 2:
			if dl == 1:
				light = false
			elif dd == 1:
				light = true
			else:
				light = randi() % 2 == 0
				if light:
					dl = 1
				else:
					dd = 1
		else:
			if sl == 1:
				light = false
			elif sd == 1:
				light = true
			else:
				light = randi() % 2 == 0
				if light:
					sl = 1
				else:
					sd = 1
		(light_debuffed_players if light else dark_debuffed_players).append(debuff_player)
		if debuff_player is PlayerCharacter:
			%Debuff.set_tower(light, 9.5)

func player_move_tether(player: OtherPlayer, pos: Vector2):
	await seconds(randf_range(0.25, 1.5))
	player.set_target(pos)

func players_move_tether():
	var tether_positions = [tether_positions_A, tether_positions_B][0 if pattern_A else 1]
	for i in range(4):
		if tethered_players[i] is OtherPlayer:
			player_move_tether(tethered_players[i], tether_positions[i].position)

func player_move_tower(player: OtherPlayer, light_debuff: bool):
	await seconds(randf_range(0.8, 3))
	if player.get_role() == 2:
		if light_laser_in_your_area[3] != light_debuff:
			player.set_target(tower_positions[3].position)
		elif light_laser_in_your_area[1] != light_debuff:
			player.set_target(tower_positions[1].position)
		else:
			player.set_target(tower_positions[2].position)
	else:
		if light_laser_in_your_area[0] != light_debuff:
			player.set_target(tower_positions[0].position)
		elif light_laser_in_your_area[2] != light_debuff:
			player.set_target(tower_positions[2].position)
		else:
			player.set_target(tower_positions[1].position)

func players_move_tower():
	for p in light_debuffed_players:
		if p is OtherPlayer:
			player_move_tower(p, true)
	for p in dark_debuffed_players:
		if p is OtherPlayer:
			player_move_tower(p, false)

func shoot_lasers():
	for angel in tether_angels:
		angel.stop_targeting()
		angel.shoot_laser()
		if !angel.distance_ok():
			lose_condition("You were too close to your laser", false)
		if angel.hitting_player():
			lose_condition("You were hit by a laser", false)
		if angel.hitting_other_player():
			lose_condition("You hit someone with your laser", true)
	for p in light_tethered_players:
		if p is PlayerCharacter:
			%Debuff.set_person(true, 11.5)
	for p in dark_tethered_players:
		if p is PlayerCharacter:
			%Debuff.set_person(false, 11.5)

func spawn_tower(light: bool, player: Node2D) -> Tower:
	var new_tower = tower.instantiate()
	new_tower.make_light(light)
	new_tower.global_position = player.global_position
	(light_towers if light else dark_towers).append(new_tower)
	%Towers.add_child(new_tower)
	new_tower.appear()
	new_tower.set_target_player(player)
	new_tower.set_allowed_players(dark_tethered_players if light else light_tethered_players)
	return new_tower

func spawn_towers():
	for angel in tether_angels:
		angel.disappear()
	for p in light_debuffed_players:
		spawn_tower(true, p)
		if p is OtherPlayer:
			player_move_slow(p, p.position + Vector2(randf_range(-40, 40), randf_range(40, 70)))
		else:
			%Debuff.set_person(true, 4.5)
	for p in dark_debuffed_players:
		spawn_tower(false, p)
		if p is OtherPlayer:
			player_move_slow(p, p.position + Vector2(randf_range(-40, 40), randf_range(40, 70)))
		else:
			%Debuff.set_person(false, 4.5)
	%MainCamera.screen_shake(0.5, 0.5)
	await seconds(0.1)
	for t in %Towers.get_children():
		if t.hitting_player():
			lose_condition("You were hit by a tower", false)
		if t.hitting_other_player():
			lose_condition("You hit someone with your tower", true)

func player_move_slow(player: OtherPlayer, pos: Vector2):
	await seconds(randf_range(0.1, 0.5))
	player.set_target(pos)

func player_move_to_tower(player: OtherPlayer, light: bool):
	await seconds(randf_range(0.2, 0.7))
	var my_towers := light_towers if light else dark_towers
	var t1dist := (my_towers[0].global_position - player.global_position).length_squared()
	var t2dist := (my_towers[1].global_position - player.global_position).length_squared()
	if t1dist < t2dist:
		player.set_target(my_towers[0].position)
	else:
		player.set_target(my_towers[1].position)

func players_move_to_tower():
	for p in dark_tethered_players:
		if p is OtherPlayer:
			player_move_to_tower(p, true)
	for p in light_tethered_players:
		if p is OtherPlayer:
			player_move_to_tower(p, false)

func towers_disappear():
	for t in light_towers:
		t.disappear()
	for t in dark_towers:
		t.disappear()
	for p in light_tethered_players:
		if p is PlayerCharacter:
			%Debuff.set_person(false, 6)
	for p in dark_tethered_players:
		if p is PlayerCharacter:
			%Debuff.set_person(false, 6)
	%MainCamera.screen_shake(0.5, 1)
	for t in %Towers.get_children():
		if t.not_soaked():
			lose_condition("You did not soak your tower", false)
		if t.hitting_player_2():
			lose_condition("You were hit by a tower", false)

func player_move_out_of_cleave(player: OtherPlayer):
	await seconds(randf_range(0.2, 0.6))
	if player.is_in_cleave_area():
		if player.can_move_left():
			player.set_target(player.global_position - Vector2(128, 0))
		else:
			player.set_target(player.global_position + Vector2(128, 0))

func players_move_out_of_cleave():
	for p in players:
		if p is OtherPlayer:
			player_move_out_of_cleave(p)

func shoot_cleaves():
	for angel in cleave_angels:
		angel.shoot_laser()
		if angel.hitting_player():
			lose_condition("You were hit by a cleave", false)

func cleaves_disappear():
	for angel in cleave_angels:
		angel.disappear()

func lose_condition(message: String, impostor: bool):
	%MainCamera.screen_shake(1, 1)
	%AthenaScare/Label.text = message
	%AudioLose.play()
	get_tree().paused = true
	var tween := get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(2)
	if impostor: tween.tween_callback(func(): %AudioImpostor.play())
	tween.tween_property(%AthenaScare, "modulate", Color.WHITE, 1.5)

func restart():
	for tween in get_tree().get_processed_tweens():
		tween.kill()
	get_tree().reload_current_scene()

func _on_sprint_button_pressed():
	%PlayerCharacter.speed *= 1.4
	%Buff.set_sprint(10)
	await seconds(10)
	%PlayerCharacter.speed /= 1.4

func _on_gcd_button_pressed():
	pressed_gcds += 1
	%GCDCount.text = str(pressed_gcds) + " / " + str(gcd_count)

func _on_gcd_timer_timeout():
	gcd_count += 1
	%GCDCount.text = str(pressed_gcds) + " / " + str(gcd_count)

