extends Node

var maxLevelSizeY:float = 4500.0
var player:RigidBody2D
var canPlay:bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):  # 'ui_cancel' is mapped to the 'Escape' key by default
		get_tree().reload_current_scene()  # Restart the current level
