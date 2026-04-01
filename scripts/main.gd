extends Node2D

var direction := Vector2.RIGHT
var clickPending := false
var clickPosition := Vector2.ZERO
var hasFirstClick := false
var isDragging := false
var dragStartPosition := Vector2.ZERO
var lastMousePosition := Vector2.ZERO
var dragThreshold := 5.0
var dragOffset := Vector2i.ZERO


@onready var clickTimer := $ClickTimer
@onready var duckNode := $Duck
@onready var cameraNode := $Camera

func _ready() -> void:
	var window = get_window()
	
	get_viewport().transparent_bg = true
	window.transparent = true 
	window.borderless = true
	window.always_on_top = true
	window.unresizable = true
	
	window.size = Globals.duckSize * Globals.cameraZoom * 4
	cameraNode.zoom = Globals.cameraZoom
	
	var usableRect := DisplayServer.screen_get_usable_rect()
	var yPos = usableRect.end.y - window.size.y
	
	window.position = Vector2i(0, yPos)

func _process(_delta: float) -> void:
	if isDragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		stopDrag()
		isDragging = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		if event.pressed:
			clickPosition = event.position
			dragStartPosition = event.position
			lastMousePosition = event.position
			
			isDragging = false
			
			if hasFirstClick and clickTimer.time_left > 0:
				clickTimer.stop()
				hasFirstClick = false
				clickPending = false
				
				print("Du hast Probleme?\nWir haben die Lösung!\nIT-Support Hotline: 0664 / 123456789\n")
			
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

func startDrag():
	var window = get_window()
	dragOffset = window.position - Vector2i(DisplayServer.mouse_get_position())

func drag():
	var window = get_window()
	var mouseGlobalPos = DisplayServer.mouse_get_position()
	window.position = mouseGlobalPos + dragOffset

func stopDrag():
	var window = get_window()
	var usableRect := DisplayServer.screen_get_usable_rect()
	var yPos = usableRect.end.y - window.size.y
	
	var positionTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	positionTween.tween_property(window, "position", Vector2i(window.position.x, yPos), pow(abs(window.position.y - yPos), 0.7) * 0.005)

func _on_click_timer_timeout() -> void:
	if clickPending:
		hasFirstClick = false
		clickPending = false
	
	duckNode.move(clickPosition.x < get_window().size.x / 2.0)
