GDPC                �                                                                      #   T   res://.godot/exported/133200997/export-3bfc78ea9e153e136ca81b26bf18a076-Client.scn  H            Ƌ��'�}��J�y4�    X   res://.godot/exported/133200997/export-3c7584b84430eee816dd365c81829d2b-node_gene.scn   �E      z      R��3-/K�Zn�I
�    T   res://.godot/exported/133200997/export-551303407a3b7047388706423bbb9f84-genome.scn  `A      /      �1�'r�X�uk�    T   res://.godot/exported/133200997/export-6b9c1b1fd6ae6f795188dfdc89e222b0-world.scn   @o            ���I�?қSt�6�    \   res://.godot/exported/133200997/export-842787de3048a3d1bbe152be62821a39-NetworkDiagram.scn  ��      �      q��鐶ڼ�Iz���}    T   res://.godot/exported/133200997/export-907aa51e66f33c3f537146f653aaa974-swimmer.scn �U      �      9��*.sD����%J��    P   res://.godot/exported/133200997/export-d42a4737021db34e7478aa19f2a4d7e7-gene.scn�>      r      �EIo957@��Wq
��    ,   res://.godot/global_script_class_cache.cfg  ��      �      ��#��q�Zs��J��G�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex`�            ：Qt�E�cO���       res://.godot/uid_cache.bin  `�      9      ��*G�8j�j����       res://NetworkDiagram.gd P�      l      
�n��,n��P�E	�        res://NetworkDiagram.tscn.remap @�      k       .�"���8D}�T-�f��       res://icon.svg  ��      �      k����X3Y���f       res://icon.svg.import   ��      �       �����nȍ
@W'33       res://neat/Client.tscn.remap�      c       ���u�
��u��f       res://neat/gene.tscn.remap  ��      a       ���$&Kr����:4       res://neat/genome.tscn.remap�      c       сp�ur9��뗖�        res://neat/node_gene.tscn.remap ��      f       �;wGh��YH�mƒe�       res://neat/scripts/Brain.gd �!      <      ����cy���P�    $   res://neat/scripts/ConnectionGene.gd        �      �� #U���X�t�       res://neat/scripts/Gene.gd  �      �       �1Y�p8���t�6       res://neat/scripts/Genome.gd@      �      v�A,��y`L��2K�    (   res://neat/scripts/HyperParameters.gd    2      �      ���q�7���G����8       res://neat/scripts/NNode.gd �      �       ���҈a�Ւ�{�u�        res://neat/scripts/NodeGene.gd  `      �      "\F̿�;��Ċ?��       res://neat/scripts/Specie.gd 6      �      Fvu�g+�H^�|�       res://neat/scripts/neat.gd  @      �	      �F�w���cE�9�B�       res://organisms/swimmer.gd  0N      \      K�	�nyXg�$S���    $   res://organisms/swimmer.tscn.remap  `�      d       `�!�N/���X.& ��n       res://project.binary��      f      =�:����Q�Te����       res://scenes/Camera3D.gda      �      U����\}�֮�B�        res://scenes/NeatController.gd   e      )       5�Q�)�Ub���6�       res://scenes/Population.gd  0e      �	      �C<Zu	�����5���       res://scenes/world.gd   �n      e       3�8�4�lR���B�j�2        res://scenes/world.tscn.remap   Ц      b       ������מ��ф�|�                extends Object

class_name ConnectionGene

var weight: float
var enabled: bool = true # default state

func _init(_weight: float, _enabled: bool = true):
	weight = _weight
	enabled = _enabled
	
func _to_string():
	return "ConnectionGene(link_id=%d, weight=%f, enabled=%s)" % [self.link_id, self.weight, str(self.enabled)]
	
func duplicate() -> ConnectionGene:
	var new_gene = ConnectionGene.new(weight, enabled)
	return new_gene
   extends Node

class_name Gene

var innovation_number: int

func _init(_innovation_number: int = -1):
	innovation_number = _innovation_number
   extends Node
class_name Genome

var genome_id: int
@export var num_inputs: int
@export var num_outputs: int
var neurons: Dictionary # neuron_id: NodeGene 
var links: Dictionary # "i,j" : ConnectionGene

var fitness: float = 0
var adjusted_fitness: float = 0
var max_node: int
var unhidden: int
var default_activation: Callable = sigmoid

var mutation_probabilities = {
	'node' : 0.01,
	'edge' : 0.09,
	'weight_perturb' : 0.4,
	'weight_set' : 0.1,
	'bias_perturb' : 0.3,
	'bias_set' : 0.1
}

func sigmoid(x: float) -> float:
	return 1.0 / (1.0 + exp(-x))

func relu(x: float) -> float:
	return max(0.0, x)

func leaky_relu(x: float) -> float:
	return max(0.01 * x, x)

func _init(_num_inputs: int, _num_outputs: int, _default_activation: Callable = Callable(self, "sigmoid")):
	num_inputs = _num_inputs
	num_outputs = _num_outputs
	default_activation = _default_activation

	unhidden = num_inputs + num_outputs
	max_node = num_inputs + num_outputs
	neurons = {}
	links = {}

func forward(_inputs: Array) -> Array:
	assert(_inputs.size() == num_inputs, "Input size mismatch")

	if neurons.is_empty():
		return []

	for i in range(num_inputs):
		neurons[i].output = _inputs[i]

	var _from = {}
	for n in range(max_node):
		_from[n] = []

	for edge in links.keys():
		var nodes = edge.split(",")
		var i = int(nodes[0])
		var j = int(nodes[1])
		if links[edge].enabled:
			_from[j].append(i)

	var ordered_nodes = []
	for i in range(unhidden, max_node):
		ordered_nodes.append(i)
	for i in range(num_inputs, unhidden):
		ordered_nodes.append(i)

	for j in ordered_nodes:
		var ax = 0.0
		for i in _from[j]:
			var key = str(i) + "," + str(j)
			ax += links[key].weight * neurons[i].output

		var neuron = neurons[j]
		neuron.output = neuron.activation_func.call(ax + neuron.bias)

	var outputs = []
	for i in range(num_outputs):
		outputs.append(neurons[num_inputs + i].output)

	return outputs

