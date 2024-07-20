extends Node
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
