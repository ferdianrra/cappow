extends Node

# Preload your background music files (.ogg or .mp3)
const MENU_MUSIC = preload("res://assets/music/battle.mp3")
const BATTLE_MUSIC = preload("res://assets/music/boxing.mp3")

var music_player: AudioStreamPlayer

func _ready() -> void:
	# Create an AudioStreamPlayer node dynamically so it lives globally
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# Set up standard background music settings
	music_player.bus = "Music" # Or a dedicated "Music" bus if you make one
	
	# Start by playing the menu music automatically when the game boots up
	play_music(MENU_MUSIC)

func play_music(stream: AudioStream) -> void:
	# Safety check: if it's already playing this exact track, don't restart it
	if music_player.stream == stream and music_player.playing:
		return
		
	music_player.stop()
	music_player.stream = stream
	music_player.play()

# Helper functions you can call from any scene in your game
func play_menu_music() -> void:
	play_music(MENU_MUSIC)

func play_battle_music() -> void:
	play_music(BATTLE_MUSIC)
