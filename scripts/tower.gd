class_name Tower extends Area2D

@export var light_sprite: Texture2D
@export var dark_sprite: Texture2D
@export var light_effect: Texture2D
@export var dark_effect: Texture2D

var is_light: bool = true
var target_player: Node2D
var allowed_players: Array[Node2D]

func make_light(light: bool):
	%Sprite2D.texture = light_sprite if light else dark_sprite
	is_light = light

func get_light() -> bool:
	return is_light

func appear():
	var tween := get_tree().create_tween()
	tween.tween_property(%Sprite2D, "position", Vector2(0, -19), 0.1).set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(%Sprite2D, "modulate", Color.WHITE, 0.05)

func set_target_player(player: Node2D):
	target_player = player

func set_allowed_players(players: Array[Node2D]):
	allowed_players = players

func disappear():
	%Effect.texture = light_effect if is_light else dark_effect
	%Effect.visible = true
	var tween := get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(%Effect, "scale", Vector2(4, 1), 0.1).set_trans(Tween.TRANS_CIRC)
	tween.parallel().tween_property(%Effect, "position", %Effect.position - Vector2(0, 32), 0.1).set_trans(Tween.TRANS_QUART)
	tween.tween_interval(0.2)
	tween.tween_property(%Sprite2D, "modulate", Color.TRANSPARENT, 0.5).set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(%Effect, "scale", Vector2(4, 0), 0.5).set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(%Effect, "position", %Effect.position, 0.5).set_trans(Tween.TRANS_QUART)
	tween.tween_callback(queue_free)

func not_soaked() -> bool:
	for body in get_overlapping_bodies():
		if body in allowed_players:
			return false
	for area in get_overlapping_areas():
		if area in allowed_players:
			return false
	return true

func hitting_player() -> bool:
	for body in get_overlapping_bodies():
		if body != target_player:
			return true
	return false

func hitting_player_2() -> bool:
	for body in get_overlapping_bodies():
		if body not in allowed_players:
			return true
	return false

func hitting_other_player() -> bool:
	for area in get_overlapping_areas():
		if area != target_player:
			return true
	return false