func mutate(probabilities: Dictionary):
	if is_disabled():
		add_enabled()

	var population = probabilities.keys()
	var choice = population[randi() % population.size()]
	
	match choice:
		"node":
			add_node()
		"edge":
			add_enabled()
		"weight_perturb", "weight_set", "bias_perturb", "bias_set":
			shift_weight(choice)

func random_pair() -> Array:
	var i = randi() % max_node
	while is_output(i):
		i = randi() % max_node

	var j_list = []
	for n in range(max_node):
		if not is_input(n) and n != i:
			j_list.append(n)

	var j
	if j_list.is_empty():
		j = max_node
		add_node()
	else:
		j = j_list[randi() % j_list.size()]

	return [i, j]

func is_disabled() -> bool:
	for link in links.values():
		if not link.enabled:
			return true
	return false

func is_input(node_id: int) -> bool:
	return 0 <= node_id and node_id < num_inputs

func is_output(node_id: int) -> bool:
	return num_inputs <= node_id and node_id < unhidden

func is_hidden(node_id: int) -> bool:
	return unhidden <= node_id and node_id < max_node

func add_node():
	var enabled = links.keys().filter(func(key): return links[key].enabled)
	
	if enabled.is_empty():
		return
	
	var selected_edge = enabled[randi() % enabled.size()]
	var nodes = selected_edge.split(",")
	var i = int(nodes[0])
	var j = int(nodes[1])
	
	links[selected_edge].enabled = false
	
	var new_node = max_node
	max_node += 1
	neurons[new_node] = NodeGene.new(default_activation)
	
	add_edge(i, new_node, 1.0)
	add_edge(new_node, j, links[selected_edge].weight)

func add_enabled():
	var disabled = links.keys().filter(func(key): return not links[key].enabled)
	if not disabled.is_empty():
		var index = randi() % disabled.size()
		links[disabled[index]].enabled = true

func add_edge(i: int, j: int, weight: float):
	var key = str(i) + "," + str(j)
	if links.has(key):
		links[key].enabled = true
	else:
		links[key] = ConnectionGene.new(weight)

func generate():
	for n in range(max_node):
		neurons[n] = NodeGene.new(default_activation)
	
	for i in range(num_inputs):
		for j in range(num_inputs, unhidden):
			add_edge(i, j, randf() * 2.0 - 1.0)

func shift_weight(type: String):
	var e = links.keys()[randi() % links.size()]
	match type:
		"weight_perturb":
			links[e].weight += randf() * 2.0 - 1.0
		"weight_set":
			links[e].weight = randf() * 4.0 - 2.0
		"bias_perturb":
			var node = int(e.split(",")[1])
			neurons[node].bias += randf() * 2.0 - 1.0
		"bias_set":
			var node = int(e.split(",")[1])
			neurons[node].bias = randf() * 4.0 - 2.0

func get_nodes() -> Dictionary:
	return neurons.duplicate()

func get_links() -> Dictionary:
	return links.duplicate()

func get_num_nodes() -> int:
	return max_node

func set_fitness(score: float):
	fitness = score

func reset():
	for n in neurons.values():
		n.output = 0.0
	fitness = 0.0

func clone() -> Genome:
	var new_genome = Genome.new(num_inputs, num_outputs)
	new_genome.neurons = neurons.duplicate(true)
	new_genome.links = links.duplicate(true)
	new_genome.fitness = fitness
	new_genome.adjusted_fitness = adjusted_fitness
	new_genome.max_node = max_node
	new_genome.unhidden = unhidden
	return new_genome
               extends Node

class_name NNode

var x: float # input

var output: float # output value
var activation: Callable
var bias: float
extends Object
class_name NodeGene

var x: float
var y: float

var activation_func: Callable
var bias: float
var output: float = 0.0


func _init(_activation_func: Callable, _bias: float = 0 ):
	if _activation_func == null:
		_activation_func = func(_x: float) -> float:
			return tanh(_x)
	activation_func = _activation_func
	bias = _bias

func duplicate() -> NodeGene:
	var new_node = NodeGene.new(activation_func, bias)
	new_node.x = x
	new_node.y = y
	return new_node
        extends Node
class_name Neat

static func genomic_distance(a: Genome, b: Genome, distance_weights: Dictionary) -> float:
	var a_edges = a.links.keys()
	var b_edges = b.links.keys()
	
	var matching_edges = []
	var disjoint_edges = []
	for edge in a_edges:
		if edge in b_edges:
			matching_edges.append(edge)
		else:
			disjoint_edges.append(edge)
	
	for edge in b_edges:
		if edge not in a_edges:
			disjoint_edges.append(edge)
	
	var N_edges = max(a_edges.size(), b_edges.size())
	var N_nodes = min(a.max_node, b.max_node)
	
	var weight_diff = 0.0
	for edge in matching_edges:
		weight_diff += abs(a.links[edge].weight - b.links[edge].weight)
	
	var bias_diff = 0.0
	for i in range(N_nodes):
		if i in a.neurons and i in b.neurons:
			bias_diff += abs(a.neurons[i].bias - b.neurons[i].bias)
	
	var t1 = distance_weights['edge'] * disjoint_edges.size() / N_edges if N_edges > 0 else 0
	var t2 = distance_weights['weight'] * weight_diff / matching_edges.size() if matching_edges.size() > 0 else 0
	var t3 = distance_weights['bias'] * bias_diff / N_nodes if N_nodes > 0 else 0
	
	return t1 + t2 + t3



static func genomic_crossover(a: Genome, b: Genome) -> Genome:
	var child = Genome.new(a.num_inputs, a.num_outputs, a.default_activation)
	var a_edges = a.links.keys()
	var b_edges = b.links.keys()
	
	var intersection = []
	for edge in a_edges:
		if edge in b_edges:
			intersection.append(edge)
	
	for edge in intersection:
		var parent = a if randf() < 0.5 else b
		child.links[edge] = parent.links[edge].duplicate()
	
	var disjoint_a = a_edges.filter(func(edge): return edge not in b_edges)
	var disjoint_b = b_edges.filter(func(edge): return edge not in a_edges)
	
	if a.fitness > b.fitness:
		for edge in disjoint_a:
			child.links[edge] = a.links[edge].duplicate()
	else:
		for edge in disjoint_b:
			child.links[edge] = b.links[edge].duplicate()
	
	child.max_node = 0
	for edge in child.links.keys():
		var nodes = edge.split(',')
		var i = int(nodes[0])
		var j = int(nodes[1])
		child.max_node = max(child.max_node, i, j)
	child.max_node += 1
	
	for n in range(child.max_node):
		var inherit_from = []
		if n in a.neurons:
			inherit_from.append(a)
		if n in b.neurons:
			inherit_from.append(b)
		
		if inherit_from.is_empty():
			continue
		
		inherit_from.shuffle()
		#var parent = inherit_from.max(func(p): return p.fitness)
		var parent = inherit_from[0]
		
		child.neurons[n] = parent.neurons[n].duplicate()
	
	child.reset()
	return child
         extends Object
