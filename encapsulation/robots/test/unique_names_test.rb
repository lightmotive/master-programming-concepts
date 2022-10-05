# frozen_string_literal: true

require_relative 'test_helper'
require './lib/unique_names'

class UniqueNamesTest < MiniTest::Test
  def setup
    @names = UniqueNames.new
  end

  def test_sequences_enumerator_size
    assert_equal(676_000, @names.sequences.size)
    p @names.sequences.to_a[0..4]
  end
end
