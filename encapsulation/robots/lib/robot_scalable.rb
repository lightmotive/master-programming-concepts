# frozen_string_literal: true

# This is a better-encapsulated version of the `robot_alt.rb` implementation.
# It also introduces new well-encapsulated functionality with classes that
# conceptualize related groups of behaviors.
#
# ** Scalability Considerations **
# Initializing many Robot instances in rapid succession, such as when
# bringing an entire Robot factory online, is CPU-intensive. So is resetting
# a batch of robots.
#
# The ./robot_alt.rb implementation solved the problem of quickly initializing
# robots, but left one problem unsolved: efficiently managing online robots.
# This implementation encapsulates core program aspects and uses binary search
# to support rapid robot management.
#
# Managing many robots efficiently requires maintaining a sorted list of them so
# they can be easily found using a binary search algorith. Ruby's core library
# includes Array methods that make binary search easy: `bsearch` and
# `bsearch_index`. Another Array method that's useful in conjunction with
# `bsearch_index` is `insert`, which enables inserting a new value into sorted
# position that's found using `bsearch_index`.
#
# With robot management capabilities, the program also needs to avoid slowing
# down batch robot maintenenace (e.g., quickly bringing an entire factory of
# robots online or resetting a robot group) with many sequential and repetitive
# `robots` array scan or sort operations. To accomplish that, the `RobotFactory`
# needs to support "batch maintenance" that modifies "single maintenance"
# behaviors as follows:
# - Complete batch maintenance, yielding robot instances to a block if given.
# - When batch processing is complete, complete post-batch operations like
#   sorting the `robots` array.
#   - As a relevant example, a single sort operation is much faster than trying
#     to maintain sort positions throughout batch processing.

# ** See benchmark setup, comparison, and analysis in ./robot_benchmark.rb **

# Generate and track usage of Robot names matching /\A[A-Z]{2}\d{3}\z/.
#
# Public behaviors:
# - `#use!`: shift a name from a pre-shuffled list of available names, then
#   block that name from further use until released.
# - `#release!(name)`: append the name to list of available names; returns `self`.
#
# Possible name permutations:
# - For each 2-upper-char letter combination, of which there are 676
#   permutations (26^2), there are 1,000 3-digit number permutations (10^3).
#   676 * 1000 = 676,000 possible names.
class RobotNames
  def initialize
    initialize_names!
  end

  def use!
    raise StandardError, 'All names are in use' if names.empty?

    names.shift
  end

  def release!(name)
    names << name
    self
  end

  private

  attr_reader :names

  def initialize_names!
    name_possibilities = letter_digit_sequences(2, 3)
    @names = name_possibilities.map do |letters, digits|
      letters.join + digits.join
    end
    @names.shuffle!
  end

  def letter_digit_sequences(letter_count, digit_count)
    letter_permutations = char_permutations('A'..'Z', letter_count)
    digit_permutations = char_permutations(0..9, digit_count)
    letter_permutations.enum_for(:product, digit_permutations) do
      # Calculate size without enumerating:
      letter_permutations.size * digit_permutations.size
    end
  end

  def char_permutations(char_range, length)
    char_range.to_a.repeated_permutation(length).to_a.uniq
  end
end

# A simple robot with a name (for now).
#
# Public behaviors:
# - `::new(name)`: assign unique name.
# - `#name`: return current `@name` value.
# - `#reset(new_name)`: currently assigns the provided new_name; would also
#   selectively reset internal state as the robot becomes more complex.
class Robot
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def reset(new_name)
    @name = new_name
  end

  def <=>(other)
    name <=> other.name
  end
end

class RobotList
  include Enumerable

  def initialize
    @robots = []
  end

  def each(&block)
    robots.each(&block)
  end

  def find(name)
    robots.bsearch { |r| name <=> r.name }
  end

  def delete(robot)
    delete_at_idx = robots.bsearch_index { |r| r.name <=> robot.name }
    return nil if delete_at_idx.nil?

    robots.delete_at(delete_at_idx)
  end

  def add(robot)
    insert_before_idx = robots.bsearch_index { |r| r.name > robot.name } ||
                        robots.size
    robots.insert(insert_before_idx, robot)
    robot
  end

  def add_batch(robot_array)
    robots.concat(robot_array)
    batch_maintenance_completed!
  end

  def batch_maintenance_completed!
    robots.sort_by!(&:name)
  end

  def [](*args)
    robots.[](*args)
  end

  def to_a
    robots.dup
  end

  private

  attr_reader :robots
end

# Create and manage robots with individual and batch management capabilities.
class RobotFactory
  def initialize
    @names = RobotNames.new
    @robots = RobotList.new
  end

  def create_robot
    robot = Robot.new(names.use!)
    robots.add(robot)
  end

  def create_robots(count)
    new_robots = []
    count.times do
      robot = Robot.new(names.use!)
      yield robot if block_given?
      new_robots << robot
    end
    robots.add_batch(new_robots)
    new_robots
  end

  def reset_robot(robot_or_name)
    robot = robot_by(robot_or_name)
    return if robot.nil?

    robots.delete(robot)
    robot_reset!(robot)
    robots.add(robot)
  end

  # Always returns Robot object array, even if array contains name strings.
  def reset_robots(robot_or_name_array)
    robots_reset = robot_or_name_array.map do |robot_or_name|
      robot = robot_by(robot_or_name)
      next if robot.nil?

      robot_reset!(robot)
      yield robot if block_given?
      robot
    end
    robots.batch_maintenance_completed!
    robots_reset
  end

  def shutdown_robot(name)
    robot = robots.find(name)
    return nil if robot.nil?

    names.release!(robot.name)
    robots.delete(robot)
  end

  def [](*args)
    robots.[](*args)
  end

  def robots_all
    robots.to_a
  end

  private

  attr_reader :names, :robots

  def robot_reset!(robot)
    names.release!(robot.name)
    robot.reset(names.use!)
  end

  def robot_by(element)
    return element if element.instance_of?(Robot)

    robots.find(element)
  end
end
