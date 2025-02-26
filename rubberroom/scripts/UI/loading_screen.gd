extends CanvasLayer

signal loading_screen_has_full_coverage

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var progressBar : ProgressBar = $Panel/ProgressBar

func update_progress_bar(new_value : float) -> void:
	progressBar.set_value_no_signal(new_value * 100)
	
func start_outro_animation() -> void:
	#await Signal(animationPlayer, "animation_finished")
	await get_tree().create_timer(1.0).timeout
	animationPlayer.play("end_load")
	await Signal(animationPlayer, "animation_finished")
	self.queue_free()