class_name Brain

var _inputs: int
var _outputs: int
var _species: Array
var _population: int
var _hyperparams: Hyperparameters
var _generation: int
var _current_species: int
var _current_genome: int
var _global_best: Genome

func _init(inputs: int, outputs: int, population: int = 100, hyperparams = null):
	_inputs = inputs
	_outputs = outputs
	_species = []
	_population = population
	_hyperparams = hyperparams if hyperparams else Hyperparameters.new()
	_generation = 0
	_current_species = 0
	_current_genome = 0
	_global_best = null

func generate():
	for i in range(_population):
		var g = Genome.new(_inputs, _outputs, _hyperparams.default_activation)
		g.generate()
		classify_genome(g)
	
	_global_best = _species[0]._members[0]

func classify_genome(genome: Genome):
	if _species.is_empty():
		_species.append(Specie.new(_hyperparams.max_fitness_history, [genome]))
	else:
		for s in _species:
			var rep = s._members[0]
			var dist = Neat.genomic_distance(genome, rep, _hyperparams.distance_weights)
			if dist <= _hyperparams.delta_threshold:
				s._members.append(genome)
				return

		_species.append(Specie.new(_hyperparams.max_fitness_history, [genome]))

func update_fittest():
	var top_performers = _species.map(func(s): return s.get_best())
	#var current_top = top_performers.max(func(g): return g._fitness)
	var current_top = top_performers[0]
	for g in top_performers:
		if g._fitness > current_top._fitness:
			current_top = g


	if current_top._fitness > _global_best._fitness:
		_global_best = current_top.clone()

func evolve():
	var global_fitness_sum = 0
	for s in _species:
		s.update_fitness()
		global_fitness_sum += s._fitness_sum

	if global_fitness_sum == 0:
		for s in _species:
			for g in s._members:
				g.mutate(_hyperparams.mutation_probabilities)
	else:
		var surviving_species = _species.filter(func(s): return s.can_progress())
		_species = surviving_species

		for s in _species:
			s.cull_genomes(false)

		for i in range(_species.size()):
			var s = _species[i]
			var ratio = s._fitness_sum / global_fitness_sum
			var diff = _population - get_population()
			var offspring = int(round(ratio * diff))
			for j in range(offspring):
				classify_genome(s.breed(_hyperparams.mutation_probabilities, _hyperparams.breed_probabilities))

		if _species.is_empty():
			for i in range(_population):
				var g
				if i % 3 == 0:
					g = _global_best.clone()
				else:
					g = Genome.new(_inputs, _outputs, _hyperparams.default_activation)
					g.generate()
				g.mutate(_hyperparams.mutation_probabilities)
				classify_genome(g)

	_generation += 1

func should_evolve() -> bool:
	update_fittest()
	var fit = _global_best._fitness <= _hyperparams.max_fitness
	var end = _generation != _hyperparams.max_generations
	return fit and end

func next_iteration():
	# edited with modulo
	var s = _species[_current_species % _species.size()]
	if _current_genome < s._members.size() - 1:
		_current_genome += 1
	else:
		if _current_species < _species.size() - 1:
			_current_species += 1
			_current_genome = 0
		else:
			evolve()
			_current_species = 0
			_current_genome = 0

func evaluate_parallel(evaluator: Callable, args: Array = [], kwargs: Dictionary = {}):
	# Note: GDScript doesn't have built-in multiprocessing.
	# You might need to implement this differently or use threads.
	pass

func get_fittest() -> Genome:
	return _global_best

func get_population() -> int:
	return _species.reduce(func(accum, s): return accum + s._members.size(), 0)

func get_current() -> Genome:

	var s = _species[_current_species % _species.size()]
	return s._members[_current_genome % s._members.size()]

func get_current_species() -> int:
	return _current_species

func get_current_genome() -> int:
	return _current_genome

func get_generation() -> int:
	return _generation

func get_species() -> Array:
	return _species

func save(filename: String):
	var file = FileAccess.open(filename + ".neat", FileAccess.WRITE)
	file.store_var(self)
	file.close()

static func load(filename: String) -> Brain:
	var file = FileAccess.open(filename + ".neat", FileAccess.READ)
	var brain = file.get_var()
	file.close()
	return brain
    extends Object
class_name Hyperparameters

var delta_threshold: float
var distance_weights: Dictionary
var default_activation: Callable
var max_fitness: float
var max_generations: float
var max_fitness_history: int
var breed_probabilities: Dictionary
var mutation_probabilities: Dictionary

func sigmoid(x: float) -> float:
	return 1.0 / (1.0 + exp(-x))
func _init():
	delta_threshold = 1.5
	distance_weights = {
		"edge": 1.0,
		"weight": 1.0,
		"bias": 1.0
	}
	default_activation = sigmoid  # Assuming sigmoid is defined elsewhere
	max_fitness = INF
	max_generations = INF
	max_fitness_history = 30
	breed_probabilities = {
		"asexual": 0.5,
		"sexual": 0.5
	}
	mutation_probabilities = {
		"node": 0.01,
		"edge": 0.09,
		"weight_perturb": 0.4,
		"weight_set": 0.1,
		"bias_perturb": 0.3,
		"bias_set": 0.1
	}

# Assuming sigmoid function is defined elsewhere, but if not, you can define it here:
# static func sigmoid(x: float) -> float:
#     return 1.0 / (1.0 + exp(-x))
               extends Object
class_name Specie

var _members: Array
var _fitness_history: Array
var _fitness_sum: float
var _max_fitness_history: int


func _init(max_fitness_history: int, members: Array = [], ):
	_members = members.duplicate()

	_fitness_history = []
	_fitness_sum = 0.0
	_max_fitness_history = max_fitness_history

