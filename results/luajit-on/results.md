# Benchmark Environment

```text
OS: macOS 26.2
CPU: Apple M2 Max
Cores: 12 cores (12 threads)
Max Frequency: 3.50 GHz
Memory: 64 GB
```

- **[100 entities](#100-entities):**
  [Entity](#entity) · [Component](#component) · [Tag](#tag) · [System](#system)
- **[1000 entities](#1000-entities):**
  [Entity](#entity) · [Component](#component) · [Tag](#tag) · [System](#system)
- **[10000 entities](#10000-entities):**
  [Entity](#entity) · [Component](#component) · [Tag](#tag) · [System](#system)

## 100 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs     |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :---------- |
| create_empty           | 160 μs  | 55.9 μs              | 32.1 μs |               |                 | 43.8 μs  |                |                  | **15.9 μs** | 24.1 μs     |
| create_with_components | 129 μs  | 85.1 μs              |         | 104 μs        | 134 μs          | 112 μs   |                |                  | **18.7 μs** | 26.2 μs     |
| destroy                | 47.1 μs | 65.5 μs              | 19.8 μs |               |                 | 123 μs   |                |                  | 8.71 μs     | **4.62 μs** |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :--------------------- | :------- | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| create_empty           | 51.2 kB  | 26.9 kB              | 82.3 kB |               |                 | 64.2 kB  |                |                  | 22.2 kB | **20.0 kB** |
| create_with_components | 101.2 kB | 76.2 kB              |         | 174.5 kB      | 193.2 kB        | 110.1 kB |                |                  | 37.9 kB | **35.0 kB** |
| destroy                | 5.5 kB   | 4.0 kB               | 11.3 kB |               |                 | **0 B**  |                |                  | 3.2 kB  | 1.1 kB      |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| get    | 500 ns  | 417 ns               | 1.83 μs |               |                 | 875 ns   |                |                  | 292 ns  | **250 ns**  |
| set    | 542 ns  | 500 ns               | 1.92 μs |               |                 | 958 ns   |                |                  | 292 ns  | **250 ns**  |
| add    | 57.2 μs | 119 μs               |         | 66.8 μs       | 83.7 μs         |          | 56.2 μs        | 46.0 μs          | 4.67 μs | **3.67 μs** |
| remove | 43.6 μs | 133 μs               | 38.8 μs |               |                 | 30.7 μs  |                |                  | 2.04 μs | **1.79 μs** |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| get    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B      |                |                  | 0 B         | 0 B     |
| set    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B      |                |                  | 0 B         | 0 B     |
| add    | 29.0 kB | 29.0 kB              |         | 67.2 kB       | 67.2 kB         |          | 43.8 kB        | 35.2 kB          | **10.9 kB** | 12.1 kB |
| remove | 4.0 kB  | 4.0 kB               | 23.4 kB |               |                 | 15.6 kB  |                |                  | **0 B**     | 1.1 kB  |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :---------- |
| has    | 458 ns  | 417 ns               | 1.58 μs |               |                 | 333 ns   |                |                  | **125 ns** | 125 ns      |
| add    | 41.8 μs | 115 μs               |         | 55.7 μs       | 65.4 μs         |          | 50.0 μs        | 44.5 μs          | 3.50 μs    | **2.71 μs** |
| remove | 52.8 μs | 50.3 μs              | 43.9 μs |               |                 | 31.2 μs  |                |                  | 2.06 μs    | **1.79 μs** |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| has    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B      |                |                  | 0 B     | 0 B     |
| add    | 19.6 kB | 19.6 kB              |         | 51.5 kB       | 51.5 kB         |          | 35.2 kB        | 26.6 kB          | **0 B** | 1.1 kB  |
| remove | 4.0 kB  | 4.0 kB               | 23.4 kB |               |                 | 15.6 kB  |                |                  | **0 B** | 1.1 kB  |

### System

#### Execution Time

| test          | concord    | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :------------ | :--------- | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| throughput    | 750 ns     |                      | 5.65 μs |               |                 | 1.58 μs  |                |                  | 500 ns  | **417 ns**  |
| overlap       | **708 ns** |                      | 12.3 μs |               |                 | 1.71 μs  |                |                  | 750 ns  | 917 ns      |
| fragmented    | 500 ns     |                      | 13.8 μs |               |                 | 792 ns   |                |                  | 458 ns  | **417 ns**  |
| chained       | 2.19 μs    |                      | 25.0 μs |               |                 | 4.25 μs  |                |                  | 1.46 μs | **1.21 μs** |
| multi_20      | 7.21 μs    |                      | 67.9 μs |               |                 | 15.5 μs  |                |                  | 5.88 μs | **4.96 μs** |
| empty_systems | 1.21 μs    |                      | 2.46 μs |               |                 | 708 ns   |                |                  | 958 ns  | **292 ns**  |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 18.5 kB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 53.8 kB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 12.3 kB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 71.2 kB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 182.1 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

## 1000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| create_empty           | 754 μs  | 333 μs               | 553 μs  |               |                 | 352 μs   |                |                  | **43.8 μs** | 125 μs  |
| create_with_components | 3.62 ms | 1.02 ms              |         | 1.39 ms       | 1.43 ms         | 1.30 ms  |                |                  | **71.8 μs** | 154 μs  |
| destroy                | 744 μs  | 344 μs               | 130 μs  |               |                 | 10.6 ms  |                |                  | **88.6 μs** | 156 μs  |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata         | tinyecs  |
| :--------------------- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :----------- | :------- |
| create_empty           | 376.4 kB | 141.3 kB             | 667.6 kB |               |                 | 562.5 kB |                |                  | **62.5 kB**  | 71.4 kB  |
| create_with_components | 876.4 kB | 626.4 kB             |          | 1.6 MB        | 1.8 MB          | 1.0 MB   |                |                  | **218.8 kB** | 226.9 kB |
| destroy                | 32.0 kB  | 32.0 kB              | 81.3 kB  |               |                 | **0 B**  |                |                  | 24.2 kB      | 8.1 kB   |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :---------- |
| get    | 6.38 μs | 5.48 μs              | 27.7 μs |               |                 | 8.77 μs  |                |                  | 4.25 μs     | **4.08 μs** |
| set    | 7.00 μs | 5.88 μs              | 21.6 μs |               |                 | 9.67 μs  |                |                  | **4.33 μs** | 4.38 μs     |
| add    | 1.23 ms | 699 μs               |         | 793 μs        | 892 μs          |          | 571 μs         | 522 μs           | 51.8 μs     | **36.7 μs** |
| remove | 1.01 ms | 388 μs               | 364 μs  |               |                 | 321 μs   |                |                  | 20.3 μs     | **13.7 μs** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata         | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :----------- | :------- |
| get    | **0 B**  | 0 B                  | 85.9 kB  |               |                 | 0 B      |                |                  | 0 B          | 0 B      |
| set    | **0 B**  | 0 B                  | 85.9 kB  |               |                 | 0 B      |                |                  | 0 B          | 0 B      |
| add    | 282.0 kB | 282.0 kB             |          | 657.6 kB      | 657.6 kB        |          | 469.5 kB       | 383.6 kB         | **109.4 kB** | 117.5 kB |
| remove | 32.0 kB  | 32.0 kB              | 220.1 kB |               |                 | 156.2 kB |                |                  | **0 B**      | 8.1 kB   |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :---------- |
| has    | 5.33 μs | 4.33 μs              | 17.3 μs |               |                 | 3.25 μs  |                |                  | **2.17 μs** | 2.25 μs     |
| add    | 1.51 ms | 337 μs               |         | 660 μs        | 760 μs          |          | 549 μs         | 481 μs           | 40.6 μs     | **26.4 μs** |
| remove | 432 μs  | 918 μs               | 393 μs  |               |                 | 327 μs   |                |                  | 20.8 μs     | **13.5 μs** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| has    | **0 B**  | 0 B                  | 85.9 kB  |               |                 | 0 B      |                |                  | 0 B     | 0 B     |
| add    | 188.2 kB | 188.2 kB             |          | 501.3 kB      | 501.3 kB        |          | 383.6 kB       | 297.6 kB         | **0 B** | 8.1 kB  |
| remove | 32.0 kB  | 32.0 kB              | 220.1 kB |               |                 | 156.2 kB |                |                  | **0 B** | 8.1 kB  |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs     |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :---------- |
| throughput    | 9.38 μs |                      | 45.7 μs |               |                 | 15.5 μs  |                |                  | 5.04 μs     | **5.02 μs** |
| overlap       | 10.1 μs |                      | 110 μs  |               |                 | 19.9 μs  |                |                  | **9.02 μs** | 10.9 μs     |
| fragmented    | 5.71 μs |                      | 98.9 μs |               |                 | 10.9 μs  |                |                  | **4.08 μs** | 5.08 μs     |
| chained       | 27.6 μs |                      | 298 μs  |               |                 | 49.1 μs  |                |                  | 26.3 μs     | **25.6 μs** |
| multi_20      | 82.1 μs |                      | 812 μs  |               |                 | 206 μs   |                |                  | 65.6 μs     | **63.0 μs** |
| empty_systems | 1.21 μs |                      | 3.00 μs |               |                 | 667 ns   |                |                  | 958 ns      | **292 ns**  |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 173.2 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 517.9 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 93.5 kB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 690.0 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 1.7 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

## 10000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs    |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :--------- |
| create_empty           | 6.62 ms | 3.96 ms              | 2.58 ms |               |                 | 3.69 ms  |                |                  | **956 μs**  | 984 μs     |
| create_with_components | 33.1 ms | 8.66 ms              |         | 9.70 ms       | 14.1 ms         | 13.6 ms  |                |                  | **1.74 ms** | 2.22 ms    |
| destroy                | 11.8 ms | 11.7 ms              | 1.99 ms |               |                 | 1.12 s   |                |                  | 796 μs      | **520 μs** |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata         | tinyecs  |
| :--------------------- | :------- | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :----------- | :------- |
| create_empty           | 4.0 MB   | 1.5 MB               | 7.1 MB  |               |                 | 5.6 MB   |                |                  | **625.0 kB** | 754.2 kB |
| create_with_components | 9.0 MB   | 6.5 MB               |         | 16.4 MB       | 18.2 MB         | 9.9 MB   |                |                  | **2.2 MB**   | 2.3 MB   |
| destroy                | 448.8 kB | 448.0 kB             | 1.3 MB  |               |                 | **0 B**  |                |                  | 384.2 kB     | 128.1 kB |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs    |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :--------- |
| get    | 256 μs  | 238 μs               | 1.34 ms |               |                 | 268 μs   |                |                  | **74.4 μs** | 81.9 μs    |
| set    | 258 μs  | 251 μs               | 1.56 ms |               |                 | 275 μs   |                |                  | **77.7 μs** | 80.4 μs    |
| add    | 5.84 ms | 33.9 ms              |         | 8.61 ms       | 10.8 ms         |          | 6.12 ms        | 5.57 ms          | **1.14 ms** | 1.42 ms    |
| remove | 20.2 ms | 21.0 ms              | 7.14 ms |               |                 | 3.62 ms  |                |                  | 235 μs      | **131 μs** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :------- |
| get    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B      |                |                  | 0 B        | 0 B      |
| set    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B      |                |                  | 0 B        | 0 B      |
| add    | 2.9 MB   | 2.9 MB               |          | 6.9 MB        | 6.9 MB          |          | 4.4 MB         | 3.5 MB           | **1.1 MB** | 1.2 MB   |
| remove | 448.0 kB | 448.0 kB             | 2.5 MB   |               |                 | 1.6 MB   |                |                  | **0 B**    | 128.1 kB |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs    |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :--------- |
| has    | 166 μs  | 176 μs               | 783 μs  |               |                 | 150 μs   |                |                  | **48.0 μs** | 51.5 μs    |
| add    | 8.81 ms | 32.1 ms              |         | 7.13 ms       | 9.28 ms         |          | 5.85 ms        | 5.24 ms          | 499 μs      | **306 μs** |
| remove | 37.5 ms | 16.4 ms              | 7.42 ms |               |                 | 3.60 ms  |                |                  | 241 μs      | **130 μs** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------- |
| has    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B      |                |                  | 0 B     | 0 B      |
| add    | 2.0 MB   | 2.0 MB               |          | 5.3 MB        | 5.3 MB          |          | 3.5 MB         | 2.7 MB           | **0 B** | 128.1 kB |
| remove | 448.0 kB | 448.0 kB             | 2.5 MB   |               |                 | 1.6 MB   |                |                  | **0 B** | 128.1 kB |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs    |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :--------- |
| throughput    | 121 μs  |                      | 1.36 ms |               |                 | 165 μs   |                |                  | **48.5 μs** | 49.6 μs    |
| overlap       | 192 μs  |                      | 3.12 ms |               |                 | 273 μs   |                |                  | **89.4 μs** | 93.0 μs    |
| fragmented    | 97.8 μs |                      | 2.29 ms |               |                 | 142 μs   |                |                  | **38.5 μs** | 42.7 μs    |
| chained       | 706 μs  |                      | 9.24 ms |               |                 | 1.07 ms  |                |                  | **298 μs**  | 307 μs     |
| multi_20      | 2.79 ms |                      | 33.1 ms |               |                 | 4.63 ms  |                |                  | **1.24 ms** | 1.40 ms    |
| empty_systems | 1.29 μs |                      | 4.58 μs |               |                 | 667 ns   |                |                  | 958 ns      | **333 ns** |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 1.7 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 5.2 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 905.6 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 6.9 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 17.2 MB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
