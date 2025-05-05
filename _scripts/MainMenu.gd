extends Control

var isReady:bool = false

func _process(_delta: float) -> void:
	if !self.visible: return
	if !isReady:
		await get_tree().process_frame
		isReady = true
		return
	if Input.is_action_just_pressed("ui_cancel"): 
		unpause()
		
func unpause():
	self.visible = false
	get_tree().paused = false
	isReady = false
