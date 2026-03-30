extends AnimatedSprite2D

var moving := false
var baseEyePos := Vector2(3, -3.5)
var moveTime := 0.5
var moveDistance := 100

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

func move(right: bool):
	if moving:
		return
	
	var window = get_window()
	var usableRect := DisplayServer.screen_get_usable_rect()

	if window.position.x + window.size.x + moveDistance > usableRect.end.x:
		right = false
	elif window.position.x - moveDistance < usableRect.position.x:
		right = true
	
	var moveVector := Vector2i.RIGHT if right else Vector2i.LEFT
	
	var positionTween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	positionTween.tween_property(window, "position", window.position + moveVector * moveDistance, 0.5)

func _on_frame_changed() -> void:
	if frame == 0:
		baseEyePos.y = -3.5
	elif frame == 1:
		baseEyePos.y = -4.5
	
	eyeNode.position = baseEyePos
