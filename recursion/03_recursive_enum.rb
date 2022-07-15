def merge1(l1, l2)
  Enumerator.new do |yielder|
    h = case l1.peek <=> l2.peek
        when -1 then l1.next
        when +1 then l2.next
        else l1.next
             l2.next
        end
    yielder << h
    merge1(l1, l2).each do |h| # <----
      yielder << h             # <----
    end                        # <----
  end.lazy
end

def merge2(l1, l2)
  Enumerator.new do |yielder|
    loop do
      h = case l1.peek <=> l2.peek
          when -1 then l1.next
          when +1 then l2.next
          else l1.next
               l2.next
          end
      yielder << h
    end
  end.lazy
end

def merge3(l1, l2, &block)
  h = case l1.peek <=> l2.peek
      when -1 then l1.next
      when +1 then l2.next
      else l1.next
           l2.next
      end

  yield h

  merge3(l1, l2, &block)
end

# merge3 solution posted on SO: https://stackoverflow.com/a/72987311/2033465

require_relative '../../ruby-common/benchmark_report'
require_relative '../../ruby-common/test'

TESTS = [
  { input: [-> { (1..Float::INFINITY).lazy.map { |x| x * 2 } },
            -> { (1..Float::INFINITY).lazy.map { |x| x * 3 } }],
    expected_output: [2, 3, 4, 6, 8, 9, 10, 12, 14, 15] },
  { input: [-> { (100..Float::INFINITY).lazy.map { |x| x * 2 } },
            -> { (100..Float::INFINITY).lazy.map { |x| x * 2.1 } }],
    expected_output: [200, 202, 204, 206, 208, 210.0, 212, 212.10000000000002, 214, 214.20000000000002] }
].freeze

def test_helper(method, input)
  send(method, input[0].call, input[1].call).first(10).to_a
end

def test_enum_for_helper(method, input)
  enum_for(method, input[0].call, input[1].call).lazy.first(10).to_a
end

run_tests('merge1', TESTS, ->(input) { test_helper(:merge1, input) })
run_tests('merge2', TESTS, ->(input) { test_helper(:merge2, input) })
run_tests('merge3', TESTS, ->(input) { test_enum_for_helper(:merge3, input) })

benchmark_report(1, 100, TESTS,
                 [
                   { label: 'merge1', method: ->(input) { test_helper(:merge1, input) } },
                   { label: 'merge2', method: ->(input) { test_helper(:merge2, input) } },
                   { label: 'merge3', method: ->(input) { test_enum_for_helper(:merge3, input) } }
                 ])
