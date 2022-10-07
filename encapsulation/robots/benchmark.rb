# frozen_string_literal: true

# ** Benchmark setup **
class BenchmarkConfig
  attr_reader :create_count, :reset_count

  def initialize(benchmark_data)
    @load_path = benchmark_data[:load_path]
    @create_count = benchmark_data[:create_count] || 676_000
    @reset_count = benchmark_data[:reset_count] || 5
    @robots = []
  end

  def init
    puts "** #{load_path} Benchmark **"
    load load_path
    self
  end

  def create
    puts "Generating #{create_count} robots..."
    self
  end

  def reset
    puts "Resetting #{reset_count} robots..."
    self
  end

  def robot_count
    robots.size
  end

  protected

  attr_reader :load_path, :robots
end

class RobotBenchmarkConfig < BenchmarkConfig
  def create
    super
    robots << Robot.new while robots.size < create_count
    self
  end

  def reset
    super
    reset_count.times { |idx| robots[idx].reset }
    self
  end
end

class RobotFleetBenchmarkConfig < BenchmarkConfig
  def init
    super
    @fleet = RobotFleet.new
    self
  end

  def create
    super
    @fleet.create_robots(create_count)
    self
  end

  def reset
    super
    @fleet.reset_robots(@fleet[0...reset_count])
    self
  end

  def robot_count
    @fleet.robots_count
  end

  private

  attr_reader :fleet
end

class Benchmark
  def initialize(data)
    @config = data[:config_class].new(data)
  end

  def run
    bm_init
    bm_create
    bm_reset
  end

  private

  attr_reader :config

  def bm_init
    start_time = Time.now
    config.init
    puts "Init: #{seconds_round_fmt(Time.now - start_time, 3)} seconds"
  end

  def bm_create
    start_time = Time.now
    config.create
    format_result('Generated', config.robot_count, Time.now - start_time)
  end

  def bm_reset
    start_time = Time.now
    config.reset
    format_result('Reset', config.reset_count, Time.now - start_time)
  end

  def format_result(title, count, seconds)
    puts "#{title} #{count} robots in " \
         "~#{seconds_round_fmt(seconds, 2)} seconds " \
         "(~#{count.fdiv(seconds).floor}/sec)"
  end

  def seconds_round_fmt(seconds, decimal_places)
    format("%<sec>.#{decimal_places}f", sec: seconds)
  end
end

BENCHMARKS = {
  'robot': { name: 'robot',
             config_class: RobotBenchmarkConfig,
             load_path: '../../../ls-rb130-exercises/07_challenges/medium/robot.rb',
             create_count: nil, reset_count: nil },
  'robot_alt': { name: 'robot_alt',
                 config_class: RobotBenchmarkConfig,
                 load_path: '../../../ls-rb130-exercises/07_challenges/medium/robot_alt.rb',
                 create_count: nil, reset_count: 50_000 },
  'robot_scalable': { name: 'robot_scalable',
                      config_class: RobotFleetBenchmarkConfig,
                      load_path: './lib/robot_fleet.rb',
                      create_count: nil, reset_count: 50_000 }
}.freeze
BENCHMARK_NAMES = BENCHMARKS.keys.map(&:to_s).freeze

def select_benchmark_name
  puts 'Which benchmark do you want to run?'
  puts BENCHMARK_NAMES

  loop do
    print '> '
    input = gets.downcase.strip
    break input if BENCHMARK_NAMES.include?(input)

    puts 'Please enter a benchmark name listed above.'
  end
end

benchmark_name = ARGV[0] || select_benchmark_name
benchmark_data = BENCHMARKS[benchmark_name.to_sym]

Benchmark.new(benchmark_data).run

# ***
# robot.rb performance analysis
# - cmd: ruby robot_benchmark.rb robot
# ***
# Init: 0.005 seconds
# Generated 676000 robots in ~50.71 seconds (~13330/sec)
# Reset 10 robots in ~21.74 seconds (~0/sec)
#
# Analysis:
# - Reasonably fast implementation that slows to a crawl when all names are used
#   because it takes time to randomly generate and check what hasn't already
#   been used.
# - Performance will be inconsistent because of that random nature and the
#   binary search algorithm.
# - Reset time is very slow (less than 0.5 robots/sec) due to the slow creation
#   time when there are many robots in use. This would be much faster with
#   fewer active robots.
# - Because startup time is not impacted, this would be a good solution for
#   small-scale scenarios.

# ***
# robot_alt.rb performance analysis
# - cmd: ruby robot_benchmark.rb robot_alt
# ***
# Init: 0.636 seconds
# Generated 676000 robots in ~0.17 seconds (~3970996/sec)
# Reset 50000 robots in ~0.02 seconds (~2233476/sec)
#
# Analysis:
# - Init is slightly slower because it generates and shuffles all possible
#   names.
# - The startup performance penalty then yields vastly improved creation time
#   and consistent performance regardless of the number of active robots.
# - Reset time is virtually the same as creation time.
#
# Trade-offs due to generating and randomizing all possible names at program
# start:
# - Slightly slower startup time; probably not a problem in a scenario where a
#   class/fleet is initialized only occasionally.
# - Higher initial memory usage; we're not storing a lot of data, so it wouldn't
#   be an issue in most cases.

# ***
# robot_scalable.rb performance analysis
# - cmd: ruby robot_benchmark.rb robot_scalable
# ***
# Init: 0.656 seconds
# Generated 676000 robots in ~0.54 seconds (~1243186/sec)
# Reset 50000 robots in ~0.24 seconds (~205215/sec)
#
# Analysis:
# - Compared to ./robot_alt.rb, this implementation requires slightly more time
#   to batch-generate/reset robots because it tracks used names. Binary search
#   minimizes that added feature's performance impact.

# Choosing the best implementation would require knowing how many robots would
# be online at once, and how quickly those robots would need to be brought
# online.
