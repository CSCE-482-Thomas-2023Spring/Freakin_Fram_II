extends Node2D

# Scroll through credits
func _ready():
	yield(get_tree().create_timer(5), "timeout")
	$SpriteCredits.show()
	$TeamCredits.hide()
	yield(get_tree().create_timer(5), "timeout")
	$ArtCredits.show()
	$SpriteCredits.hide()
	yield(get_tree().create_timer(5), "timeout")
	$ThanksForPlaying.show()
	$ArtCredits.hide()

# Exit Game
func _on_QuitButton_pressed():
	get_tree().quit()
