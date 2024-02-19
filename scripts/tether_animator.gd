extends Path2D

@export var arrow: PackedScene

func _on_generator_timeout():
	var arrow1 = arrow.instantiate()
	var arrow2 = arrow.instantiate()
	arrow1.get_node("Sprite2D").scale = Vector2.ZERO
	arrow2.get_node("Sprite2D").scale = Vector2.ZERO
	add_child(arrow1)
	add_child(arrow2)
	arrow1.start(1)
	arrow2.start(-1)
