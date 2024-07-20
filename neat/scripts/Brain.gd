extends Resource
class_name Brain
const  SAVE_PATH = "res://saves/"
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

func purge_worst_species():
	"""Only keep top 10 species based on fitness"""
	_species.sort_custom(func(a, b): return b._fitness_sum - a._fitness_sum)
	_species = _species.slice(0, 10)
	

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
	
	# resets
	_current_species = 0
	_current_genome = 0

func should_evolve() -> bool:
	update_fittest()
	var fit = _global_best._fitness <= _hyperparams.max_fitness
	var end = _generation != _hyperparams.max_generations
	return fit and end

func next_iteration():
	if _species.is_empty():
		evolve()
		return

	var s = _species[_current_species]
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
	if _species.is_empty():
		return null

	var s = _species[_current_species]
	if s._members.is_empty():
		return null

	return s._members[_current_genome]

func get_current_species() -> int:
	return _current_species if not _species.is_empty() else -1

func get_current_genome() -> int:
	if _species.is_empty():
		return -1
	var s = _species[_current_species]
	return _current_genome if not s._members.is_empty() else -1

func get_generation() -> int:
	return _generation

func get_species() -> Array:
	return _species

# load genome.neat
static func load(filename: String) -> Brain:
	var file = FileAccess.open(filename, FileAccess.READ)
	if not file.file_exists(filename):
		print(filename)
		return null

	file.open(SAVE_PATH + filename + ".neat", FileAccess.READ)
	var inputs = int(file.get_line())
	var outputs = int(file.get_line())
	var brain = Brain.new(inputs, outputs)
	brain._generation = int(file.get_line())
	brain._current_species = int(file.get_line())
	brain._current_genome = int(file.get_line())
	brain._global_best = Genome.new(inputs, outputs)
	brain._global_best.load(file)
	brain._species = []
	var num_species = int(file.get_line())
	for i in range(num_species):
		var species = Specie.new(10)
		species.load(file)
		brain._species.append(species)
	file.close()
	return brain

func save_best_genome(filename: String):
	if _global_best:
		print("saving genome")
		_global_best.save("res://saves/" + filename)
