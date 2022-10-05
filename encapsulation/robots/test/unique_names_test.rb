# frozen_string_literal: true

require_relative 'test_helper'
require './lib/unique_names'

class UniqueNamesTest < MiniTest::Test
  DIFFERENT_NAME_SEED = 1234
  DEFAULT_NAME_REGEXP = /\A[A-Z]{1}\d{1}\z/.freeze
  DEFAULT_UNIQUE_NAME_COUNT = 260

  def setup
    @names = UniqueNames.new(1, 1)
  end

  def test_default_name_format
    assert_match DEFAULT_NAME_REGEXP, @names.use!
  end

  def test_all_names_unique
    names = @names.sequences.size.times.map { @names.use! }
    assert_equal(DEFAULT_UNIQUE_NAME_COUNT, names.uniq.size)
    assert_empty(@names.to_a)
    error = assert_raises(StandardError) { @names.use! }
    assert_equal('No names available', error.message)
  end

  def test_sequences_enumerator_size
    assert_equal(DEFAULT_UNIQUE_NAME_COUNT, @names.sequences.size)
  end

  def test_release_name
    Kernel.srand DIFFERENT_NAME_SEED
    name = @names.use!
    @names.release!(name)
    name2 = @names.use!
    refute_equal name, name2
    assert_match DEFAULT_NAME_REGEXP, name2
  end

  def test_released_names_are_returned_to_end_of_available_names
    names = []
    3.times { names << @names.use! }
    names.each { |name| @names.release!(name) }
    assert_equal(names, @names[-3, 3])
  end

  def test_custom_name_formats
    names_default = UniqueNames.new
    assert_match(/\A[A-Z]{2}\d{3}\z/, names_default.use!)
    assert_equal(676_000, names_default.sequences.size)
    names2 = UniqueNames.new(3, 2)
    assert_match(/\A[A-Z]{3}\d{2}\z/, names2.use!)
    assert_equal(1_757_600, names2.sequences.size)
  end
end
