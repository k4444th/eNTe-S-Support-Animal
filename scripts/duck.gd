extends AnimatedSprite2D

var baseEyePos := Vector2(3, -3.5)

@onready var eyeNode := $Eye
@onready var pupilNode := $Eye/Pupil

func _ready() -> void:
	animation = "idle" + Globals.duckColor
	play()

func _process(_delta: float) -> void:
	followMouse()

func followMouse():
	var mousePos = get_global_mouse_position()
	var pupilsPos = mousePos
	pupilsPos.y += 3.5
	
	pupilsPos.x = clamp(pupilsPos.x, -0.25, 0.25)
	pupilsPos.y = clamp(pupilsPos.y, -0.25, 0.25)
	
	pupilNode.position = pupilsPos

func _on_frame_changed() -> void:
	if frame == 0:
		baseEyePos.y = -3.5
	elif frame == 1:
		baseEyePos.y = -4.5
	
	eyeNode.position = baseEyePos
