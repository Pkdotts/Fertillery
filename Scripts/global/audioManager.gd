extends Control

#func play_music()
var musicVolume = 0

func _ready():
	$AudioPlayers/GameMusic.volume_db = musicVolume
	$AudioPlayers/Ambiance.volume_db = musicVolume

func play_game_music():
	$AudioPlayers/GameMusic.play()

func stop_game_music():
	$AudioPlayers/GameMusic.stop()

func play_ambiance_music():
	$AudioPlayers/Ambiance.play()

func stop_ambiance_music():
	$AudioPlayers/Ambiance.stop()

func add_sfx(stream, name) -> AudioStreamPlayer:
	var sfx_node: AudioStreamPlayer = get_sfx(name)
	if !sfx_node:
		sfx_node = AudioStreamPlayer.new()
		sfx_node.bus = "SFX"
		sfx_node.name = name
		$Sfx.add_child(sfx_node)
	sfx_node.stream = stream
	return sfx_node

func play_sfx(stream, name) -> AudioStreamPlayer:
	var sfx_node: AudioStreamPlayer = add_sfx(stream, name)
	sfx_node.play()
	return sfx_node

func get_sfx(name) -> AudioStreamPlayer:
	return $Sfx.get_node_or_null(name) as AudioStreamPlayer

#func _on_Tween_tween_completed(object, key):
	#remove_all_unplaying()
