# My Solutions for Advent of Code 2022

Solutions are written for [Lua 5.4](https://www.lua.org/) but are compatible with (much faster) [LuaJIT](https://luajit.org/).

## Goals

1. To have fun.
2. To improve as a programmer and problem solver.
3. To code some personal general little libraries for use with Lua (the result can be seen in the `libs` directory).
4. To have a good balance between performance and code readability.
5. To learn more about Lua.

## Running

Download your puzzle input from the [AoC website](https://adventofcode.com/2022) and redirect the file to the standard input of the program for the particular day. For example, the following command runs the solution for day 1 assuming the input is in a file named `input_1.txt`.

```bash
lua day_1.lua < input_1.txt
```

## Benchmark

Put all your inputs in the root directory of this repository, name them `input_$day.txt`. For example, `input_1.txt` for day 1, `input_2.txt` for day 2, and so on. Then run the following command.

```bash
./run_all.sh
```

The script will run all solutions in order and sum the times from the output.

You can specify the Lua command to run as the first argument for the script. For example, assuming `luajit` is in the `PATH` environment variable.

```bash
./run_all.sh luajit
```

Note that both the inputs and the puzzle descriptions are [copyrighted](https://www.reddit.com/r/adventofcode/wiki/faqs/copyright/puzzle_texts/) which is why they are not included in this repository.
