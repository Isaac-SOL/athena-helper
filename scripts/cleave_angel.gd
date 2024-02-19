class_name CleaveAngel extends Node2D

@export var angel_sprite: Texture2D
@export var speed: float = 500

var target_position: Vector2

func _ready():
	target_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var move_vector := target_position - global_position
	if move_vector.length() > 5:
		position += speed * delta * move_vector.normalized()

func set_target_position(pos: Vector2):
	target_position = pos

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
	%LaserSprite.visible = true
	var base_scale: Vector2 = %LaserSprite.scale
	var tween := get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(%LaserSprite, "scale", Vector2(8, base_scale.y), 0.15).set_trans(Tween.TRANS_QUAD)
	tween.tween_interval(0.5)
	tween.tween_property(%LaserSprite, "scale", Vector2(0, base_scale.y), 0.5).set_trans(Tween.TRANS_CIRC)
	tween.parallel().tween_property(%LaserSprite, "modulate", Color.TRANSPARENT, 1)

func disappear():
	await get_tree().create_timer(1).timeout
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_QUART)
	tween.tween_property(self, "scale", scale * Vector2(0, 2), 0.4)
	tween.parallel().tween_property(self, "position", position + Vector2(0, -64), 0.4)
	tween.tween_callback(queue_free)

func hitting_player() -> bool:
	for body in %LaserArea.get_overlapping_bodies():
		if body is PlayerCharacter:
			return true
	return false
