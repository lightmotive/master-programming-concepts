# Robots

## Encapsulation and scalability

This small program was inspired by Launch School's [Robot Name exercise](https://launchschool.com/exercises/9302dd42).

My [original solution](https://github.com/lightmotive/ls-rb130-exercises/blob/main/07_challenges/medium/robot.rb) and [alternative solution](https://github.com/lightmotive/ls-rb130-exercises/blob/main/07_challenges/medium/robot_alt.rb) both touched on encapsulation and scalability.

Here, I further explore encapsulation and, to a lesser degree, scalability.

 This is a better-encapsulated version of the `robot_alt.rb` implementation. It also introduces new well-encapsulated functionality with classes that conceptualize related groups of behaviors.

 ### Scalability considerations

Initializing many Robot instances in rapid succession, such as when bringing an entire Robot factory online, is CPU-intensive. So is resetting a batch of robots.

The *alternative solution* linked above solved the problem of quickly initializing robots, but left one problem unsolved: efficiently [managing online robots. This implementation encapsulates core program aspects and uses binary search to support rapid robot management.

Managing many robots efficiently requires maintaining a sorted list of them so they can be easily found using a binary search algorith. Ruby's core library includes Array methods that make binary search easy: `bsearch` and `bsearch_index`. Another Array method that's useful in conjunction with `bsearch_index` is `insert`, which enables inserting a new value into sorted position that's found using `bsearch_index`.

With robot management capabilities, the program also needs to avoid slowing down batch robot maintenenace (e.g., quickly bringing an entire factory of robots online or resetting a robot group) with many sequential and repetitive `robots` array scan or sort operations. To accomplish that, the `RobotFactory` needs to support "batch maintenance" that modifies "individual maintenance" behaviors as follows:

- Complete batch maintenance, yielding robot instances to a block if given.
- When batch processing is complete, execute post-batch operations like sorting the `robots` array.
  - A single sort operation is much faster than trying to maintain sort positions throughout batch processing.

See benchmark setup, comparison, and analysis in [benchmark.rb](benchmark.rb).
