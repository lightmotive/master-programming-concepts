# frozen_string_literal: true

require_relative 'unique_names'
require_relative 'fast_list'
require_relative 'robot'

# Create and manage robots with individual and batch management capabilities.
class RobotFactory
  def initialize
    @names = UniqueNames.new
    @robots = FastList.new
  end

  def create_robot
    robot = robot_create!
    robots.add(robot)
  end

  def create_robots(count)
    robots.add_count(count) do
      robot = robot_create!
      yield robot if block_given?
      robot
    end

    self
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
    robots_to_reset = robot_or_name_array.map(&method(:robot_by))
    robots.batch_process do
      robots_to_reset.each do |robot|
        robot_reset!(robot)
        yield robot if block_given?
      end
    end
    robots_to_reset
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

  def robots_count
    robots.size
  end

  def robots_to_a
    robots.to_a
  end

  private

  attr_reader :names, :robots

  def robot_create!
    Robot.new(names.use!)
  end

  def robot_reset!(robot)
    names.release!(robot.name)
    robot.reset(names.use!)
  end

  def robot_by(element)
    return element if element.is_a?(Robot)
    return robots.find { |item| element <=> item.name } if element.is_a?(String)

    raise StandardError, "element must be a #{Robot.name} or a String."
  end
end
