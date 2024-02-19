extends TextureRect

@export var light_tower_texture: Texture2D
@export var dark_tower_texture: Texture2D
@export var light_person_texture: Texture2D
@export var dark_person_texture: Texture2D
@export var sprint_texture: Texture2D

func _ready():
	if OS.has_feature("web_android") || OS.has_feature("web_ios"):
		scale *= 2

func _process(_delta):
	if %Timer.time_left >= 1:
		%Label.text = str(floori(%Timer.time_left))
	else:
		%Label.visible = false

func set_tower(light: bool, time: float):
	visible = true
	texture = light_tower_texture if light else dark_tower_texture
	set_timer(time)
	
func set_person(light: bool, time: float):
	visible = true
	texture = light_person_texture if light else dark_person_texture
	set_timer(time)

func set_sprint(time: float):
	visible = true
	texture = sprint_texture
	set_timer(time)

func set_timer(duration: float):
	%Timer.start(duration)
	%Label.visible = true
