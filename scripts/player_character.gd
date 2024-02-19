class_name PlayerCharacter extends CharacterBody2D

@export var speed: float = 1
@export var role_icons: Array[Texture2D]

var playing: bool = false
var my_role: int

func _physics_process(_delta):
	if playing:
		var input := Vector2(0, 0)
		input.x -= Input.get_action_strength("left")
		input.x += Input.get_action_strength("right")
		input.y -= Input.get_action_strength("up")
		input.y += Input.get_action_strength("down")
		velocity = speed * input.normalized()
		move_and_slide()

func set_role(role: int):
	%Sprite2D.texture = role_icons[role]
	playing = true
	my_role = role

func get_role() -> int:
	return my_role
