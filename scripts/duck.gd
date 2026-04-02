extends AnimatedSprite2D

var moving := false
var baseEyePos := Vector2(12, -14)
var baseBeakPos := Vector2(0, 0)
var moveTime := 0.5
var moveDistance := 100
var talkCount := 3
var currentTalkCount := talkCount

@onready var eyeNode := $Eye
@onready var pupilNode := $Eye/Pupil
@onready var tailNode := $Tail
@onready var beakNode := $Beak
@onready var blinkTimer := $BlinkTimer

signal duckFrameChanged()

func _ready() -> void:
	play("idle" + Globals.duckColor)
	tailNode.play("idle" + Globals.duckColor)
	eyeNode.play("open")
	beakNode.play("close")

func _process(_delta: float) -> void:
	followMouse()

func followMouse():
	var mousePos = get_global_mouse_position()
	var pupilsPos = mousePos
	pupilsPos += Vector2(-12, 15)
	
	pupilsPos.x = clamp(pupilsPos.x, -1, 1)
	pupilsPos.y = clamp(pupilsPos.y, -1, 1)
	
	pupilNode.position = pupilsPos

func talk():
	beakNode.play("talk")

func _on_frame_changed() -> void:
	baseEyePos.y = -14 - frame if frame <= 4 else -22 + frame
	baseBeakPos.y = -frame if frame <= 4 else -8 +frame
	
	eyeNode.position = baseEyePos
	beakNode.position = baseBeakPos
	
	duckFrameChanged.emit()

func _on_blink_timer_timeout() -> void:
	pupilNode.visible = false
	eyeNode.play("blink")

func _on_eye_animation_finished() -> void:
	if eyeNode.animation == "blink":
		eyeNode.play("open")
		pupilNode.visible = true
		blinkTimer.start()

func _on_beak_animation_finished() -> void:
	if beakNode.animation == "talk":
		beakNode.play("close")
		if currentTalkCount > 0:
			var tempTimer = get_tree().create_timer(1 / beakNode.sprite_frames.get_animation_speed("talk"))
			await  tempTimer.timeout
			beakNode.play("talk")
			currentTalkCount -= 1
		else:
			currentTalkCount = talkCount
