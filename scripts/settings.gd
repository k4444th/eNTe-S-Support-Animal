extends Node2D

var open := false
var settingsPosition: Vector2

@onready var backgroundNode := $Background
@onready var nameEditNode := $Background/Margin/VBox/HBox2/NameEdit
@onready var sizeSliderNode := $Background/Margin/VBox/HBox3/SizeSlider
@onready var duckColorButtonNode := $Background/Margin/VBox/HBox4/DuckColorButton
@onready var duckColorMenuNode := $Background/Margin/VBox/HBox4/DuckColorMenu
@onready var parachuteColorButtonNode := $Background/Margin/VBox/HBox5/ParachuteColorButton
@onready var parachuteColorMenuNode := $Background/Margin/VBox/HBox5/ParachuteColorMenu
@onready var parachuteBackgroundcolorButtonNode := $Background/Margin/VBox/HBox6/ParachuteBackgroundColorButton
@onready var parachuteBackgroundcolorMenuNode := $Background/Margin/VBox/HBox6/ParachuteBackgroundColorMenu
@onready var characterButtonNode := $Background/Margin/VBox/HBox7/CharacterButton
@onready var characterMenuNode := $Background/Margin/VBox/HBox7/CharacterMenu

signal closeSettings()
signal settingsChanged()

func _ready() -> void:
	var usableRect := DisplayServer.screen_get_usable_rect()
	
	sizeSliderNode.max_value = usableRect.size.y / (backgroundNode.size.y + 56)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var usableRect := DisplayServer.screen_get_usable_rect()
		var settingsRect = Rect2(position + Vector2(usableRect.size) / Globals.cameraZoom / 2, backgroundNode.size)
		
		if visible and not settingsRect.has_point(event.position  / Globals.cameraZoom):
			hideSettings()

func showSettings(clickPosition: Vector2):
	nameEditNode.text = Globals.duckName
	sizeSliderNode.value = Globals.cameraZoom.x
	duckColorButtonNode.text = duckColorMenuNode.get_item_text(Globals.colorIndex)
	parachuteColorButtonNode.text = parachuteColorMenuNode.get_item_text(Globals.parachuteColorIndex)
	parachuteBackgroundcolorButtonNode.text = parachuteBackgroundcolorMenuNode.get_item_text(Globals.parachuteBackgroundIndex)
	characterButtonNode.text = characterMenuNode.get_item_text(Globals.personalityIndex)
	
	settingsPosition = clickPosition
	
	var usableRect := DisplayServer.screen_get_usable_rect()
	var xOffset = 0 if clickPosition.x / Globals.cameraZoom.x < usableRect.size.x / Globals.cameraZoom.x - backgroundNode.size.x else backgroundNode.size.x
	
	position = Vector2(-usableRect.size) / Globals.cameraZoom / 2 + settingsPosition / Globals.cameraZoom - Vector2(xOffset, backgroundNode.size.y)
	visible = true

func hideSettings():
	visible = false
	closeSettings.emit()
	Globals.duckName = nameEditNode.text

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
	duckColorButtonNode.text = duckColorMenuNode.get_item_text(id)
	settingsChanged.emit()

func _on_parachute_color_button_pressed() -> void:
	parachuteColorMenuNode.popup()

func _on_parachute_color_menu_id_pressed(id: int) -> void:
	Globals.parachuteColorIndex = id
	parachuteColorButtonNode.text = parachuteColorMenuNode.get_item_text(id)
	settingsChanged.emit()

func _on_parachute_background_color_button_pressed() -> void:
	parachuteBackgroundcolorMenuNode.popup()

func _on_parachute_background_color_menu_id_pressed(id: int) -> void:
	Globals.parachuteBackgroundIndex = id
	parachuteBackgroundcolorButtonNode.text = parachuteBackgroundcolorMenuNode.get_item_text(id)
	settingsChanged.emit()

func _on_character_button_pressed() -> void:
	characterMenuNode.popup()

func _on_character_menu_id_pressed(id: int) -> void:
	Globals.personalityIndex = id
	characterButtonNode.text = characterMenuNode.get_item_text(id)
	settingsChanged.emit()
