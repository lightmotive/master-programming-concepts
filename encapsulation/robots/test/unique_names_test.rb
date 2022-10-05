# frozen_string_literal: true

require_relative 'test_helper'
require './lib/unique_names'

class UniqueNamesTest < MiniTest::Test
  DIFFERENT_NAME_SEED = 1234
  NAME_REGEXP = /\A[A-Z]{2}\d{3}\z/.freeze

  def setup
    @names = UniqueNames.new
    @default_unique_names_size = 676_000
  end

  def test_default_name_format
    assert_match NAME_REGEXP, @names.use!
  end

  def test_custom_name_formats
    format1 = /\A[A-Z]{1}\d{1}\z/
    names1 = UniqueNames.new(1, 1)
    assert_match(format1, names1.use!)
    format2 = /\A[A-Z]{3}\d{2}\z/
    names2 = UniqueNames.new(3, 2)
    assert_match(format2, names2.use!)
  end

  def test_all_names_unique
    names = @names.sequences.size.times.map { @names.use! }
    assert_equal(@default_unique_names_size, names.uniq.size)
    assert_empty(@names.to_a)
    error = assert_raises(StandardError) { @names.use! }
    assert_equal('No names available', error.message)
  end

  def test_sequences_enumerator_size
    assert_equal(@default_unique_names_size, @names.sequences.size)
  end

  def test_release_name
    Kernel.srand DIFFERENT_NAME_SEED
    name = @names.use!
    @names.release!(name)
    name2 = @names.use!
    refute_equal name, name2
    assert_match NAME_REGEXP, name2
  end

  def test_released_names_are_returned_to_end_of_available_names
    names = []
    3.times { names << @names.use! }
    names.each { |name| @names.release!(name) }
    assert_equal(names, @names[-3, 3])
  end
end