func breed(mutation_probabilities: Dictionary, breed_probabilities: Dictionary):
	var population = breed_probabilities.keys()
	var probabilities = []
	for k in population:
		probabilities.append(breed_probabilities[k])
	
	var choice = random_weighted_choice(population, probabilities)
	var child
	
	if choice == "asexual" or _members.size() == 1:
		child = _members[randi() % _members.size()].clone()
		child.mutate(mutation_probabilities)
	elif choice == "sexual":
		var parents = _members.duplicate()
		parents.shuffle()
		var mom = parents.pop_front()
		var dad = parents.pop_front()
		child = Neat.new().genomic_crossover(mom, dad)
	
	return child

func update_fitness():
	for g in _members:
		g.adjusted_fitness = g.fitness / _members.size()
	
	_fitness_sum = 0.0
	for g in _members:
		_fitness_sum += g.adjusted_fitness
	
	_fitness_history.append(_fitness_sum)
	if _fitness_history.size() > _max_fitness_history:
		_fitness_history.pop_front()

func cull_genomes(fittest_only: bool):
	_members.sort_custom(func(a, b): return a.fitness > b.fitness)
	var remaining: int
	if fittest_only:
		remaining = 1
	else:
		remaining = int(ceil(0.25 * _members.size()))
	_members = _members.slice(0, remaining)

func get_best():
	return _members.reduce(func(a, b): return a if a.fitness > b.fitness else b)

func can_progress() -> bool:
	var n = _fitness_history.size()
	var avg = _fitness_history.reduce(func(accum, item): return accum + item) / n
	return avg > _fitness_history[0] or n < _max_fitness_history

# Helper function for weighted random choice
func random_weighted_choice(items: Array, weights: Array):
	var total_weight = weights.reduce(func(accum, item): return accum + item)
	var random_value = randf() * total_weight
	var current_weight = 0.0
	
	for i in range(items.size()):
		current_weight += weights[i]
		if random_value <= current_weight:
			return items[i]
	
	return items[-1]  # Fallback to last item if something goes wrong
          RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://neat/scripts/Gene.gd ��������      local://PackedScene_mdg28          PackedScene          	         names "         Gene    script    Node    	   variants                       node_count             nodes     	   ��������       ����                    conn_count              conns               node_paths              editable_instances              version             RSRC              RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://neat/scripts/Genome.gd ��������   PackedScene    res://neat/node_gene.tscn ��w��`   PackedScene    res://neat/gene.tscn ���a_�?   Script    res://neat/scripts/NNode.gd ��������   Script %   res://neat/scripts/ConnectionGene.gd ��������      local://PackedScene_7e5fn �         PackedScene          	         names "         Genome    script    Node 	   NodeGene    Gene    NNode    ConnectionGene    	   variants                                                           node_count             nodes     )   ��������       ����                      ���                      ���                            ����                           ����                   conn_count              conns               node_paths              editable_instances              version             RSRC RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://neat/scripts/NodeGene.gd ��������      local://PackedScene_a6vf5          PackedScene          	         names "      	   NodeGene    script    Node    	   variants                       node_count             nodes     	   ��������       ����                    conn_count              conns               node_paths              editable_instances              version             RSRC      RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    script/source 	   _bundled    script       Script    res://neat/scripts/Genome.gd ��������      local://GDScript_s84vf I         local://PackedScene_sl2i0 �      	   GDScript            extends Node

class_name Client

# since this game is focused on organic virtual life, time spent alive will be a metric for fitness

var fitness: float = 0
@export var genome: Genome

var time_alive: float = 0
var time_start: float = 0
var starting_health: float = 1600.0
var distance_travelled: float = 0
var uid: int = randi() % 1000
@onready var root = get_parent()


func _ready():
	genome = Genome.new(uid, 1, 2)
	#genome.num_inputs = 1
	#genome.num_outputs = 2
	time_start = Time.get_unix_time_from_system()
	
func calculate_fitness() -> float:
	# Fitness = (v^Time) / ((v^Time)^2 + Distance 
	var time_end = Time.get_unix_time_from_system()
	var d_time = time_end - time_start
	
	return time_alive / pow(d_time, 2) + distance_travelled

func set_id(id: int): uid = id
func die():
	pass
    PackedScene          	         names "         Client    script    Node    Genome    	   variants                                 node_count             nodes        ��������       ����                            ����                   conn_count              conns               node_paths              editable_instances              version             RSRC  extends Node3D

@onready var body = $Body
@onready var left_wing = $LeftWing
@onready var right_wing = $RightWing
@onready var left_wing_joint = $LeftWingJoint
@onready var right_wing_joint = $RightWingJoint
@export var flap_force = 50.0
@export var flap_speed = 0.1
@export var max_altitude = 1.0  # Max allowed altitude
@export var min_altitude = 0.0   # Min allowed altitude
@export var penalty = 10.0       # Penalty for flying too high

var distance_to_ground = 0
var time_in_altitude_range = 0.0
var fitness = 0.0

var genome: Genome

func _ready():
	genome = Genome.new(1, 3)  # Adjusted for more outputs
	setup_joints()

func get_distance_to_ground():
	# calulate distance to ground by y position
	return body.global_position.y
func _physics_process(delta):
	distance_to_ground = get_distance_to_ground()

	# Update fitness calculation each frame
	if min_altitude < distance_to_ground  and distance_to_ground < max_altitude:
		time_in_altitude_range += delta
	elif distance_to_ground >= max_altitude:
		fitness -= penalty * delta  # Penalize if out of range

func setup_joints():
	left_wing_joint.node_a = body.get_path()
	left_wing_joint.node_b = left_wing.get_path()
	right_wing_joint.node_a = body.get_path()
	right_wing_joint.node_b = right_wing.get_path()

func flap_wing(wing: RigidBody3D, direction: int):
	wing.apply_torque(Vector3(0, 0, -flap_force * direction))
	body.apply_force(Vector3.UP * flap_force, wing.global_position - body.global_position)

func move_forward():
	body.apply_central_impulse(Vector3.FORWARD * flap_force * 0.1)

func move_backward():
	body.apply_central_impulse(Vector3.BACK * flap_force * 0.1)

func descend():
	body.apply_central_impulse(Vector3.DOWN * flap_force * 0.1)

