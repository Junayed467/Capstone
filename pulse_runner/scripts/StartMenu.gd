extends Node2D

func _ready() -> void:
    """Connect button signals when the menu loads."""
    if has_node("StartButton"):
        $StartButton.connect("pressed", Callable(self, "_on_start_pressed"))
    if has_node("TutorialButton"):
        $TutorialButton.connect("pressed", Callable(self, "_on_tutorial_pressed"))


func _on_start_pressed() -> void:
    """Begin the game by switching to the main scene."""
    get_tree().change_scene_to_file("res://MainGame.tscn")


func _on_tutorial_pressed() -> void:
    """Open the tutorial screen."""
    get_tree().change_scene_to_file("res://Tutorial.tscn")