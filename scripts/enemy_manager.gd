extends Node

# 敌人场景路径
@export var kamikaze_enemy_scene: PackedScene  # 自爆敌人场景

# 敌人生成设置
@export var spawn_delay: float = 5.0  # 生成敌人的基础时间间隔
@export var min_spawn_delay: float = 2.0  # 最小生成时间间隔
@export var spawn_delay_reduction: float = 0.1  # 每次生成后减少的时间间隔
@export var max_enemies: int = 10  # 场景中最大敌人数量

# 生成点设置
@export var spawn_points: Array[Node] = []  # 敌人生成点
@export var min_distance_from_player: float = 300.0  # 生成敌人与玩家的最小距离

# 内部变量
var elapsed_time: float = 0.0
var current_spawn_delay: float = 0.0
var enemies_count: int = 0
var player: Node2D = null
var rng = RandomNumberGenerator.new()

func _ready():
	# 初始化随机数生成器
	rng.randomize()
	
	# 设置初始生成延迟
	current_spawn_delay = spawn_delay
	
	# 查找玩家节点
	player = get_tree().get_first_node_in_group("player")
	
	# 如果没有指定生成点，尝试在场景中查找
	if spawn_points.size() == 0:
		var spawners = get_tree().get_nodes_in_group("enemy_spawner")
		if spawners.size() > 0:
			spawn_points = spawners

func _process(delta):
	# 更新经过的时间
	elapsed_time += delta
	
	# 检查是否应该生成新敌人
	if elapsed_time >= current_spawn_delay and enemies_count < max_enemies:
		spawn_enemy()
		
		# 重置计时器并减少下次生成的延迟
		elapsed_time = 0.0
		current_spawn_delay = max(min_spawn_delay, current_spawn_delay - spawn_delay_reduction)

func spawn_enemy():
	# 确保有可用的敌人场景和生成点
	if kamikaze_enemy_scene == null or spawn_points.size() == 0:
		print("无法生成敌人：", "场景可用: ", kamikaze_enemy_scene != null, " 生成点数量: ", spawn_points.size())
		return
	
	print("开始生成敌人...")
	
	# 选择一个离玩家足够远的生成点
	var valid_spawn_points = []
	for point in spawn_points:
		if player and point.global_position.distance_to(player.global_position) >= min_distance_from_player:
			valid_spawn_points.append(point)
	
	print("有效生成点数量: ", valid_spawn_points.size())
	
	# 如果没有有效的生成点，直接返回
	if valid_spawn_points.size() == 0:
		print("没有找到有效的生成点")
		return
	
	# 随机选择一个生成点
	var spawn_point = valid_spawn_points[rng.randi() % valid_spawn_points.size()]
	print("选择的生成点位置: ", spawn_point.global_position)
	
	# 实例化敌人
	var enemy = kamikaze_enemy_scene.instantiate()
	enemies_count += 1
	print("已生成自爆敌人，当前敌人数量: ", enemies_count)
	
	# 将敌人添加到游戏场景并设置位置
	get_tree().get_root().add_child(enemy)
	enemy.global_position = spawn_point.global_position
	print("敌人位置已设置为: ", enemy.global_position)
	
	# 连接敌人的tree_exited信号，以便在敌人被销毁时更新计数
	enemy.tree_exited.connect(_on_enemy_destroyed.bind(enemy))
	
	# 可以在这里根据游戏进度调整敌人的属性
	# enemy.detection_radius += get_parent().current_wave * 50.0

func _on_enemy_destroyed(enemy):
	# 更新敌人计数
	enemies_count -= 1 