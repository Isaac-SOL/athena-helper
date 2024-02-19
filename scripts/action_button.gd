extends TextureRect

signal pressed

@export var is_gcd: bool = true
@export var listen_to_input: StringName

var pressable: bool = true
@onready var gcd: float = 2.5 if is_gcd else 0.0
var press_anim_tween: Tween
var event_was_pressed: bool = false
var frozen: bool = true
var queue_press: bool = false

func _process(delta):
	if !frozen && gcd > 0:
		gcd -= delta
		%GCDTimer.value = (gcd / 2.5) * 100
		if gcd <= 0 && queue_press:
			press(false)
	if listen_to_input != "" && Input.is_action_just_pressed(listen_to_input):
		press()

func press_anim():
	%PressAnim.visible = true
	if press_anim_tween:
		press_anim_tween.kill()
	press_anim_tween = get_tree().create_tween()
	for i in range(0, %PressAnim.hframes * %PressAnim.vframes):
		press_anim_tween.tween_callback(func(): %PressAnim.frame = i)
		press_anim_tween.tween_interval(0.05)
	press_anim_tween.tween_callback(func(): %PressAnim.visible = false)
	press_anim_tween.tween_callback(func(): %PressAnim.frame = 0)

func press(anim: bool = true):
	if !frozen:
		if anim: press_anim()
		if pressable:
			if gcd <= 0 || !is_gcd:
				emit_signal("pressed")
				queue_press = false
				if is_gcd: gcd = 2.5
			elif is_gcd && gcd <= 0.5:
				queue_press = true
		if pressable && !is_gcd:
			set_pressed_final()

func set_pressable(p: bool):
	pressable = p
	%CantPress.visible = !pressable
	modulate = Color.WHITE if pressable else Color(0.6, 0.6, 0.6)

func set_pressed_final():
	pressable = false
	modulate = Color(0.6, 0.6, 0.6)

func unfreeze():
	frozen = false

func _on_gui_input(event):
	if event is InputEventMouseButton && event.button_index == 1:
		if !event_was_pressed && event.pressed:
			event_was_pressed = true
			press()
		elif event_was_pressed:
			event_was_pressed = false
