extends Node2D

@onready var duckNode := $Duck
@onready var parachuteNode := $Parachute

func _ready() -> void:
	parachuteNode.visible = false
