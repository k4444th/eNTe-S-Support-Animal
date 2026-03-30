extends AnimatedSprite2D

var baseEyePos := Vector2(3, -3.5)

@onready var eyeNode := $Eye

func _on_frame_changed() -> void:
	if frame == 0:
		baseEyePos.y = -3.5
	elif frame == 1:
		baseEyePos.y = -4.5
	
	eyeNode.position = baseEyePos
