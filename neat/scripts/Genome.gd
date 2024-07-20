extends Resource
class_name Genome

var genome_id: int
@export var num_inputs: int
@export var num_outputs: int
@export var neurons: Dictionary # neuron_id: NodeGene 
@export var links: Dictionary # "i,j" : ConnectionGene

@export var fitness: float = 0
@export var adjusted_fitness: float = 0
@export var max_node: int
@export var unhidden: int
@export var default_activation: String

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

var activation_functions = {
	"sigmoid": sigmoid,
	"relu": relu,
	"leaky_relu": leaky_relu
}

func _init(_num_inputs: int, _num_outputs: int, _default_activation: String = "sigmoid"):
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
		
		neuron.output = activation_functions[neuron.activation_func].call(ax + neuron.bias)

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
	
	
	
func save(_file_path: String):
	var directory_path = "res://saves/"
	var file_path = directory_path + _file_path + ".neat"

	# Ensure the directory exists
	var dir = DirAccess.open(directory_path)
	if not dir.dir_exists(directory_path):
		dir.make_dir(directory_path)

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		print("Failed to open file for writing: " + file_path)
		return

	file.store_line(str(num_inputs))
	file.store_line(str(num_outputs))
	file.store_line(str(max_node))
	file.store_line(str(unhidden))
	file.store_line(str(fitness))
	file.store_line(str(adjusted_fitness))
	file.store_line(default_activation)
	file.store_line(str(neurons.size()))
	for n in neurons.keys():
		file.store_line(str(n) + "," + str(neurons[n].bias))
	file.store_line(str(links.size()))
	for l in links.keys():
		var nodes = l.split(",")
		file.store_line(nodes[0] + "," + nodes[1] + "," + str(links[l].weight) + "," + str(links[l].enabled))
	file.close()


func load(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("Failed to open file for reading: " + file_path)
		return
	
	num_inputs = int(file.get_line().strip_edges())
	num_outputs = int(file.get_line().strip_edges())
	max_node = int(file.get_line().strip_edges())
	unhidden = int(file.get_line().strip_edges())
	fitness = float(file.get_line().strip_edges())
	adjusted_fitness = float(file.get_line().strip_edges())
	default_activation = file.get_line().strip_edges()
	
	var num_neurons = int(file.get_line().strip_edges())
	print(num_neurons)
	for i in range(num_neurons):
		var line = file.get_line().strip_edges().split(",")
		print("adding neuron")
		neurons[int(line[0])] = NodeGene.new(default_activation, float(line[1]))

	var num_links = int(file.get_line().strip_edges())
	for i in range(num_links):
		var line = file.get_line().strip_edges().split(",")
		links[line[0] + "," + line[1]] = ConnectionGene.new(float(line[2]), line[3] == "true")
	
	file.close()
	self.generate()


func save_as_resource(file_path: String):
	var dict = _to_dict()
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		print("Failed to save resource: " + file_path)
		return
	file.store_string(JSON.stringify(dict))
	file.close()
	print("Resource saved: " + file_path)

func load_from_resource(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("Failed to load resource: " + file_path)
		return
	var dict = JSON.parse_string(file.get_as_text())
	_from_dict(dict)
	file.close()
	print("Resource loaded: " + file_path)

func _to_dict() -> Dictionary:
	var neurons_dict = {}
	for id in neurons.keys():
		neurons_dict[int(id)] = neurons[id]._to_dict()

	var links_dict = {}
	for key in links.keys():
		links_dict[key] = links[key]._to_dict()

	return {
		"num_inputs": num_inputs,
		"num_outputs": num_outputs,
		"max_node": max_node,
		"unhidden": unhidden,
		"fitness": fitness,
		"adjusted_fitness": adjusted_fitness,
		"default_activation": default_activation,
		"neurons": neurons_dict,
		"links": links_dict
	}

func _from_dict(dict: Dictionary):
	num_inputs = dict.get("num_inputs", 0)
	num_outputs = dict.get("num_outputs", 0)
	max_node = dict.get("max_node", 0)
	unhidden = dict.get("unhidden", 0)
	fitness = dict.get("fitness", 0.0)
	adjusted_fitness = dict.get("adjusted_fitness", 0.0)
	default_activation = dict.get("default_activation", "")

	neurons.clear()
	for id in dict["neurons"].keys():
		var node_gene = NodeGene.new()
		node_gene._from_dict(dict["neurons"][id])
		neurons[int(id)] = node_gene

	links.clear()
	for key in dict["links"].keys():
		var connection_gene = ConnectionGene.new()
		connection_gene._from_dict(dict["links"][key])
		links[key] = connection_gene
