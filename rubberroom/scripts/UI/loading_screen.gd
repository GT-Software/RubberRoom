extends CanvasLayer

signal loading_screen_has_full_coverage

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var progressBar : ProgressBar = $Panel/ProgressBar

func update_progress_bar(new_value : float) -> void:
	progressBar.set_value_no_signal(new_value * 100)
	
func start_outro_animation() -> void:
	await Signal(animationPlayer, "animation_finished")
	animationPlayer.play("end_load")
	await Signal(animationPlayer, "animation_finished")
	self.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
