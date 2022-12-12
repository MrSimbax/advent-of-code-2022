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

## Tests

### Puzzle Answers

Answers from the solutions can be checked with the `run_all.lua` script. Create an `answers.txt` file which in line `i` contains the two solutions for day `i` separated by comma. For example, for the first six days the file should look something like this (the values are arbitrary):

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
