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

var personalities = [
	"Intelligent",
	"Motivational",
	"Funny",
	"Sarcastic"
]

var quotes := [
	[
		"ToDo: Sprüche hinzufügen"
	],
	[
		"Das ist kein Fehler... das ist ein kreatives Verhalten.",
		"Interessant sehr interessant."
	],
	[
		"Das ist ein Feature und kein Bug!",
		"Hast du schon probiert, das Gerät aus- und wieder ein zu schalten?",
		"Ich warte, während du neu startest.",
		"Ich bin eben ein Feature mit Charakter.",
		"Das Problem sitzt vermutlich vor dem Bildschirm.",
		"Ein Neustart löst 80% aller Probleme.",
		"Ich sehe das Problem... und ich ignoriere es.",
		"Das merke ich mir... vielleicht.",
		"Also ich war das nicht!",
		"Das ist ein Feature und kein Bug! "
	],
	[
		"Also auf meinem Rechner funktioniert es...",
		"Das sieht aber nach Arbeit aus."
	]
]

var supportHotlineText = "Du hast Probleme?\nWir haben Lösungen!\nIT-Support Hotline:\n+43 316 405 455 222"

var colorIndex = 7
var parachuteColorIndex = 0
var parachuteBackgroundIndex = 0

var duckColor = duckColors[colorIndex]
var beakColor = beakColors[colorIndex]
var parachuteColor = parachuteColors[parachuteColorIndex]
var parachuteBackground = parachuteBackgrounds[parachuteBackgroundIndex]

var personalityIndex = 2
var selectedQuotes = quotes[personalityIndex].duplicate(true)

var cameraZoom = Vector2(2.5, 2.5)
