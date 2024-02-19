extends PathFollow2D

@export var speed: float = 150
@export var attack: float = 10

var my_direction: int = 1
var started: bool = false

func scale_fuction(ratio: float) -> float:
	var y: float = (ratio - 0.5) * 2
	y = (-pow((y + (-my_direction * 0.45)) * 2.5, 2) + 1) * attack
	return 1.0 / (1.0 + exp(-y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if started:
		progress += delta * speed * my_direction
		$Sprite2D.scale = Vector2.ONE * scale_fuction(progress_ratio) * 2
		if progress_ratio > 1 || progress_ratio < 0:
			queue_free()

func start(direction: int):
	progress_ratio = 0.5
	my_direction = direction
	if my_direction > 0:
		$Sprite2D.flip_h = true
	started = true
