extends AnimatedSprite2D

@onready var colorNode := $Color
@onready var backgroundNode := $Backgroud

signal parachuteClosed()

func _ready() -> void:
	visible = false
	colorNode.visible = false
	backgroundNode.visible = false

func open():
	colorNode.play(Globals.parachuteColor)
	backgroundNode.play(Globals.parachuteBackground)
	visible = true
	play("opening")

func _on_animation_finished() -> void:
	if animation == "opening":
		play("open")
		colorNode.visible = true
		backgroundNode.visible = true
	elif animation == "closing":
		visible = false
		parachuteClosed.emit()

func close():
	play("closing")
	colorNode.visible = false
	backgroundNode.visible = false
