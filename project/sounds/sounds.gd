class_name Sounds
extends Node2D

func PlaySound(soundName: String) -> void:
	var found := false
	for child in get_children():
		if child.name == soundName:
			# print("playing: " + soundName)
			var sound : AudioStreamPlayer = child
			sound.playing = true
			found = true
			break

	if not found:
		print("No sound found with name: " + soundName)