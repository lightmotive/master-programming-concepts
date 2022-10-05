# frozen_string_literal: true

require_relative 'test_helper'
require './lib/fast_list'

class FastListTest < MiniTest::Test
  class TestItem
    include Comparable

    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def <=>(other)
      value <=> other.value
    end
  end

  def setup
    @default_items = 5.times.map { |idx| TestItem.new((idx + 1).to_s) }
    @list = FastList.new
    @list.add_count(5) { |idx| @default_items[idx] }
  end

  def test_default_items_exist
    assert_equal(@default_items, @list.to_a)
  end

  def test_size
    assert_equal(@default_items.size, @list.size)
  end

  def test_get_at_index
    assert_same(@default_items[1], @list[1])
  end

  def test_get_slice
    assert_equal(@default_items[1, 3], @list[1, 3])
  end

  def test_get_range
    assert_equal(@default_items[2..3], @list[2..3])
  end

  def test_find_by_item
    assert_equal(@default_items[2], @list.find(@default_items[2]))
  end

  def test_find_with_block
    assert_equal(@default_items[3], @list.find { |item| @default_items[3] <=> item })
    assert_equal(@default_items[2], @list.find { |item| item > @default_items[1] })
  end

  def test_add_is_sorted
    item_to_add = TestItem.new('9')
    @list.add(item_to_add)
    assert_equal((@default_items << item_to_add).sort, @list.to_a)
    second_item_to_add = TestItem.new('8')
    @list.add(second_item_to_add)
    assert_equal((@default_items << second_item_to_add).sort, @list.to_a)
  end

  def test_add_count_is_sorted
    list = FastList.new
    list.add_count(3, &:-@)
    assert_equal([-2, -1, 0], list.to_a)
  end

  def test_delete
    @list.delete(@default_items[2])
    @default_items.delete(@default_items[2])
    assert_equal(@default_items, @list.to_a)
  end

  def test_batch_mutate
    @list.batch_mutate { @default_items[1].value = '0' }
    assert_equal(@default_items.sort, @list.to_a)
  end

  def test_mutate_one
    @list.mutate_one(@default_items[1]) { |item| item.value = '0' }
    @default_items.sort!
    assert_equal(@default_items, @list.to_a)
    assert_raises(NameError) do
      @list.mutate_one(@default_items[3], &:fake_method)
    end
    assert_equal(@default_items, @list.to_a)
  end
end
