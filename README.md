# Lua ECS Library Benchmark

## Overview

This repository hosts a benchmark suite for popular Lua ECS (Entity-Component-System) libraries, aimed at comparing their performance in terms of memory and time consumption.

## Tested Libraries

- **[tiny-ecs](https://github.com/bakpakin/tiny-ecs)**: An ECS for Lua that's simple, flexible, and useful.
- **[concord](https://github.com/Keyslam-Group/Concord)**: A feature-complete ECS for LÖVE.
- **[ecs-lua](https://github.com/nidorx/ecs-lua)**: A full-featured ECS library for Lua.
- **[nata](https://github.com/tesselode/nata)**: Entity management for Lua.

### Pinned Versions

Libraries included as git submodules:

| Library | Commit |
|---------|--------|
| [Concord](https://github.com/Keyslam-Group/Concord) | [`848652f`](https://github.com/Keyslam-Group/Concord/tree/848652f68887db0c4261efe499facbec88959d03) |
| [ecs-lua](https://github.com/nidorx/ecs-lua) | [`c6be4a8`](https://github.com/nidorx/ecs-lua/tree/c6be4a85b13caf1f73facc816a08f20737e4e545) |
| [nata](https://github.com/tesselode/nata) | [`eb9d49b`](https://github.com/tesselode/nata/tree/eb9d49bdb32b964be9419f50dfec14e9adb1bcf0) |

## Benchmark Tests

This repository offers a suite of benchmarks designed to evaluate various aspects of popular Entity-Component-System (ECS) frameworks used in Lua. These benchmarks are tailored to assess key functionalities of ECS frameworks, including the efficiency of update systems, adding and removing components, and the dynamics of entity creation and management.

Each test measures memory usage and time consumption. Memory usage may not reflect absolute precision but should be sufficient for relative comparisons.

While these benchmarks offer valuable insights, it's important to understand that they focus on basic functionalities and do not entirely mimic real-world usage scenarios. Features like event messaging or serialization, which aren't covered in our tests, can greatly affect a framework's overall performance and suitability. That said, the results gleaned from these tests can provide useful information, helping guide decisions in choosing the most suitable ECS framework for your Lua applications.

## Running the Benchmarks

Install:

- [Lua 5.1+](https://www.lua.org/) (or [LuaJIT](https://luajit.org/)) & [Luarocks](https://luarocks.org)
- [Python 3.12+](https://www.python.org/) & [uv](https://docs.astral.sh/uv/): required to export the results.
- [Taskfile](https://taskfile.dev/): task runner

Run benchmarks with:

```bash
task
```

Libraries are automatically installed, provided the tools above are installed.

## Results

- `nata` is not displayed in plots and not tested for entities=100000 because of the very long execution time.
- The results are expressed in terms of **median** execution time and memory usage; _lower is better_.

### Benchmark environment

```
Lua Version: LuaJIT 2.1.1765228720 -- Copyright (C) 2005-2025 Mike Pall. https://luajit.org/
OS: Darwin
OS Version: Darwin Kernel Version 25.2.0: Tue Nov 18 21:07:05 PST 2025; root:xnu-12377.61.12~1/RELEASE_ARM64_T6020
Processor: arm64
Physical cores: 12
Total cores: 12
Min Frequency: 702.00Mhz
Max Frequency: 3504.00Mhz
Memory: 64.00GB
```

### Plots

Note that the y-axis is on a log scale.

#### add_component
![add_component Plot](results/img/add_component.svg)

#### add_components
![add_components Plot](results/img/add_components.svg)

#### add_empty_entity
![add_empty_entity Plot](results/img/add_empty_entity.svg)

#### add_entities
![add_entities Plot](results/img/add_entities.svg)

#### get_component
![get_component Plot](results/img/get_component.svg)

#### get_components
![get_components Plot](results/img/get_components.svg)

#### remove_component
![remove_component Plot](results/img/remove_component.svg)

#### remove_components
![remove_components Plot](results/img/remove_components.svg)

#### remove_entities
![remove_entities Plot](results/img/remove_entities.svg)

#### system_update
![system_update Plot](results/img/system_update.svg)

### Tables

#### 10 entities

##### Execution Time

| test              | concord   | ecs-lua    | lovetoys   | nata        | tinyecs    |
|:------------------|:----------|:-----------|:-----------|:------------|:-----------|
| add_component     | 3.88 µs   | 2.42 µs    | 5.62 µs    | 1.08 µs     | **625 ns** |
| add_components    | 13.2 µs   | 8.46 µs    | 17.8 µs    | **1.71 µs** | 2.08 µs    |
| add_empty_entity  | 34.8 µs   | 3.5 µs     | 2.79 µs    | 4.29 µs     | **958 ns** |
| add_entities      | 42 µs     | 9.88 µs    | 7.88 µs    | 4.58 µs     | **1.5 µs** |
| get_component     | 125 ns    | 167 ns     | **42 ns**  | 42 ns       | 42 ns      |
| get_components    | 167 ns    | 1.83 µs    | 83 ns      | **42 ns**   | 42 ns      |
| remove_component  | 28.4 µs   | 2.54 µs    | 2.96 µs    | **583 ns**  | 1.21 µs    |
| remove_components | 32.2 µs   | 4.5 µs     | 9.12 µs    | **583 ns**  | 1.12 µs    |
| remove_entities   | 68.4 µs   | **667 ns** | 1.04 µs    |             | 1.5 µs     |
| system_update     | 151 µs    | 3.62 µs    | **83 ns**  | 208 ns      | 15.3 µs    |

##### Memory Usage

| test              | concord   | ecs-lua   | lovetoys   | nata       | tinyecs    |
|:------------------|:----------|:----------|:-----------|:-----------|:-----------|
| add_component     | 2.5 kB    | 3.8 kB    | 4.7 kB     | **1.6 kB** | 1.7 kB     |
| add_components    | 7.5 kB    | 13.4 kB   | 13.2 kB    | **3.8 kB** | 3.8 kB     |
| add_empty_entity  | 5.9 kB    | 9.2 kB    | 5.3 kB     | 2.0 kB     | **1.8 kB** |
| add_entities      | 11.7 kB   | 20.0 kB   | 11.1 kB    | 4.2 kB     | **4.0 kB** |
| get_component     | **0 B**   | 859 B     | 0 B        | 0 B        | 0 B        |
| get_components    | **0 B**   | 2.3 kB    | 0 B        | 0 B        | 0 B        |
| remove_component  | 1.5 kB    | 1.7 kB    | 1.6 kB     | **0 B**    | 695 B      |
| remove_components | 1.8 kB    | 2.1 kB    | 4.7 kB     | **0 B**    | 695 B      |
| remove_entities   | 3.5 kB    | 1.1 kB    | **0 B**    |            | 703 B      |
| system_update     | 1.4 kB    | 5.0 kB    | **0 B**    | 0 B        | 2.7 kB     |

## Contributing

Contributions, including adding new tests or ECS libraries, are welcome.
