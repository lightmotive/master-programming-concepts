# frozen_string_literal: true

# A simple robot with a name (for now).
#
# Public behaviors:
# - `::new(name)`: assign unique name.
# - `#name`: return current `@name` value.
# - `#reset(new_name)`: currently assigns the provided new_name; would also
#   selectively reset internal state as the robot becomes more complex.
class Robot
  include Comparable

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
