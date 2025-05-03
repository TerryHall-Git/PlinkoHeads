extends Node2D

@export var prize:String = "Candy"
@onready var yellowLight1: Sprite2D = $YellowLight1
@onready var greenLight1: Sprite2D = $GreenLight1
@onready var yellowLight2: Sprite2D = $YellowLight2
@onready var greenLight2: Sprite2D = $GreenLight2

var playerStopped: bool = false  
var isPlayerInZone: bool = false 

signal player_won(somePrize:String)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Global.player:
		isPlayerInZone = true 

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == Global.player:
		isPlayerInZone = false 

func _process(_delta: float) -> void:
	if isPlayerInZone and !playerStopped:
		if Global.player.isCelebrating:
			playerStopped = true
			greenLight1.visible = true
			greenLight2.visible = true
			yellowLight1.visible = false
			yellowLight2.visible = false
			player_won.emit(prize)
