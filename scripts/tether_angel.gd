class_name TetherAngel extends Node2D

@export var angel_sprite: Texture2D
@export var light_color: Color
@export var dark_color: Color
@export var light_laser: Texture2D
@export var dark_laser: Texture2D
@export var speed: float = 200

var target_position: Vector2
var target_player: Node2D
var light: bool
var path_mod_tween: Tween
var last_distance_ok: bool = false

func _ready():
	target_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target_player:
		update_tether()
		%Laser.look_at(target_player.global_position)
	var move_vector := target_position - global_position
	if move_vector.length() > 5:
		position += speed * delta * move_vector.normalized()

func update_tether():
	%Line2D.set_point_position(1, target_player.global_position - global_position)
	%Path2D.curve.set_point_position(1, target_player.global_position - global_position)
	%Path2D/MiddlePathFollow.progress_ratio = 0.5
	if (target_player.global_position - global_position).length() > 430:
		if !last_distance_ok:
			hide_arrows()
			last_distance_ok = true
	else:
		if last_distance_ok:
			show_arrows()
			last_distance_ok = false

func set_target_position(pos: Vector2):
	target_position = pos

func line_appear_anim(reverse: bool):
	var alpha: float = 1 if reverse else 0
	while (alpha > 0) if reverse else (alpha < 1):
		alpha += 0.08 * (-1 if reverse else 1)
		%Line2D.modulate = Color(1, 1, 1, alpha)
		%Path2D.modulate = Color(%Path2D.modulate, alpha)
		await get_tree().process_frame
	if reverse:
		%Line2D.visible = false
		%Path2D.visible = false
		target_player = null

func start_targeting(player: Node2D, is_light: bool):
	target_player = player
	light = is_light
	%Line2D.default_color = light_color if light else dark_color
	%Line2D.visible = true
	%Path2D.modulate = %Line2D.default_color
	%Path2D.visible = true
	update_tether()
	line_appear_anim(false)

func stop_targeting():
	line_appear_anim(true)

func show_arrows():
	var trans = light_color if light else dark_color
	if path_mod_tween:
		path_mod_tween.kill()
	path_mod_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	path_mod_tween.tween_property(%Path2D, "modulate", trans, 0.5)

func hide_arrows():
	var trans = light_color if light else dark_color
	trans.a = 0
	if path_mod_tween:
		path_mod_tween.kill()
	path_mod_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	path_mod_tween.tween_property(%Path2D, "modulate", trans, 0.5)

func appear():
	scale = Vector2.ZERO
	visible = true
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)

func transform():
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0, 1), 0.5).set_trans(Tween.TRANS_CIRC)
	tween.tween_callback(func(): %Sprite2D.texture = angel_sprite)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_QUAD)

func shoot_laser():
	%LaserSprite.texture = light_laser if light else dark_laser
	%LaserSprite.visible = true
	var base_scale: Vector2 = %LaserSprite.scale
	var tween := get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(%LaserSprite, "scale", Vector2(2, base_scale.y), 0.15).set_trans(Tween.TRANS_QUAD)
	tween.tween_interval(0.5)
	tween.tween_property(%LaserSprite, "scale", Vector2(0, base_scale.y), 0.5).set_trans(Tween.TRANS_CIRC)
	tween.parallel().tween_property(%LaserSprite, "modulate", Color.TRANSPARENT, 1)

func disappear():
	await get_tree().create_timer(1).timeout
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_QUART)
	tween.tween_property(self, "scale", scale * Vector2(0, 2), 0.4)
	tween.parallel().tween_property(self, "position", position + Vector2(0, -64), 0.4)
	tween.tween_callback(queue_free)

func distance_ok() -> bool:
	return (target_player.global_position - global_position).length() > 430

func hitting_player() -> bool:
	for body in %LaserArea.get_overlapping_bodies():
		if body != target_player:
			return true
	return false

func hitting_other_player() -> bool:
	for area in %LaserArea.get_overlapping_areas():
		if area != target_player:
			return true
	return false
