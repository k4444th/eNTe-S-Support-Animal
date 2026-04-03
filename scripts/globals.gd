extends Node

var duckColors = [
	"Cyan",
	"DarkBlue",
	"LightBlue",
	"LightGreen",
	"Orange",
	"Pink",
	"Purple",
	"Yellow"
]

var beakColors = [
	"Orange",
	"Orange",
	"Orange",
	"Orange",
	"Yellow",
	"Orange",
	"Orange",
	"Orange"
]

var parachuteColors = [
	"Cyan",
	"DarkBlue",
	"LightBlue",
	"LightGreen",
	"Orange",
	"Pink",
	"Purple",
	"Yellow"
]

var parachuteBackgrounds = [
	"Light",
	"Dark"
]

var colorIndex = 7
var parachuteColorIndex = 0
var parachuteBackgroundIndex = 0

var duckColor = duckColors[colorIndex]
var beakColor = beakColors[colorIndex]
var parachuteColor = parachuteColors[parachuteColorIndex]
var parachuteBackground = parachuteBackgrounds[parachuteBackgroundIndex]

var cameraZoom = Vector2(2.5, 2.5)
