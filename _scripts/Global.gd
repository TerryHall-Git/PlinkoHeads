extends Node

var maxLevelSizeY:float = 4500.0
var player:RigidBody2D
var canPlay:bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if !get_tree().paused:
			get_tree().current_scene.get_node("Camera2D/UI/MainMenu").visible = true
			get_tree().paused = true
	
