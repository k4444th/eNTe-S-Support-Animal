extends AnimatedSprite2D

var moving := false
var baseEyePos := Vector2(12, -14)
var moveTime := 0.5
var moveDistance := 100

@onready var eyeNode := $Eye
@onready var pupilNode := $Eye/Pupil
@onready var tailNode := $Tail
@onready var blinkTimer := $BlinkTimer

func _ready() -> void:
	play("idle" + Globals.duckColor)
	tailNode.play("idle" + Globals.duckColor)
	eyeNode.play("open")

func _process(_delta: float) -> void:
	followMouse()

func followMouse():
	var mousePos = get_global_mouse_position()
	var pupilsPos = mousePos
	pupilsPos += Vector2(-12, 15)
	
	pupilsPos.x = clamp(pupilsPos.x, -1, 1)
	pupilsPos.y = clamp(pupilsPos.y, -1, 1)
	
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
	baseEyePos.y = -14 - frame if frame <= 4 else -18 + (frame - 4)
	
	eyeNode.position = baseEyePos

func _on_blink_timer_timeout() -> void:
	pupilNode.visible = false
	eyeNode.play("blink")

func _on_eye_animation_finished() -> void:
	if eyeNode.animation == "blink":
		eyeNode.play("open")
		pupilNode.visible = true
		blinkTimer.start()
