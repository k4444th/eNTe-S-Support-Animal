extends Node

var colors = [
	"Cyan",
	"DarkBlue",
	"LightBlue",
	"LightGreen",
	"Orange",
	"Pink",
	"Purple",
	"Yellow"
]

var colorIndex = randi_range(0, len(colors) - 1)

var duckColor = colors[colorIndex]
