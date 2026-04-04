extends Node2D

var open := false
var settingsPosition: Vector2

@onready var backgroundNode := $Background
@onready var sizeSliderNode := $Background/Margin/VBox/HBox3/SizeSlider
@onready var duckColorMenuNode := $Background/Margin/VBox/HBox4/DuckColorMenu
@onready var parachuteColorMenuNode := $Background/Margin/VBox/HBox5/ParachuteColorMenu
@onready var parachuteBackgroundcolorMenuNode := $Background/Margin/VBox/HBox6/ParachuteBackgroundColorMenu

signal closeSettings()
signal settingsChanged()

func _ready() -> void:
	var usableRect := DisplayServer.screen_get_usable_rect()
	
	sizeSliderNode.value = Globals.cameraZoom.x
	sizeSliderNode.max_value = usableRect.size.y / (backgroundNode.size.y + 56)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var usableRect := DisplayServer.screen_get_usable_rect()
		var settingsRect = Rect2(position + Vector2(usableRect.size) / Globals.cameraZoom / 2, backgroundNode.size)
		
		if visible and not settingsRect.has_point(event.position  / Globals.cameraZoom):
			hideSettings()

func showSettings(clickPosition: Vector2):
	settingsPosition = clickPosition
	
	var usableRect := DisplayServer.screen_get_usable_rect()
	var xOffset = 0 if clickPosition.x / Globals.cameraZoom.x < usableRect.size.x / Globals.cameraZoom.x - backgroundNode.size.x else backgroundNode.size.x
	
	position = Vector2(-usableRect.size) / Globals.cameraZoom / 2 + settingsPosition / Globals.cameraZoom - Vector2(xOffset, backgroundNode.size.y)
	visible = true

func hideSettings():
	visible = false
	closeSettings.emit()

func _on_close_button_pressed() -> void:
	hideSettings()

func _on_size_slider_drag_ended(_value_changed: bool) -> void:
	Globals.cameraZoom = Vector2(sizeSliderNode.value, sizeSliderNode.value)
	
	var usableRect := DisplayServer.screen_get_usable_rect()
	var xOffset = 0 if settingsPosition.x / Globals.cameraZoom.x < usableRect.size.x / Globals.cameraZoom.x - backgroundNode.size.x else backgroundNode.size.x
	
	position = Vector2(-usableRect.size) / Globals.cameraZoom / 2 + settingsPosition / Globals.cameraZoom - Vector2(xOffset, backgroundNode.size.y)
	
	settingsChanged.emit()

func _on_duck_color_button_pressed() -> void:
	duckColorMenuNode.popup()

func _on_duck_color_menu_id_pressed(id: int) -> void:
	Globals.colorIndex = id
	settingsChanged.emit()

func _on_parachute_color_button_pressed() -> void:
	parachuteColorMenuNode.popup()

func _on_parachute_color_menu_id_pressed(id: int) -> void:
	Globals.parachuteColorIndex = id
	settingsChanged.emit()

func _on_parachute_background_color_button_pressed() -> void:
	parachuteBackgroundcolorMenuNode.popup()

func _on_parachute_background_color_menu_id_pressed(id: int) -> void:
	Globals.parachuteBackgroundIndex = id
	settingsChanged.emit()
