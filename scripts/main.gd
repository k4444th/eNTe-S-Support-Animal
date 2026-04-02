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

var totalPolygon := PackedVector2Array()

@onready var clickTimer := $ClickTimer
@onready var spriteNode := $Sprite
@onready var cameraNode := $Camera

func _ready() -> void:
	spriteNode.duckNode.duckFrameChanged.connect(cookieCutDuckShape)
	
	var window = get_window()
	
	get_viewport().transparent_bg = true
	window.transparent = true 
	window.borderless = true
	window.always_on_top = true
	window.unresizable = true
	
	window.size = Vector2(spriteNode.duckNode.sprite_frames.get_frame_texture("idleDarkBlue", 4).get_width() * Globals.cameraZoom.x, spriteNode.parachuteNode.sprite_frames.get_frame_texture("open", 0).get_height() * Globals.cameraZoom.y + (32 * Globals.cameraZoom.y))
	cameraNode.zoom = Globals.cameraZoom
	
	var usableRect := DisplayServer.screen_get_usable_rect()
	var yPos = usableRect.end.y - window.size.y
	
	window.position = Vector2i(0, yPos)

func cookieCutDuckShape(duckFrame: int, tailFrame: int, beakFrame: int, beakAnimation: String):
	#var totalPolygon := PackedVector2Array()
	totalPolygon = PackedVector2Array()
	
	var bodyTexture = spriteNode.duckNode.sprite_frames.get_frame_texture("idleDarkBlue", duckFrame)
	var bodyImage = bodyTexture.get_image()
	var bodyBitmap = BitMap.new()
	bodyBitmap.create_from_image_alpha(bodyImage)
	var bodyPolygons = bodyBitmap.opaque_to_polygons(Rect2(Vector2.ZERO, bodyImage.get_size()))
	
	var tailTexture = spriteNode.duckNode.tailNode.sprite_frames.get_frame_texture("idleDarkBlue", tailFrame)
	var tailImage = tailTexture.get_image()
	var tailBitmap = BitMap.new()
	tailBitmap.create_from_image_alpha(tailImage)
	var tailPolygons = tailBitmap.opaque_to_polygons(Rect2(Vector2.ZERO, tailImage.get_size()))
	
	var beakTexture = spriteNode.duckNode.beakNode.sprite_frames.get_frame_texture(beakAnimation, beakFrame)
	var beakImage = beakTexture.get_image()
	var beakBitmap = BitMap.new()
	beakBitmap.create_from_image_alpha(beakImage)
	var beakPolygons = beakBitmap.opaque_to_polygons(Rect2(Vector2.ZERO, beakImage.get_size()))
	
	if bodyPolygons.size() > 0:
		for p in bodyPolygons[0]:
			totalPolygon.append(p * Globals.cameraZoom + Vector2(0, 40 * Globals.cameraZoom.y))
	
	if tailPolygons.size() > 0:
		for p in tailPolygons[0]:
			totalPolygon.append(p * Globals.cameraZoom + Vector2(0, 40 * Globals.cameraZoom.y))
	
	if beakPolygons.size() > 0:
		for p in beakPolygons[0]:
			totalPolygon.append(p * Globals.cameraZoom + Vector2(0, 40 * Globals.cameraZoom.y))
	
	DisplayServer.window_set_mouse_passthrough(totalPolygon)

func _draw():
	if totalPolygon.size() > 0:
		draw_colored_polygon(totalPolygon, Color(1, 0, 0))
			
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
	
	var flyTime = pow(abs(window.position.y - yPos), 0.7) * 0.01
	var parachuteAnimationDuration = (1 / spriteNode.parachuteNode.sprite_frames.get_animation_speed("opening")) * spriteNode.parachuteNode.sprite_frames.get_frame_count("opening")
	
	if flyTime > parachuteAnimationDuration and window.position.y < yPos:
		spriteNode.parachuteNode.open()
	
	var positionTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	positionTween.tween_property(window, "position", Vector2i(window.position.x, yPos), flyTime)
	
	if flyTime > parachuteAnimationDuration and window.position.y < yPos:
		await positionTween.finished
		spriteNode.parachuteNode.close()

func _on_click_timer_timeout() -> void:
	if clickPending:
		hasFirstClick = false
		clickPending = false
	
	spriteNode.duckNode.talk()
