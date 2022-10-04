# frozen_string_literal: true

# ** Benchmark setup **
class RobotBenchmarkConfig
  attr_reader :create_count, :reset_count, :robots

  def initialize(load_path, create_count: 676_000, reset_count: 5)
    @load_path = load_path
    @create_count = create_count
    @reset_count = reset_count
    @robots = []
  end

  def init
    puts "** #{load_path} Benchmark **"
    load load_path
  end

  def create
    puts "Generating #{create_count} robots..."
  end

  def reset
    puts "Resetting #{reset_count} robots..."
  end

  protected

  attr_reader :load_path
end

class RobotBenchmarkNonFactoryConfig < RobotBenchmarkConfig
  def create
    super
    robots << Robot.new while robots.size < create_count
    self
  end

  def reset
    super
    reset_count.times { |idx| robots[idx].reset }
  end
end

class RobotBenchmarkFactoryConfig < RobotBenchmarkConfig
  def init
    super
    @factory = RobotFactory.new
  end

  def create
    super
    @factory.create_robots(create_count)
  end

  def reset
    super
    @factory.reset_robots(@factory[0...reset_count])
  end

  def robots
    @factory.robots_all
  end

  private

  attr_reader :factory
end

class RobotBenchmark
  def initialize(config)
    @config = config
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
    format_result('Generated', config.robots.size, Time.now - start_time)
  end

  def bm_reset
    config.robots.shuffle!
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

case ARGV[0]
when 'robot' then RobotBenchmark.new(
  RobotBenchmarkNonFactoryConfig.new(
    '../../../ls-rb130-exercises/07_challenges/medium/robot.rb'
  )
).run
when 'robot_alt' then RobotBenchmark.new(
  RobotBenchmarkNonFactoryConfig.new(
    '../../../ls-rb130-exercises/07_challenges/medium/robot_alt.rb',
    reset_count: 50_000
  )
).run
when 'robot_scalable' then RobotBenchmark.new(
  RobotBenchmarkFactoryConfig.new('./lib/robot_factory.rb', reset_count: 50_000)
).run
end

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
#   class/factory is initialized only occasionally.
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
