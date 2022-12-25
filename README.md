# My Solutions for Advent of Code 2022

Solutions are written for [Lua 5.4](https://www.lua.org/) but are compatible with (much faster) [LuaJIT](https://luajit.org/).

## Goals

1. To have fun.
2. To improve as a programmer and problem solver.
3. To code some personal general little libraries for use with Lua (the result can be seen in the `libs` directory).
4. To have a good balance between performance and code readability.
5. To learn more about Lua.
6. To minimize the usage of 3rd party libraries.

## Running

Download your puzzle input from the [AoC website](https://adventofcode.com/2022) and redirect the file to the standard input of the program for the particular day. For example, the following command runs the solution for day 1 assuming the input is in a file named `input_1.txt`.

```bash
lua day_1.lua < input_1.txt
```

**Note** that both the inputs and the puzzle descriptions are [copyrighted](https://www.reddit.com/r/adventofcode/wiki/faqs/copyright/puzzle_texts/) which is why they are not included in this repository.

## Benchmark

Put all your inputs in the root directory of this repository, name them `input_$day.txt`. For example, `input_1.txt` for day 1, `input_2.txt` for day 2, and so on. Then run the following command.

```bash
lua run_all.lua
```

The script will run all solutions in order and sum the times from the output. It runs solutions in the same Lua instance the script is run with, so if you run it with LuaJIT they will also run with LuaJIT.

### Results

Here are example results from running all solutions on my inputs.

```plain
Ranking (from slowest to fastest)
 1. Day 23 took 9.187685 s.
 2. Day 20 took 3.858578 s.
 3. Day 16 took 2.341249 s.
 4. Day 24 took 1.606584 s.
 5. Day 19 took 0.656611 s.
 6. Day 17 took 0.254634 s.
 7. Day 11 took 0.160950 s.
 8. Day  9 took 0.076270 s.
 9. Day  8 took 0.051646 s.
10. Day 14 took 0.029913 s.
11. Day 12 took 0.026426 s.
12. Day 18 took 0.022622 s.
13. Day 22 took 0.019746 s.
14. Day  3 took 0.003781 s.
15. Day 21 took 0.003021 s.
16. Day 13 took 0.002250 s.
17. Day  7 took 0.001031 s.
18. Day  6 took 0.000844 s.
19. Day  5 took 0.000807 s.
20. Day  2 took 0.000678 s.
21. Day  4 took 0.000468 s.
22. Day 15 took 0.000205 s.
23. Day  1 took 0.000139 s.
24. Day 10 took 0.000090 s.
25. Day 25 took 0.000088 s.
Total time taken is 18.306316 s.
```

Ranking for LuaJIT is as follows.

```plain
Ranking (from slowest to fastest)
 1. Day 23 took 1.692535 s.
 2. Day 24 took 0.407493 s.
 3. Day 20 took 0.307804 s.
 4. Day 16 took 0.212727 s.
 5. Day 17 took 0.198889 s.
 6. Day 19 took 0.146560 s.
 7. Day  9 took 0.026662 s.
 8. Day 11 took 0.024901 s.
 9. Day 18 took 0.023238 s.
10. Day 14 took 0.018946 s.
11. Day 12 took 0.016392 s.
12. Day  8 took 0.011467 s.
13. Day 22 took 0.008641 s.
14. Day 13 took 0.003207 s.
15. Day 21 took 0.002474 s.
16. Day  3 took 0.002289 s.
17. Day  7 took 0.000811 s.
18. Day  5 took 0.000598 s.
19. Day  6 took 0.000570 s.
20. Day  4 took 0.000423 s.
21. Day  2 took 0.000414 s.
22. Day 10 took 0.000254 s.
23. Day 15 took 0.000165 s.
24. Day  1 took 0.000094 s.
25. Day 25 took 0.000076 s.
Total time taken is 3.107630 s.
```

## Tests

### Puzzle Answers

Answers from the solutions can be checked with the `run_all.lua` script. Create the `answers.txt` file which in line `i` contains the two solutions for day `i` separated by comma. For example, for the first six days the file should look something like this (the values are arbitrary):

```plain
123,321
5,10
24,56
987,654
ABCDEFGHJ,FGYBJLAFA
123849078,3987
```

Some puzzles have strings as solutions. If the output string has multiple lines, like in day 10, it must be still in the same line in `answers.txt`: replace new line characters with `\n`. For example, the answers for day 10 should look like the following (note that the real answer for part 2 will be much longer).

```plain
213,\n####....####\n#..##...##..
```

### Unit Tests

The `spec` folder contains unit tests for the code inside the `libs` directory. The tests are written with the [busted](https://lunarmodules.github.io/busted/) library (which breaks goals 3 and 6 unfortunately) and can be run by executing the following command in the root of the repository.

```sh
busted
```

The coverage is not full, as I'm focusing more on solving the puzzles instead of writing tests for the common code, and my free time is limited.
