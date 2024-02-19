class_name OtherPlayer extends Area2D

@export var speed: float = 50
@export var role_icons: Array[Texture2D]

var target_position: Vector2
var my_role: int

# Called when the node enters the scene tree for the first time.
func _ready():
	target_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var move_vector := target_position - global_position
	if move_vector.length() > 5:
		position += speed * delta * move_vector.normalized()

func set_target(pos: Vector2):
	target_position = pos

func set_role(role: int):
	%Sprite2D.texture = role_icons[role]
	my_role = role

func get_role() -> int:
	return my_role

func is_in_cleave_area() -> bool:
	for area in get_overlapping_areas():
		if area.is_in_group("BigLaser"):
			return true
	return false

func can_move_left() -> bool:
	return !%RayCastLeft.is_colliding()
