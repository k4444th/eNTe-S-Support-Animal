extends Node2D

var open := false

@onready var backgroundNode := $Background

signal closeSettings()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var usableRect := DisplayServer.screen_get_usable_rect()
		var settingsRect = Rect2(position + Vector2(usableRect.size) / Globals.cameraZoom / 2, backgroundNode.size)
		
		if visible and not settingsRect.has_point(event.position  / Globals.cameraZoom):
			hideSettings()
		else:
			print("Click in Settings")
			

func showSettings(clickPosition: Vector2):
	var usableRect := DisplayServer.screen_get_usable_rect()
	var xOffset = 0 if clickPosition.x / Globals.cameraZoom.x < usableRect.size.x / Globals.cameraZoom.x - backgroundNode.size.x else backgroundNode.size.x
	
	position = Vector2(-usableRect.size) / Globals.cameraZoom / 2 + clickPosition / Globals.cameraZoom - Vector2(xOffset, backgroundNode.size.y)
	visible = true

func hideSettings():
	visible = false
	closeSettings.emit()

func _on_close_button_pressed() -> void:
	hideSettings()
