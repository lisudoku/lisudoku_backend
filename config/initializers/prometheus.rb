registry = Prometheus::Client.registry
$PUZZLE_RANDOM_COUNTER = Prometheus::Client::Counter.new(
  :puzzle_random_requests_total,
  docstring: 'A user loads a random puzzle',
  labels: [:variant, :difficulty]
)
$PUZZLE_SOLVED_COUNTER = Prometheus::Client::Counter.new(
  :puzzle_solved_total,
  docstring: 'A user correctly solved puzzle',
  labels: [:variant, :difficulty]
)
registry.register($PUZZLE_RANDOM_COUNTER)
registry.register($PUZZLE_SOLVED_COUNTER)
