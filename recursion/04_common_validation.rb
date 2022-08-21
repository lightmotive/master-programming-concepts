class SomethingCustom
  attr_reader :default_scenario1, :default_scenario2, :invalid_scenario

  def initialize(default_scenario1: false, default_scenario2: false,
                 invalid_scenario: false)
    @default_scenario1 = default_scenario1
    @default_scenario2 = default_scenario2
    @invalid_scenario = invalid_scenario
  end

  def do_this
    validate_before_do do
      'Did this!'
    end
  end

  def do_that
    validate_before_do do
      'Did that!'
    end
  end

  def can_do?
    validate_before_do do
      true
    rescue StandardError
      false
    end
  end

  private

  attr_reader :something

  def validate_before_do
    return 'Default 1' if default_scenario1
    return 'Default 2' if default_scenario2
    raise StandardError if invalid_scenario

    yield # Validated, so yield to block that depends on validation
  end
end

puts SomethingCustom.new.do_this # => Did this!
puts SomethingCustom.new.do_that # => Did that!
puts SomethingCustom.new(default_scenario1: true).do_this # => Default 1
puts SomethingCustom.new(invalid_scenario: true).do_this # => raises StandardError
