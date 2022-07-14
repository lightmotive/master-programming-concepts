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
  yield merge3(l1, l2, &block).next
end

# merge3 posted on SO: https://stackoverflow.com/a/72987311/2033465

require_relative 'ruby-common/benchmark_report'
require_relative 'ruby-common/test'

TESTS = [
  { input: [-> { (1..Float::INFINITY).lazy.map { |x| x * 2 } },
            -> { (1..Float::INFINITY).lazy.map { |x| x * 3 } }],
    expected_output: [2, 3, 4, 6, 8, 9, 10, 12, 14, 15] }
].freeze

run_tests('merge1', TESTS, ->(input) { merge1(input[0].call, input[1].call).first(10).to_a })
run_tests('merge2', TESTS, ->(input) { merge2(input[0].call, input[1].call).first(10).to_a })
run_tests('merge3', TESTS, lambda { |input|
  enum_for(:merge3,
           input[0].call,
           input[1].call).lazy.first(10).to_a
})

benchmark_report(3, 50, TESTS,
                 [
                   { label: 'merge1', method: ->(input) { merge1(input[0].call, input[1].call).first(10).to_a } },
                   { label: 'merge2', method: ->(input) { merge2(input[0].call, input[1].call).first(10).to_a } },
                   { label: 'merge3', method: lambda { |input|
                                                enum_for(:merge3, input[0].call, input[1].call).lazy.first(10).to_a
                                              } }
                 ])
