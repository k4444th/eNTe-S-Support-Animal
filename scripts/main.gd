extends Node2D

var direction := Vector2.RIGHT
var clickPending := false
var clickPosition := Vector2.ZERO
var hasFirstClick := false
var isDragging := false
var isFlying := false
var hasStartedDrag := false
var dragStartPosition := Vector2.ZERO
var lastMousePosition := Vector2.ZERO
var dragThreshold := 5.0
var dragOffset := Vector2i.ZERO
var settingsOpen := false
var settingsJustClosed := false
var totalPolygon := PackedVector2Array()

@onready var clickTimer := $ClickTimer
@onready var spriteNode := $Sprite
@onready var settingsNode := $Settings
@onready var cameraNode := $Camera
@onready var settingsDelayTimer := $SettingsDelayTimer


func _ready() -> void:
	spriteNode.parachuteNode.parachuteClosed.connect(parachuteClosed)
	spriteNode.duckNode.talkEnd.connect(talkEnd)
	settingsNode.closeSettings.connect(closeSettings)
	
	var window = get_window()
	
	get_viewport().transparent_bg = true
	window.transparent = true 
	window.borderless = true
	window.always_on_top = true
	window.unresizable = true
	
	var usableRect := DisplayServer.screen_get_usable_rect()
	
	cameraNode.zoom = Globals.cameraZoom
	window.size = usableRect.size
	window.position = usableRect.position
	
	spriteNode.position = Vector2i(floor(-usableRect.size.x / (Globals.cameraZoom.x * 2) + spriteNode.duckNode.sprite_frames.get_frame_texture("idleDarkBlue", 4).get_width() / 2), floor(usableRect.size.y / (Globals.cameraZoom.y * 2) - spriteNode.duckNode.sprite_frames.get_frame_texture("idleDarkBlue", 4).get_height() / 2))
	
	setMousePassthroughArea(spriteNode.clickableAreaNode)
	
func _process(_delta: float) -> void:
	if isDragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		stopDrag()
		isDragging = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not settingsJustClosed and not settingsOpen:
		if event.pressed:
			settingsNode.hideSettings()
			settingsOpen = false
			
			clickPosition = event.position
			dragStartPosition = event.position
			lastMousePosition = event.position
			
			isDragging = false
			
			if hasFirstClick and clickTimer.time_left > 0:
				clickTimer.stop()
				hasFirstClick = false
				clickPending = false
				
				spriteNode.duckNode.talk(true)
				setMousePassthroughArea(spriteNode.visibleSpeechBubbleAreaNode)
			
			else:
				hasFirstClick = true
				clickPending = true
				clickTimer.start()
		else:
			if isDragging:
				stopDrag()
			
			isDragging = false

	elif event is InputEventMouseMotion:
		var mousePos = event.position
		
		if clickPending and not isDragging:
			if mousePos.distance_to(dragStartPosition) > dragThreshold:
				isDragging = true
				clickPending = false
				hasFirstClick = false
				clickTimer.stop()
				startDrag()
		
		if isDragging:
			lastMousePosition = mousePos
			drag()
	
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not settingsOpen:
		if event.pressed:
			settingsNode.showSettings(event.position)
			settingsOpen = true
			
			if spriteNode.duckNode.talking:
				spriteNode.duckNode.speechBubbleNode.visible = false
				spriteNode.duckNode.beakNode.play("close" + Globals.beakColor)
				spriteNode.duckNode.talking = false
				talkEnd()
			
			var usableRect := DisplayServer.screen_get_usable_rect()
	
			var wholeScreenArea := Polygon2D.new()
			wholeScreenArea.polygons = PackedVector2Array([
				usableRect.position,
				Vector2(usableRect.position.x, usableRect.size.y),
				usableRect.size,
				Vector2(usableRect.size.x, usableRect.position.y)
			])
			
			setMousePassthroughArea(wholeScreenArea)

func setMousePassthroughArea(area: Polygon2D):
	var clickableArea = PackedVector2Array()
	var usableRect = DisplayServer.screen_get_usable_rect()
	
	for p in area.polygon:
		clickableArea.append(Globals.cameraZoom * p + Vector2(spriteNode.position) * Globals.cameraZoom + Vector2(usableRect.size) / 2)

	DisplayServer.window_set_mouse_passthrough(clickableArea)

func parachuteClosed():
	setMousePassthroughArea(spriteNode.clickableAreaNode)
	isFlying = false

func closeSettings():
	settingsOpen = false
	settingsJustClosed = true
	settingsDelayTimer.start()
	setMousePassthroughArea(spriteNode.clickableAreaNode)

func startDrag():
	if isFlying:
		return
	
	hasStartedDrag = true
	spriteNode.duckNode.beakNode.play("close" + Globals.beakColor)
	spriteNode.duckNode.talking = false
	spriteNode.duckNode.speechBubbleNode.visible = false
	spriteNode.duckNode.talkEnd.emit()

func drag():
	if isFlying or not hasStartedDrag:
		return
	
	spriteNode.position = get_local_mouse_position()
	
	var usableRect := DisplayServer.screen_get_usable_rect()
	
	var wholeScreenArea := Polygon2D.new()
	wholeScreenArea.polygons = PackedVector2Array([
		usableRect.position,
		Vector2(usableRect.position.x, usableRect.size.y),
		usableRect.size,
		Vector2(usableRect.size.x, usableRect.position.y)
	])
	
	setMousePassthroughArea(wholeScreenArea)

func stopDrag():
	if isFlying:
		return
	
	var window = get_window()
	var yPos = floor(window.size.y / (Globals.cameraZoom.y * 2) - spriteNode.duckNode.sprite_frames.get_frame_texture("idleDarkBlue", 4).get_height() / 2)
	var usableRect := DisplayServer.screen_get_usable_rect()
	
	var flyTime = pow(abs(spriteNode.position.y - yPos), 0.7) * 0.0175
	var parachuteAnimationDuration = (1 / spriteNode.parachuteNode.sprite_frames.get_animation_speed("opening")) * spriteNode.parachuteNode.sprite_frames.get_frame_count("opening")
	
	isFlying = true
	var spriteStartPos = spriteNode.position.y
	
	if flyTime > parachuteAnimationDuration and spriteStartPos < usableRect.size.y / Globals.cameraZoom.y / 2:
		spriteNode.parachuteNode.open()
	
	var positionTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	positionTween.tween_property(spriteNode, "position:y", yPos, flyTime)
	
	await positionTween.finished
	
	if flyTime > parachuteAnimationDuration and spriteStartPos < usableRect.size.y / Globals.cameraZoom.y / 2:
		spriteNode.parachuteNode.close()
	else:
		setMousePassthroughArea(spriteNode.clickableAreaNode)
	
	isFlying = false
	hasStartedDrag = false

func talkEnd():
	setMousePassthroughArea(spriteNode.clickableAreaNode)

func _on_click_timer_timeout() -> void:
	if clickPending:
		hasFirstClick = false
		clickPending = false
	
	if not isFlying:
		spriteNode.duckNode.talk(false)
		setMousePassthroughArea(spriteNode.visibleSpeechBubbleAreaNode)

func _on_settings_delay_timer_timeout() -> void:
	settingsJustClosed = false
