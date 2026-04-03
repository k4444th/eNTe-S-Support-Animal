extends AnimatedSprite2D

var moving := false
var baseEyePos := Vector2(12, -14)
var baseBeakPos := Vector2(0, 0)
var speechBubblePos := Vector2(32, -107)
var maxSpeechBubblePos := Vector2(32, -107)
var maxSpeechBubbleSize := Vector2(200, 100)
var initialSpeechBubblePosY := speechBubblePos.y
var moveTime := 0.5
var moveDistance := 100
var talkCount := 3
var talking := false
var currentTalkCount := talkCount

@onready var eyeNode := $Eye
@onready var pupilNode := $Eye/Pupil
@onready var tailNode := $Tail
@onready var beakNode := $Beak
@onready var speechBubbleNode := $SpeechBubble
@onready var blinkTimer := $BlinkTimer
@onready var speechBubbleTimer := $SpeechBubbleTimer

signal talkEnd()

func _ready() -> void:
	play("idle" + Globals.duckColor)
	tailNode.play("idle" + Globals.duckColor)
	eyeNode.play("open")
	beakNode.play("close" + Globals.beakColor)
	speechBubbleNode.visible = false
	initialSpeechBubblePosY = speechBubbleNode.position.y
	
func _process(_delta: float) -> void:
	followMouse()

func followMouse():
	var mousePos = get_local_mouse_position()
	var pupilsPos = mousePos
	pupilsPos -= Vector2(12.5, -15)
	
	pupilsPos.x = clamp(pupilsPos.x, -1, 1)
	pupilsPos.y = clamp(pupilsPos.y, -1, 1)
	
	pupilNode.position = pupilsPos

func talk(doubleCLick: bool):
	if talking:
		speechBubbleNode.visible = false
		beakNode.play("close" + Globals.beakColor)
		talking = false
		talkEnd.emit()
	else:
		if doubleCLick:
			speechBubbleNode.textNode.text = Globals.supportHotlineText
		else:
			speechBubbleNode.textNode.text = Globals.selectedQuotes[randi() % len(Globals.selectedQuotes)]
		
		speechBubbleNode.size = maxSpeechBubbleSize
		
		var font = speechBubbleNode.textNode.get_theme_font("font")

		var textSize = font.get_multiline_string_size(
			speechBubbleNode.textNode.text,
			HORIZONTAL_ALIGNMENT_LEFT,
			maxSpeechBubbleSize.x - 48,
			speechBubbleNode.textNode.get_theme_font_size("font_size")
		)
		
		speechBubbleNode.size = textSize + Vector2(24, 32)
		speechBubbleNode.size = speechBubbleNode.size.clamp(Vector2.ZERO, maxSpeechBubbleSize)
		
		speechBubblePos.y = maxSpeechBubblePos.y + maxSpeechBubbleSize.y - speechBubbleNode.size.y
		initialSpeechBubblePosY = speechBubblePos.y
		
		speechBubblePos.y = initialSpeechBubblePosY - frame if frame <= 4 else -8 + initialSpeechBubblePosY + frame
		speechBubbleNode.position = speechBubblePos
		
		speechBubbleTimer.start()
		speechBubbleNode.visible = true
		beakNode.play("talk" + Globals.beakColor)
		talking = true

func _on_frame_changed() -> void:
	baseEyePos.y = -14 - frame if frame <= 4 else -22 + frame
	baseBeakPos.y = - frame if frame <= 4 else -8 + frame
	speechBubblePos.y = initialSpeechBubblePosY - frame if frame <= 4 else -8 + initialSpeechBubblePosY + frame
	
	eyeNode.position = baseEyePos
	beakNode.position = baseBeakPos
	speechBubbleNode.position.y = speechBubblePos.y

func _on_blink_timer_timeout() -> void:
	pupilNode.visible = false
	eyeNode.play("blink")

func _on_eye_animation_finished() -> void:
	if eyeNode.animation == "blink":
		eyeNode.play("open")
		pupilNode.visible = true
		blinkTimer.start()

func _on_beak_animation_finished() -> void:
	if beakNode.animation == "talk" + Globals.beakColor:
		beakNode.play("close" + Globals.beakColor)
		if currentTalkCount > 0:
			var tempTimer = get_tree().create_timer(1 / beakNode.sprite_frames.get_animation_speed("talk" + Globals.beakColor))
			await  tempTimer.timeout
			beakNode.play("talk" + Globals.beakColor)
			currentTalkCount -= 1
		else:
			currentTalkCount = talkCount
