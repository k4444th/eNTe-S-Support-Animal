extends Node2D

var direction := Vector2.RIGHT
var clickPending := false
var clickPosition := Vector2.ZERO

@onready var clickTimer := $ClickTimer
@onready var duckNode := $Duck

func _ready() -> void:
	var window = get_window()
	
	get_viewport().transparent_bg = true
	window.transparent = true 
	window.borderless = true
	window.always_on_top = true
	window.unresizable = true
	
	var usableRect := DisplayServer.screen_get_usable_rect()
	var yPos = usableRect.end.y - window.size.y
	
	window.position = Vector2i(0, yPos)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if clickTimer.time_left > 0:
			clickTimer.stop()
			clickPending = false
			
			print("Du hast Probleme?\nWir haben die Lösung!\nIT-Support Hotline: 0664 / 123456789\n")
		
		else:
			clickPending = true
			clickPosition = event.position
			clickTimer.start()

func _on_click_timer_timeout() -> void:
	if clickPending:
		clickPending = false
	
	duckNode.move(clickPosition.x < get_window().size.x / 2.0)