func calculate_fitness():
	fitness = time_in_altitude_range - (penalty * max(0, distance_to_ground - max_altitude))
	print("fitness: " + str(fitness))
	return fitness
    RSRC                    PackedScene            ��������                                                  ..    Body 	   LeftWing 
   RightWing    resource_local_to_scene    resource_name    lightmap_size_hint 	   material    custom_aabb    flip_faces    add_uv2    uv2_padding    size    subdivide_width    subdivide_height    subdivide_depth    script    custom_solver_bias    margin 	   _bundled       Script    res://organisms/swimmer.gd ��������   PackedScene    res://neat/genome.tscn o�{�b�'      local://BoxMesh_4ucxp �         local://BoxShape3D_pa0ue �         local://BoxShape3D_ppefw          local://BoxShape3D_4wikv >         local://PackedScene_1deju Y         BoxMesh             BoxShape3D            �?Q>  �?         BoxShape3D            �?��Z>  �?         BoxShape3D             PackedScene          	         names "   #      Bird    script    Node3D    Genome    num_inputs    num_outputs    LeftWingJoint 
   transform    node_a    node_b    angular_limit/enable    angular_limit/upper    HingeJoint3D    RightWingJoint    angular_limit/lower    angular_limit/bias    angular_limit/softness 	   LeftWing    RigidBody3D    flipper_left    mesh 	   skeleton    MeshInstance3D    CollisionShape3D    shape 
   RightWing    flipper_right    Body    axis_lock_angular_x    axis_lock_angular_y    axis_lock_angular_z    body    ray    target_position 
   RayCast3D    	   variants                                         �,~�    ���      �?    ��=    �,~������?f�R�                                   �a�?   ���    ��<      �?    ���    �����?<jD?��#�                �a��   {.?   ף<A     �?              �?              �?􉘿�N�>         �?            ��L>              �?                                         �?              �?              �?     Z�                  �?              �?              �?}�?�N�>         �?              �?              �?    ��_:                                �          node_count             nodes     �   ��������       ����                      ���                                       ����               	      
                              ����      	         	   
   
                                                ����                          ����                                      ����                                 ����                          ����                                      ����                                 ����                         
             ����                   
             ����                     "       ����   !                conn_count              conns               node_paths              editable_instances              version             RSRCextends Camera3D

@export var pan_speed = 0.005
@export var move_speed = 10.0

var is_panning = false
var last_mouse_position = Vector2.ZERO

func _ready():
	pass

func _process(delta):
	handle_keyboard_input(delta)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				last_mouse_position = event.position
			else:
				is_panning = false
	
	elif event is InputEventMouseMotion and is_panning:
		var mouse_delta = event.relative
		rotate_y(mouse_delta.x * -pan_speed)
		rotate_object_local(Vector3.RIGHT, mouse_delta.y * -pan_speed)

func handle_keyboard_input(delta):
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_axis("camera_left", "camera_right")
	input_dir.z = Input.get_axis("camera_up", "camera_back")
	
	if input_dir != Vector3.ZERO:
		translate(input_dir.normalized() * move_speed * delta)

	if Input.is_action_pressed("ui_accept"):
		translate(Vector3.UP * move_speed * delta)
    extends Node

class_name NeatController

       extends Node

@export var swimmer_node: PackedScene
@onready var time_start = Time.get_unix_time_from_system()
@onready var control

var brain: Brain
var population_size = 50
var birds = []

func _ready():
	control = get_parent().get_node("CanvasLayer/Control")
	# Initialize the Brain with 1 input (distance to ground) and 2 outputs (left and right wing flap)
	brain = Brain.new(1, 3, population_size)
	brain.generate()  # Generate initial population
	
	# Create bird instances
	for i in range(population_size):
		var bird = swimmer_node.instantiate()
		bird.genome =  Genome.new(1, 2).generate()  # Adjusted for more outputs
		add_child(bird)
		birds.append(bird)
		
		# Set isnitial position (you might want to adjust this)
		bird.global_position = Vector3(randf_range(-10, 10), 10, randf_range(-10, 10))
		
	# Assign genomes to birds
	update_bird_genomes()

func _physics_process(delta):
	for bird in birds:
		# Get distance to ground
		var distance = bird.get_distance_to_ground()
		
		# Run forward pass
		var outputs = bird.genome.forward([distance])
		
		# Apply flapping based on outputs
		if outputs[0] > 0.5:  # Threshold for left wing
			bird.flap_wing(bird.left_wing, 1)
		if outputs[1] > 0.5:  # Threshold for right wing
			bird.flap_wing(bird.right_wing, -1)
		if outputs[2] > 0.5:  # Threshold for descending
			bird.descend()
	
	# Check if it's time to evolve (you might want to adjust the condition)
	if Time.get_unix_time_from_system() - time_start > 10:  # Evolve every 10 seconds
		evolve_population()
		time_start = Time.get_unix_time_from_system()

func evolve_population():
	# Calculate fitness for each bird (you need to implement this based on your criteria)
	for i in range(population_size):
		var fitness = calculate_fitness(birds[i])
		brain.get_current().set_fitness(fitness)
		control.visualize_network(brain.get_current(), brain.get_current().get_nodes())
		brain.next_iteration()
	
	# Evolve the population
	brain.evolve()
	
	# Update bird genomes
	update_bird_genomes()
	
	# Reset bird positions
	for bird in birds:
		bird.global_position = Vector3(randf_range(-10, 10), 10, randf_range(-10, 10))

func update_bird_genomes():
	for i in range(population_size):
		birds[i].genome = brain.get_current()
		brain.next_iteration()

func calculate_fitness(bird):
	# Implement your fitness function here
	# For example, it could be based on how long the bird stays in the air
	# or how far it travels
	return bird.calculate_fitness()
    extends Node3D

