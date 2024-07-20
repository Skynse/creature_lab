extends Object
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
