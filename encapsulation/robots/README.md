# Robots

## Encapsulation and scalability

This small program was inspired by Launch School's [Robot Name exercise](https://launchschool.com/exercises/9302dd42).

My [original solution (robot.rb)](https://github.com/lightmotive/ls-rb130-exercises/blob/main/07_challenges/medium/robot.rb) and [alternative solution (robot_alt.rb)](https://github.com/lightmotive/ls-rb130-exercises/blob/main/07_challenges/medium/robot_alt.rb) both touched on encapsulation and scalability.

Here, I further explore encapsulation and, to a lesser degree, scalability.

This is a better-encapsulated version of the `robot_alt.rb` implementation. It also introduces new well-encapsulated functionality with classes that conceptualize related groups of behaviors.

 ### Scalability considerations

With the original solution, initializing many `Robot` instances in rapid succession--imagine bringing an entire fleet of nanobots online--was CPU-intensive. So was resetting robots. The performance was good with lower numbers of potential robots, but slowed dramatically upon reaching the capacity of 676K robots.

The *alternative solution* linked above solved the problem of quickly initializing robots, but left one problem unsolved: efficiently managing online robots.

This program encapsulates core components and uses a binary search algorithm to support rapid robot management like reset, shutdown, and any other future feature that requires finding bots that have a specific state.

Managing many robots efficiently requires maintaining a sorted list of them so they can be located using binary search. Ruby's core library offers that through the `bsearch` and `bsearch_index` Array methods. Another Array method that's useful in conjunction with `bsearch_index` is `insert`, which enables inserting a new value into sorted position that was determined using `bsearch_index`.

With new robot management capabilities, the program also needs a feature that prevents slowing down batch robot maintenenace with many sequential and repetitive `robots` array scan/sort operations. To accomplish that, the `RobotFleet` needs to support "batch maintenance" that modifies "individual maintenance" behaviors as follows:

- Complete batch maintenance that requires re-sorting the array, yielding robot instances to a block if given.
- When batch processing is complete, execute post-batch operations like sorting the `robots` array.
  - A single sort operation is much faster than trying to maintain sort positions throughout batch processing.

See benchmark setup, comparison, and analysis in [benchmark.rb](benchmark.rb).
