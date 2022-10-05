# frozen_string_literal: true

require_relative 'test_helper'
require './lib/unique_names'

class UniqueNamesTest < MiniTest::Test
  def setup
    @names = UniqueNames.new
    @default_unique_names_size = 676_000
  end

  def test_sequences_enumerator_size
    assert_equal(@default_unique_names_size, @names.sequences.size)
  end

  def test_use_all_names
    names = @names.sequences.size.times.map { @names.use! }
    assert_equal(@default_unique_names_size, names.uniq.size)
    assert_empty(@names.to_a)
    error = assert_raises(StandardError) { @names.use! }
    assert_equal('No names available', error.message)
  end

  def test_release_names
    names = []
    3.times { names << @names.use! }
    names.each { |name| @names.release!(name) }
    assert_equal(names, @names[-3, 3])
  end
end
