extends Node

export (PackedScene) var Mob
export var max_mobs_count = 5
var score

func _ready():
	randomize()
	$BackgroundMusic.play()

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	get_tree().call_group("mobs", "queue_free")
	$HUD.show_game_over()
	$DeathSound.play()

func new_game():
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get ready!")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$BackgroundMusic.stop()

func _can_mob_spawn():
	# TODO: Might be more performant to just write that into a variable
	var current_mobs = get_tree().get_nodes_in_group("mobs").size()
	return current_mobs < max_mobs_count

func _mob_spawn_location():
	var player_pos = $Player.position
	var safe_space = Rect2(player_pos.x - 3, player_pos.y -3, 6, 6)
	$MobPath/MobSpawnLocation.offset = randi()
	# TODO: Might be more performant to just move the spawn location outside
	# of the safe_space
	while(safe_space.has_point($MobPath/MobSpawnLocation.position)):
		$MobPath/MobSpawnLocation.offset = randi()

func _on_MobTimer_timeout():
	if !_can_mob_spawn():
		 return 
	
	_mob_spawn_location()
	
	var mob = Mob.instance()
	add_child(mob)
	
	var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
	mob.position = $MobPath/MobSpawnLocation.position
	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0)
	mob.linear_velocity = mob.linear_velocity.rotated(direction)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
