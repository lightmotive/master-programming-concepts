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
    @list = FastList.new
    @list.add_count(5) { |idx| idx }
    @default_items = 5.times.map.to_a
  end

  def test_default_items_exist
    assert_equal(@default_items, @list.to_a)
  end

  def test_size
    assert_equal(@default_items.size, @list.size)
  end

  def test_get_at_index
    assert_equal(1, @list[1])
  end

  def test_get_range
    assert_equal([2, 3], @list[2..3])
  end

  def test_find_by_item
    assert_equal(2, @list.find(2))
  end

  def test_find_with_block
    assert_equal(1, @list.find { |item| 1 <=> item })
    assert_equal(3, @list.find { |item| item > 2 })
  end

  def test_add_is_sorted
    item_to_add = @default_items.last + 10
    @list.add(item_to_add)
    assert_equal((@default_items << item_to_add).sort, @list.to_a)
    second_item_to_add = @default_items[-2] + 1
    @list.add(second_item_to_add)
    assert_equal((@default_items << second_item_to_add).sort, @list.to_a)
  end

  def test_add_count_is_sorted
    list = FastList.new
    list.add_count(3, &:-@)
    assert_equal([-2, -1, 0], list.to_a)
  end

  def test_delete
    @list.delete(2)
    @default_items.delete(2)
    assert_equal(@default_items, @list.to_a)
  end

  def test_batch_process
    list = FastList.new
    items = 3.times.map { |idx| TestItem.new(idx + 1) }.to_a
    list.add_count(items.size) { |idx| items[idx] }
    list.batch_mutate { items[1].value = -1 }
    assert_equal(-1, items[1].value)
    assert_equal(items.sort, list.to_a)
  end
end
