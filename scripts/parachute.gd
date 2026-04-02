extends AnimatedSprite2D

signal parachuteClosed()

func _ready() -> void:
	visible = false

func open():
	visible = true
	play("opening")

func _on_animation_finished() -> void:
	if animation == "opening":
		play("open")
	elif animation == "closing":
		visible = false
		parachuteClosed.emit()

func close():
	play("closing")
