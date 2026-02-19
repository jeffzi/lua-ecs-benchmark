# Benchmark Environment

```text
OS: macOS 26.3
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
| create_empty           | 440 μs  | 119 μs               | 47.5 μs |               |                 | 35.3 μs  |                |                  | **16.2 μs** | 24.4 μs     |
| create_with_components | 633 μs  | 504 μs               |         | 129 μs        | 125 μs          | 126 μs   |                |                  | **19.1 μs** | 26.9 μs     |
| destroy                | 133 μs  | 102 μs               | 20.3 μs |               |                 | 122 μs   |                |                  | 9.38 μs     | **4.67 μs** |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :--------------------- | :------- | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| create_empty           | 51.2 kB  | 26.9 kB              | 82.3 kB |               |                 | 58.0 kB  |                |                  | 22.2 kB | **19.4 kB** |
| create_with_components | 101.2 kB | 76.2 kB              |         | 174.5 kB      | 193.3 kB        | 103.8 kB |                |                  | 37.9 kB | **35.0 kB** |
| destroy                | 4.0 kB   | 4.0 kB               | 11.3 kB |               |                 | **0 B**  |                |                  | 3.2 kB  | 1.1 kB      |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :---------- |
| get    | 625 ns  | 542 ns               | 1.83 μs |               |                 | 833 ns   |                |                  | **292 ns** | 292 ns      |
| set    | 667 ns  | 583 ns               | 1.92 μs |               |                 | 875 ns   |                |                  | **208 ns** | 250 ns      |
| add    | 247 μs  | 180 μs               |         | 71.1 μs       | 73.9 μs         |          | 48.0 μs        | 44.9 μs          | 4.71 μs    | **3.58 μs** |
| remove | 775 μs  | 572 μs               | 38.3 μs |               |                 | 29.1 μs  |                |                  | 2.12 μs    | **1.75 μs** |

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
| has    | 500 ns  | 417 ns               | 1.29 μs |               |                 | 333 ns   |                |                  | **125 ns** | 125 ns      |
| add    | 204 μs  | 155 μs               |         | 56.3 μs       | 62.6 μs         |          | 45.6 μs        | 42.3 μs          | 3.25 μs    | **2.58 μs** |
| remove | 707 μs  | 683 μs               | 38.5 μs |               |                 | 29.9 μs  |                |                  | 2.00 μs    | **1.58 μs** |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| has    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B      |                |                  | 0 B     | 0 B     |
| add    | 19.6 kB | 19.6 kB              |         | 51.5 kB       | 51.5 kB         |          | 35.2 kB        | 26.6 kB          | **0 B** | 1.1 kB  |
| remove | 4.0 kB  | 4.0 kB               | 23.4 kB |               |                 | 15.6 kB  |                |                  | **0 B** | 1.1 kB  |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs     |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :---------- |
| throughput    | 958 ns  |                      | 5.17 μs |               |                 | 1.50 μs  |                |                  | **375 ns** | 417 ns      |
| overlap       | 2.46 μs |                      | 12.2 μs |               |                 | 1.71 μs  |                |                  | **708 ns** | 1.54 μs     |
| fragmented    | 1.12 μs |                      | 7.58 μs |               |                 | 833 ns   |                |                  | 333 ns     | **292 ns**  |
| chained       | 3.00 μs |                      | 22.1 μs |               |                 | 4.25 μs  |                |                  | 1.25 μs    | **1.12 μs** |
| multi_20      | 12.9 μs |                      | 66.9 μs |               |                 | 17.5 μs  |                |                  | 5.63 μs    | **5.04 μs** |
| empty_systems | 1.79 μs |                      | 2.67 μs |               |                 | 750 ns   |                |                  | 958 ns     | **250 ns**  |

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

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs    |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :--------- |
| create_empty           | 1.72 ms | 744 μs               | 551 μs  |               |                 | 586 μs   |                |                  | **42.4 μs** | 123 μs     |
| create_with_components | 3.38 ms | 2.30 ms              |         | 1.28 ms       | 1.84 ms         | 1.27 ms  |                |                  | 512 μs      | **154 μs** |
| destroy                | 1.01 ms | 601 μs               | 123 μs  |               |                 | 10.8 ms  |                |                  | **86.2 μs** | 117 μs     |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata         | tinyecs  |
| :--------------------- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :----------- | :------- |
| create_empty           | 376.4 kB | 141.3 kB             | 667.7 kB |               |                 | 500.0 kB |                |                  | **62.5 kB**  | 70.6 kB  |
| create_with_components | 876.4 kB | 626.4 kB             |          | 1.6 MB        | 1.8 MB          | 946.4 kB |                |                  | **218.8 kB** | 226.9 kB |
| destroy                | 32.0 kB  | 32.0 kB              | 81.3 kB  |               |                 | **0 B**  |                |                  | 24.2 kB      | 8.1 kB   |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :---------- |
| get    | 12.2 μs | 12.1 μs              | 21.7 μs |               |                 | 8.88 μs  |                |                  | 4.46 μs     | **4.29 μs** |
| set    | 13.8 μs | 13.3 μs              | 21.6 μs |               |                 | 9.75 μs  |                |                  | **4.50 μs** | 4.50 μs     |
| add    | 656 μs  | 693 μs               |         | 641 μs        | 642 μs          |          | 472 μs         | 473 μs           | 51.5 μs     | **36.5 μs** |
| remove | 1.04 ms | 621 μs               | 351 μs  |               |                 | 290 μs   |                |                  | 19.0 μs     | **13.9 μs** |

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
| has    | 25.8 μs | 19.0 μs              | 13.2 μs |               |                 | 3.25 μs  |                |                  | **2.17 μs** | 2.21 μs     |
| add    | 640 μs  | 672 μs               |         | 499 μs        | 542 μs          |          | 472 μs         | 442 μs           | 37.8 μs     | **25.2 μs** |
| remove | 1.03 ms | 648 μs               | 347 μs  |               |                 | 306 μs   |                |                  | 20.9 μs     | **14.3 μs** |

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
| throughput    | 9.75 μs |                      | 32.9 μs |               |                 | 15.6 μs  |                |                  | 5.00 μs     | **4.96 μs** |
| overlap       | 10.5 μs |                      | 85.5 μs |               |                 | 21.3 μs  |                |                  | **9.79 μs** | 9.88 μs     |
| fragmented    | 7.42 μs |                      | 27.0 μs |               |                 | 11.3 μs  |                |                  | **4.00 μs** | 4.04 μs     |
| chained       | 26.5 μs |                      | 174 μs  |               |                 | 50.3 μs  |                |                  | **25.5 μs** | 26.1 μs     |
| multi_20      | 168 μs  |                      | 571 μs  |               |                 | 201 μs   |                |                  | 65.4 μs     | **64.6 μs** |
| empty_systems | 1.92 μs |                      | 3.46 μs |               |                 | 750 ns   |                |                  | 958 ns      | **292 ns**  |

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
| create_empty           | 7.77 ms | 4.23 ms              | 3.22 ms |               |                 | 6.02 ms  |                |                  | **1.04 ms** | 1.09 ms    |
| create_with_components | 13.9 ms | 10.00 ms             |         | 9.73 ms       | 18.5 ms         | 13.0 ms  |                |                  | **1.82 ms** | 2.40 ms    |
| destroy                | 3.69 ms | 3.78 ms              | 1.87 ms |               |                 | 1.22 s   |                |                  | 791 μs      | **514 μs** |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata         | tinyecs  |
| :--------------------- | :------- | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :----------- | :------- |
| create_empty           | 4.0 MB   | 1.5 MB               | 7.1 MB  |               |                 | 5.0 MB   |                |                  | **625.0 kB** | 753.1 kB |
| create_with_components | 9.0 MB   | 6.5 MB               |         | 16.4 MB       | 18.2 MB         | 9.2 MB   |                |                  | **2.2 MB**   | 2.3 MB   |
| destroy                | 448.0 kB | 448.0 kB             | 1.3 MB  |               |                 | **0 B**  |                |                  | 384.2 kB     | 128.1 kB |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs    |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :--------- |
| get    | 249 μs  | 209 μs               | 1.14 ms |               |                 | 242 μs   |                |                  | **78.2 μs** | 87.3 μs    |
| set    | 258 μs  | 222 μs               | 1.26 ms |               |                 | 200 μs   |                |                  | **47.7 μs** | 54.2 μs    |
| add    | 4.44 ms | 4.35 ms              |         | 8.57 ms       | 8.43 ms         |          | 5.50 ms        | 5.05 ms          | **1.07 ms** | 1.40 ms    |
| remove | 5.37 ms | 4.89 ms              | 6.23 ms |               |                 | 3.13 ms  |                |                  | 211 μs      | **133 μs** |

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
| has    | 170 μs  | 163 μs               | 655 μs  |               |                 | 108 μs   |                |                  | **45.6 μs** | 51.7 μs    |
| add    | 4.17 ms | 4.02 ms              |         | 6.80 ms       | 7.32 ms         |          | 5.21 ms        | 4.74 ms          | 465 μs      | **293 μs** |
| remove | 5.24 ms | 4.79 ms              | 6.13 ms |               |                 | 3.38 ms  |                |                  | 245 μs      | **134 μs** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------- |
| has    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B      |                |                  | 0 B     | 0 B      |
| add    | 2.0 MB   | 2.0 MB               |          | 5.3 MB        | 5.3 MB          |          | 3.5 MB         | 2.7 MB           | **0 B** | 128.1 kB |
| remove | 448.0 kB | 448.0 kB             | 2.5 MB   |               |                 | 1.6 MB   |                |                  | **0 B** | 128.1 kB |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs     |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :---------- |
| throughput    | 125 μs  |                      | 1.04 ms |               |                 | 185 μs   |                |                  | 49.8 μs     | **49.8 μs** |
| overlap       | 194 μs  |                      | 2.78 ms |               |                 | 300 μs   |                |                  | **99.3 μs** | 100 μs      |
| fragmented    | 97.3 μs |                      | 815 μs  |               |                 | 125 μs   |                |                  | 39.6 μs     | **39.2 μs** |
| chained       | 692 μs  |                      | 6.50 ms |               |                 | 931 μs   |                |                  | **293 μs**  | 304 μs      |
| multi_20      | 2.71 ms |                      | 22.2 ms |               |                 | 4.50 ms  |                |                  | **1.18 ms** | 1.28 ms     |
| empty_systems | 8.04 μs |                      | 4.88 μs |               |                 | 750 ns   |                |                  | 958 ns      | **292 ns**  |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 1.7 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 5.2 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 905.6 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 6.9 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 17.2 MB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
