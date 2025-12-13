extends Area2D

var speed = 600.0 

func _process(delta):
	# Move down
	position.y += speed * delta

# Signal: Connected via Node tab -> VisibilityNotifier -> screen_exited
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Clean up memory (Robustness Rubric)

# Signal: Connected via Node tab -> Area2D -> body_entered
func _on_body_entered(body):
	if body.name == "Player":
		# We use a group call so we don't need hard links to the main scene
		get_tree().call_group("game_manager", "game_over")
