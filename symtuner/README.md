This directory contains the instructions to use SymTuner.
For technical details, see our paper below:
* SymTuner: Maximizing the Power of Symbolic Execution by Adaptively Tuning External Parameters

## Install SymTuner

Official SymTuner implementation is in [`skkusal/symtuner`](https://github.com/skkusal/symtuner).
You can easily install it with your `pip`.

For example, in Ubuntu 20.04 LTS, use the following command:
```bash
$ sudo pip3 install git+https://github.com/skkusal/symtuner.git
# You can find symtuner executable in your system.
$ symtuner --help
```

## Test With SymTuner

*Note that, the target program **must** be compiled with GCov features and LLVM.
Please see [benchmarks](../benchmarks) to see how to compile project with required features.
We also privide a build script to build klee-testable projects.*

You can test perform **KLEE+SymTuner** on the program `grep-3.4` (which is built with the provided script) with the following command:
```bash
$ symtuner -t 3600 -s examples/spaces.json -d KLEE_SymTuner ../benchmarks/grep-3.4/obj-llvm/src/grep.bc ../benchmarks/grep-3.4/obj-gcov/src/grep 
```
Then, you will see the testing progress as follows:
```
...
2022-06-23 06:52:04 symtuner [INFO] All configuration loaded. Start testing.
2022-06-23 06:52:39 symtuner [INFO] Iteration: 1 Time budget: 30 Time elapsed: 34 Coverage: 1209 Bugs: 0
2022-06-23 06:53:14 symtuner [INFO] Iteration: 2 Time budget: 30 Time elapsed: 70 Coverage: 1548 Bugs: 0
2022-06-23 06:54:03 symtuner [INFO] Iteration: 3 Time budget: 30 Time elapsed: 118 Coverage: 1578 Bugs: 0
...
```
When SymTuner successfully terminates, you can see the following output:
```
...
2022-06-23 07:52:13 symtuner [INFO] SymTuner done. Achieve 3105 coverage and found 0 bugs.
```

## Usage

You can check the options of SymTuner and see the meaning of each option with the following command:
```
$ symtuner -h
usage: symtuner [-h] [--klee KLEE] [--klee-replay KLEE_REPLAY] [--gcov GCOV]
                [-s JSON] [--exploit-portion FLOAT] [--step INT]
                [--minimum-time-portion FLOAT] [--increase-ratio FLOAT]
                [--minimum-time-budget INT] [--exploration-steps INT]
                [-d OUTPUT_DIR] [--generate-search-space-json] [--debug]
                [--gcov-depth GCOV_DEPTH] [-t INT]
                [llvm_bc] [gcov_obj]

optional arguments:
  -h, --help            show this help message and exit                    
...
```

### Three mandatory options
**Three options** are mandatory to run SymTuner: **llvm_bc**, **gcov_obj** and **time budget**. 
**llvm_bc** indicates a location of an LLVM bitcode file to run KLEE, and **gcov_obj** is a location of an executable file with Gcov instrumentation for coverage calculation.
The option **`-t`** or **`--budget`** denotes the total testing time budget. 
| Option     | Description                  |
|:----------:|:-----------------------------|
| `--budget` | Total time budget in seconds |
| `llvm_bc`  | LLVM bitcode file            |
| `gcov_obj` | executable with Gcov support |


### Hyperparameters
The hyperparameter `--search-space` is very important in our tool. You can check all the hyperparameters by passing `--help` option to SymTuner.
| Option           | Description                                     |
|:----------------:|:------------------------------------------------|
| `--search-space` | Path to json file that defines parameter spaces |

If you do not specify search space, SymTuner will use the parameter spaces predefined in our paper.
You can give your own parameter space with `--search-space` option.
`--generate-search-space-json` option will generate an example json that defines search spaces:
```bash
$ symtuner --generate-search-space-json
# See example-space.json
```

In the json file, there are two entries;
`space` for parameters to be tuned by SymTuner, and `defaults` for parameters to use directly without tuning.
```json
{
    "space": {
        "-max-memory": [[500, 1000, 1500, 2000, 2500], 1],
        "-sym-stdout": [["on", "off"], 1],
        ...
    },
    "defaults": {
        "-watchdog": null,
        ...
    }
}
```
Each tuning space is defined by its candidate values, and the maximum number of times to be repeated.

You can find some examples of json files that defines search space in [examples](./examples).

### Notes
You may carefully pass the depth of parent directory to collect auxiliary files for Gcov.
You can set the level as the depth to the root of the target object.
| Option         | Description                                                                        |
|:--------------:|:-----------------------------------------------------------------------------------|
| `--gcov-depth` | The parent depth to find gcov auxiliary files, such as `*.gcda` and `*.gcov` files |

For example, you should set `--gcov-depth` to `0` (which is `1` by default) to test `gawk-5.1.0`:
```bash
$ symtuner -t 3600 --search-space examples/no-optimize.json --gcov-depth 0 ../benchmarks/gawk-5.1.0/obj-llvm/gawk.bc ../benchmarks/gawk-5.1.0/obj-gcov/gawk
```
