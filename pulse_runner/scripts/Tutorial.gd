extends Node2D

func _ready() -> void:
    """Connect the start button to begin play from the tutorial."""
    if has_node("StartButton"):
        $StartButton.connect("pressed", Callable(self, "_on_start_pressed"))


func _on_start_pressed() -> void:
    """Jump straight into the main game scene."""
    get_tree().change_scene_to_file("res://MainGame.tscn")