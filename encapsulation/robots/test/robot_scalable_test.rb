# frozen_string_literal: true

require 'minitest'
require 'minitest/autorun'
require './lib/robot_factory'

class RobotScalableTest < Minitest::Test
  DIFFERENT_ROBOT_NAME_SEED = 1234
  SAME_INITIAL_ROBOT_NAME_SEED = 1000
  NAME_REGEXP = /\A[A-Z]{2}\d{3}\z/.freeze

  def setup
    @factory = RobotFactory.new
  end

  def test_has_name
    assert_match NAME_REGEXP, @factory.create_robot.name
  end

  def test_name_sticks
    robot = @factory.create_robot
    robot.name
    assert_equal robot.name, robot.name
  end

  def test_different_robots_have_different_names
    Kernel.srand DIFFERENT_ROBOT_NAME_SEED
    refute_equal @factory.create_robot.name, @factory.create_robot.name
  end

  def test_reset_name
    Kernel.srand DIFFERENT_ROBOT_NAME_SEED
    robot = @factory.create_robot
    name = robot.name
    @factory.reset_robot(robot)
    name2 = robot.name
    refute_equal name, name2
    assert_match NAME_REGEXP, name2
  end

  def test_different_name_when_chosen_name_is_taken
    Kernel.srand SAME_INITIAL_ROBOT_NAME_SEED
    name1 = @factory.create_robot.name
    Kernel.srand SAME_INITIAL_ROBOT_NAME_SEED
    name2 = @factory.create_robot.name
    refute_equal name1, name2
  end

  def test_create_all_possible_robots
    create_count = 676_000
    robots = @factory.create_robots(676_000)
    assert_equal(create_count, robots.map(&:name).uniq.size)
  end
end