@onready var controller = NeatController.new()
@onready var population = $Population
           RSRC                    PackedScene            ��������                                            }      resource_local_to_scene    resource_name    lightmap_size_hint 	   material    custom_aabb    flip_faces    add_uv2    uv2_padding    size    subdivide_width    subdivide_depth    center_offset    orientation    script    sky_top_color    sky_horizon_color 
   sky_curve    sky_energy_multiplier 
   sky_cover    sky_cover_modulate    ground_bottom_color    ground_horizon_color    ground_curve    ground_energy_multiplier    sun_angle_max 
   sun_curve    use_debanding    sky_material    process_mode    radiance_size    background_mode    background_color    background_energy_multiplier    background_intensity    background_canvas_max_layer    background_camera_feed_id    sky    sky_custom_fov    sky_rotation    ambient_light_source    ambient_light_color    ambient_light_sky_contribution    ambient_light_energy    reflected_light_source    tonemap_mode    tonemap_exposure    tonemap_white    ssr_enabled    ssr_max_steps    ssr_fade_in    ssr_fade_out    ssr_depth_tolerance    ssao_enabled    ssao_radius    ssao_intensity    ssao_power    ssao_detail    ssao_horizon    ssao_sharpness    ssao_light_affect    ssao_ao_channel_affect    ssil_enabled    ssil_radius    ssil_intensity    ssil_sharpness    ssil_normal_rejection    sdfgi_enabled    sdfgi_use_occlusion    sdfgi_read_sky_light    sdfgi_bounce_feedback    sdfgi_cascades    sdfgi_min_cell_size    sdfgi_cascade0_distance    sdfgi_max_distance    sdfgi_y_scale    sdfgi_energy    sdfgi_normal_bias    sdfgi_probe_bias    glow_enabled    glow_levels/1    glow_levels/2    glow_levels/3    glow_levels/4    glow_levels/5    glow_levels/6    glow_levels/7    glow_normalized    glow_intensity    glow_strength 	   glow_mix    glow_bloom    glow_blend_mode    glow_hdr_threshold    glow_hdr_scale    glow_hdr_luminance_cap    glow_map_strength 	   glow_map    fog_enabled    fog_light_color    fog_light_energy    fog_sun_scatter    fog_density    fog_aerial_perspective    fog_sky_affect    fog_height    fog_height_density    volumetric_fog_enabled    volumetric_fog_density    volumetric_fog_albedo    volumetric_fog_emission    volumetric_fog_emission_energy    volumetric_fog_gi_inject    volumetric_fog_anisotropy    volumetric_fog_length    volumetric_fog_detail_spread    volumetric_fog_ambient_inject    volumetric_fog_sky_affect -   volumetric_fog_temporal_reprojection_enabled ,   volumetric_fog_temporal_reprojection_amount    adjustment_enabled    adjustment_brightness    adjustment_contrast    adjustment_saturation    adjustment_color_correction 	   _bundled       Script    res://scenes/world.gd ��������   Script    res://scenes/NeatController.gd ��������   PackedScene    res://NetworkDiagram.tscn ����:Μ   Script    res://scenes/Camera3D.gd ��������   Script    res://scenes/Population.gd ��������   PackedScene    res://organisms/swimmer.tscn 6m\2	c2      local://PlaneMesh_1huik �      $   local://ProceduralSkyMaterial_s76w6 �         local://Sky_5vowm          local://Environment_cw4jq 0         local://PackedScene_guyik h      
   PlaneMesh             ProceduralSkyMaterial             Sky                         Environment             $                     PackedScene    |      	         names "         world    script    Node3D 
   CSGMesh3D 
   transform    use_collision    mesh    ground    CSGMesh3D2    NeatController    Node    CanvasLayer    Control    anchors_preset    offset_left    offset_top    grow_horizontal    grow_vertical    metadata/_edit_use_anchors_ 	   Camera3D    WorldEnvironment    environment    Population    swimmer_node    DirectionalLight3D    	   variants                    /]�B              �?            X9�B                               /]��1��3    �۶  ��            X9�BΈ<�6M�A�?d>                            �8D     �C           �?              �?              �?      �?  �@                                       2;?���=q=F?-�G�05>Û?�����0z��M>      �@          node_count    
         nodes     p   ��������       ����                            ����                                         ����                                   
   	   ����                           ����               ���                        	      
      
                           ����                                 ����                     
      ����                                 ����                   conn_count              conns               node_paths              editable_instances              version             RSRC   GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�m�m۬�}�p,��5xi�d�M���)3��$�V������3���$G�$2#�Z��v{Z�lێ=W�~� �����d�vF���h���ڋ��F����1��ڶ�i�엵���bVff3/���Vff���Ҿ%���qd���m�J�}����t�"<�,���`B �m���]ILb�����Cp�F�D�=���c*��XA6���$
