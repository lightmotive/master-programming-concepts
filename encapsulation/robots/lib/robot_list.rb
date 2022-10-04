# frozen_string_literal: true

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
