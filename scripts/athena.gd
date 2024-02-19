extends Area2D

func squish_squash():
	var base_scale = %MainSprite.scale
	var tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(%MainSprite, "scale", base_scale * Vector2(0.8, 1.2), 0.1)
	tween.tween_property(%MainSprite, "scale", base_scale * Vector2(1.1, 1.1), 0.1)
	tween.tween_property(%MainSprite, "scale", base_scale * Vector2(1.2, 0.8), 0.1)
	tween.tween_property(%MainSprite, "scale", base_scale, 0.2)

func is_on_player():
	for body in get_overlapping_bodies():
		if body is PlayerCharacter:
			return true
	return false