2#�E.@$���A.T�p )��#L��;Ev9	Б )��D)�f(qA�r�3A�,#ѐA6��npy:<ƨ�Ӱ����dK���|��m�v�N�>��n�e�(�	>����ٍ!x��y�:��9��4�C���#�Ka���9�i]9m��h�{Bb�k@�t��:s����¼@>&�r� ��w�GA����ը>�l�;��:�
�wT���]�i]zݥ~@o��>l�|�2�Ż}�:�S�;5�-�¸ߥW�vi�OA�x��Wwk�f��{�+�h�i�
4�˰^91��z�8�(��yޔ7֛�;0����^en2�2i�s�)3�E�f��Lt�YZ���f-�[u2}��^q����P��r��v��
�Dd��ݷ@��&���F2�%�XZ!�5�.s�:�!�Њ�Ǝ��(��e!m��E$IQ�=VX'�E1oܪì�v��47�Fы�K챂D�Z�#[1-�7�Js��!�W.3׹p���R�R�Ctb������y��lT ��Z�4�729f�Ј)w��T0Ĕ�ix�\�b�9�<%�#Ɩs�Z�O�mjX �qZ0W����E�Y�ڨD!�$G�v����BJ�f|pq8��5�g�o��9�l�?���Q˝+U�	>�7�K��z�t����n�H�+��FbQ9���3g-UCv���-�n�*���E��A�҂
�Dʶ� ��WA�d�j��+�5�Ȓ���"���n�U��^�����$G��WX+\^�"�h.���M�3�e.
����MX�K,�Jfѕ*N�^�o2��:ՙ�#o�e.
��p�"<W22ENd�4B�V4x0=حZ�y����\^�J��dg��_4�oW�d�ĭ:Q��7c�ڡ��
A>��E�q�e-��2�=Ϲkh���*���jh�?4�QK��y@'�����zu;<-��|�����Y٠m|�+ۡII+^���L5j+�QK]����I �y��[�����(}�*>+���$��A3�EPg�K{��_;�v�K@���U��� gO��g��F� ���gW� �#J$��U~��-��u���������N�@���2@1��Vs���Ŷ`����Dd$R�":$ x��@�t���+D�}� \F�|��h��>�B�����B#�*6��  ��:���< ���=�P!���G@0��a��N�D�'hX�׀ "5#�l"j߸��n������w@ K�@A3�c s`\���J2�@#�_ 8�����I1�&��EN � 3T�����MEp9N�@�B���?ϓb�C��� � ��+�����N-s�M�  ��k���yA 7 �%@��&��c��� �4�{� � �����"(�ԗ�� �t�!"��TJN�2�O~� fB�R3?�������`��@�f!zD��%|��Z��ʈX��Ǐ�^�b��#5� }ى`�u�S6�F�"'U�JB/!5�>ԫ�������/��;	��O�!z����@�/�'�F�D"#��h�a �׆\-������ Xf  @ �q�`��鎊��M��T�� ���0���}�x^�����.�s�l�>�.�O��J�d/F�ě|+^�3�BS����>2S����L�2ޣm�=�Έ���[��6>���TъÞ.<m�3^iжC���D5�抺�����wO"F�Qv�ږ�Po͕ʾ��"��B��כS�p�
��E1e�������*c�������v���%'ž��&=�Y�ް>1�/E������}�_��#��|������ФT7׉����u������>����0����緗?47�j�b^�7�ě�5�7�����|t�H�Ե�1#�~��>�̮�|/y�,ol�|o.��QJ rmϘO���:��n�ϯ�1�Z��ը�u9�A������Yg��a�\���x���l���(����L��a��q��%`�O6~1�9���d�O{�Vd��	��r\�՜Yd$�,�P'�~�|Z!�v{�N�`���T����3?DwD��X3l �����*����7l�h����	;�ߚ�;h���i�0�6	>��-�/�&}% %��8���=+��N�1�Ye��宠p�kb_����$P�i�5�]��:��Wb�����������ě|��[3l����`��# -���KQ�W�O��eǛ�"�7�Ƭ�љ�WZ�:|���є9�Y5�m7�����o������F^ߋ������������������Р��Ze�>�������������?H^����&=����~�?ڭ�>���Np�3��~���J�5jk�5!ˀ�"�aM��Z%�-,�QU⃳����m����:�#��������<�o�����ۇ���ˇ/�u�S9��������ٲG}��?~<�]��?>��u��9��_7=}�����~����jN���2�%>�K�C�T���"������Ģ~$�Cc�J�I�s�? wڻU���ə��KJ7����+U%��$x�6
�$0�T����E45������G���U7�3��Z��󴘶�L�������^	dW{q����d�lQ-��u.�:{�������Q��_'�X*�e�:�7��.1�#���(� �k����E�Q��=�	�:e[����u��	�*�PF%*"+B��QKc˪�:Y��ـĘ��ʴ�b�1�������\w����n���l镲��l��i#����!WĶ��L}rեm|�{�\�<mۇ�B�HQ���m�����x�a�j9.�cRD�@��fi9O�.e�@�+�4�<�������v4�[���#bD�j��W����֢4�[>.�c�1-�R�����N�v��[�O�>��v�e�66$����P
�HQ��9���r�	5FO� �<���1f����kH���e�;����ˆB�1C���j@��qdK|
����4ŧ�f�Q��+�     [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bny0j1g685qw0"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                extends Control

var genome: Genome
var nodes: Dictionary
var node_names = ["a", "b", "c", "d"]

func _ready():
	custom_minimum_size = Vector2(300, 200)  # Set a minimum size

func _draw():
	var size_x = get_rect().size.x
	var size_y = get_rect().size.y

	# Clear the background
	draw_rect(Rect2(Vector2.ZERO, Vector2(size_x, size_y)), Color(0.1, 0.1, 0.1))

	if genome == null:
		draw_string(ThemeDB.fallback_font, Vector2(10, 20), "Waiting for data", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
		return

	# Draw nodes
	draw_nodes(size_x, size_y)

	# Draw connections
	draw_connections(size_x, size_y)

	# Draw node names and values
	draw_node_info(size_x, size_y)

func draw_nodes(size_x: float, size_y: float):
	for i in range(genome.num_inputs):
		var y = lerp(0.1, 0.9, float(i) / max(1, genome.num_inputs - 1))
		draw_circle(Vector2(0.1 * size_x, y * size_y), 5, Color.WHITE)

	for i in range(genome.unhidden):
		var y = lerp(0.1, 0.9, float(i) / max(1, genome.unhidden - 1))
		draw_circle(Vector2(0.5 * size_x, y * size_y), 5, Color.WHITE)

	for i in range(genome.num_outputs):
		var y = lerp(0.1, 0.9, float(i) / max(1, genome.num_outputs - 1))
		draw_circle(Vector2(0.9 * size_x, y * size_y), 5, Color.WHITE)

func draw_connections(size_x: float, size_y: float):
	for edge in genome.links.keys():
		var i = int(edge.split(",")[0])
		var j = int(edge.split(",")[1])
		
		var a: Vector2
		var b: Vector2
		
		# Determine the position of the source node (i)
		if i < genome.num_inputs:
			# Input node
			a = Vector2(0.1 * size_x, lerp(0.1, 0.9, float(i) / max(1, genome.num_inputs - 1)) * size_y)
		elif i < genome.num_inputs + genome.unhidden:
			# Hidden node
			a = Vector2(0.5 * size_x, lerp(0.1, 0.9, float(i - genome.num_inputs) / max(1, genome.unhidden - 1)) * size_y)
		else:
			# Output node (shouldn't be a source, but just in case)
			a = Vector2(0.9 * size_x, lerp(0.1, 0.9, float(i - genome.num_inputs - genome.unhidden) / max(1, genome.num_outputs - 1)) * size_y)
		
		# Determine the position of the target node (j)
		if j < genome.num_inputs:
			# Input node (shouldn't be a target, but just in case)
			b = Vector2(0.1 * size_x, lerp(0.1, 0.9, float(j) / max(1, genome.num_inputs - 1)) * size_y)
		elif j < genome.num_inputs + genome.unhidden:
			# Hidden node
			b = Vector2(0.5 * size_x, lerp(0.1, 0.9, float(j - genome.num_inputs) / max(1, genome.unhidden - 1)) * size_y)
		else:
			# Output node
			b = Vector2(0.9 * size_x, lerp(0.1, 0.9, float(j - genome.num_inputs - genome.unhidden) / max(1, genome.num_outputs - 1)) * size_y)
		
		# Draw the connection
		var color = Color.GREEN if genome.links[edge].weight > 0 else Color.RED
		draw_line(a, b, color, 2)

func draw_node_info(size_x: float, size_y: float):
	for i in range(genome.num_inputs):
		var y = lerp(0.1, 0.9, float(i) / max(1, genome.num_inputs - 1))
		draw_text(Vector2(0.1 * size_x + 10, y * size_y - 10), node_names[i], Color.WHITE)
		if i in nodes:
			draw_text(Vector2(0.1 * size_x - 20, y * size_y - 10), truncate(str(nodes[i].output)), Color.WHITE)

	for i in range(genome.unhidden):
		var y = lerp(0.1, 0.9, float(i) / max(1, genome.unhidden - 1))
		draw_text(Vector2(0.5 * size_x + 10, y * size_y - 10), str(i), Color.WHITE)
		if i + genome.num_inputs in nodes:
			draw_text(Vector2(0.5 * size_x - 20, y * size_y - 10), truncate(str(nodes[i + genome.num_inputs].output)), Color.WHITE)

	for i in range(genome.num_outputs):
		var y = lerp(0.1, 0.9, float(i) / max(1, genome.num_outputs - 1))
		draw_text(Vector2(0.9 * size_x + 10, y * size_y - 10), node_names[i + genome.num_inputs], Color.WHITE)
		if i + genome.num_inputs + genome.unhidden in nodes:
			draw_text(Vector2(0.9 * size_x - 20, y * size_y - 10), truncate(str(nodes[i + genome.num_inputs + genome.unhidden].output)), Color.WHITE)

func draw_text(pos: Vector2, text: String, color: Color):
	draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, color)

func _process(delta):
	queue_redraw()

func truncate(text: String) -> String:
	return text.substr(0, 5) if len(text) > 5 else text

func visualize_network(new_genome: Genome, new_nodes: Dictionary):
	genome = new_genome
	nodes = new_nodes
	queue_redraw()
    RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://NetworkDiagram.gd ��������      local://PackedScene_vbw64          PackedScene          	         names "         Control    layout_direction    layout_mode    anchors_preset    anchor_right    anchor_bottom    offset_left    offset_top    grow_horizontal    grow_vertical    size_flags_horizontal    size_flags_vertical    script    	   variants    	                          �?    �'D     �C                             node_count             nodes        ��������        ����                                                    	      
                            conn_count              conns               node_paths              editable_instances              version             RSRC             [remap]

path="res://.godot/exported/133200997/export-d42a4737021db34e7478aa19f2a4d7e7-gene.scn"
               [remap]

path="res://.godot/exported/133200997/export-551303407a3b7047388706423bbb9f84-genome.scn"
             [remap]

path="res://.godot/exported/133200997/export-3c7584b84430eee816dd365c81829d2b-node_gene.scn"
          [remap]

path="res://.godot/exported/133200997/export-3bfc78ea9e153e136ca81b26bf18a076-Client.scn"
             [remap]

path="res://.godot/exported/133200997/export-907aa51e66f33c3f537146f653aaa974-swimmer.scn"
            [remap]

path="res://.godot/exported/133200997/export-6b9c1b1fd6ae6f795188dfdc89e222b0-world.scn"
              [remap]

path="res://.godot/exported/133200997/export-842787de3048a3d1bbe152be62821a39-NetworkDiagram.scn"
     list=Array[Dictionary]([{
"base": &"Object",
"class": &"Brain",
"icon": "",
"language": &"GDScript",
"path": "res://neat/scripts/Brain.gd"
}, {
"base": &"Object",
"class": &"ConnectionGene",
"icon": "",
"language": &"GDScript",
"path": "res://neat/scripts/ConnectionGene.gd"
}, {
"base": &"Node",
"class": &"Gene",
"icon": "",
"language": &"GDScript",
"path": "res://neat/scripts/Gene.gd"
}, {
"base": &"Node",
"class": &"Genome",
"icon": "",
"language": &"GDScript",
"path": "res://neat/scripts/Genome.gd"
}, {
"base": &"Object",
"class": &"Hyperparameters",
"icon": "",
"language": &"GDScript",
"path": "res://neat/scripts/HyperParameters.gd"
}, {
"base": &"Node",
"class": &"NNode",
"icon": "",
"language": &"GDScript",
"path": "res://neat/scripts/NNode.gd"
}, {
"base": &"Node",
"class": &"Neat",
"icon": "",
"language": &"GDScript",
"path": "res://neat/scripts/neat.gd"
}, {
"base": &"Node",
"class": &"NeatController",
"icon": "",
"language": &"GDScript",
"path": "res://scenes/NeatController.gd"
}, {
"base": &"Object",
"class": &"NodeGene",
"icon": "",
"language": &"GDScript",
"path": "res://neat/scripts/NodeGene.gd"
}, {
"base": &"Object",
"class": &"Specie",
"icon": "",
"language": &"GDScript",
"path": "res://neat/scripts/Specie.gd"
}])
             <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 814 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H446l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z" fill="#478cbf"/><path d="M483 600c0 34 58 34 58 0v-86c0-34-58-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
           	   f�R�Qi   res://neat/Client.tscn���a_�?   res://neat/gene.tscno�{�b�'   res://neat/genome.tscn��w��`   res://neat/node_gene.tscn6m\2	c2   res://organisms/swimmer.tscn\�WNu{c   res://scenes/world.tscn�*2�Po}.   res://icon.svg����:Μ   res://NetworkDiagram.tscn���?�{   res://neat/Client.tscn       ECFG	      application/config/name         Creature Lab   application/run/main_scene          res://scenes/world.tscn    application/config/features$   "         4.2    Forward Plus       application/config/icon         res://icon.svg     dotnet/project/assembly_name         Creature Lab   input/camera_left�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   A   	   key_label             unicode    a      echo          script         input/camera_right�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   D   	   key_label             unicode    d      echo          script         input/camera_up�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   W   	   key_label             unicode    w      echo          script         input/camera_back�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   S   	   key_label             unicode    s      echo          script                