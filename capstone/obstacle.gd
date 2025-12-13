extends Area2D
var speed = 600.0

func _ready() -> void:
	add_to_group("obstacles")

func _process(delta: float) -> void:
	position.y += speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		get_tree().call_group("game_manager", "game_over")
