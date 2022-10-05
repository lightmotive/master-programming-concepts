# frozen_string_literal: true

require_relative 'test_helper'
require './lib/robot_factory'

class RobotFactoryTest < Minitest::Test
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
    robots = @factory.create_robots(676_000).robots_all
    assert_equal(create_count, robots.map(&:name).uniq.size)
  end

  def test_reset_robots_returns_array_of_original_objects_with_new_names
    robots = @factory.create_robots(5).robots_all
    original_robot_names = robots.map(&:name)
    reset_robots = @factory.reset_robots(robots)
    assert_equal(robots.map(&:object_id), reset_robots.map(&:object_id))
    assert_equal(0, original_robot_names.intersection(reset_robots.map(&:name)).size)
  end

  def test_reset_robots_by_name
    robots = @factory.create_robots(3).robots_all
    original_robot_names = robots.map(&:name)
    reset_robots = @factory.reset_robots(original_robot_names)
    assert_equal(0, original_robot_names.intersection(reset_robots.map(&:name)).size)
  end

  def test_reset_invalid_object_raises_exception
    assert_raises(StandardError) { @factory.create_robots(3).reset_robot(1) }
  end

  def test_shutdown_robot
    robots = @factory.create_robots(3).robots_all
    @factory.shutdown_robot(robots[1])
    robots.delete(robots[1])
    assert_equal(robots, @factory.robots_all)
  end

  def test_count_online
    @factory.create_robots(3)
    assert_equal(3, @factory.count_online)
  end

  def test_index_lookup
    robots = @factory.create_robots(5).robots_all
    assert_same(robots[2], @factory[2])
  end
end
