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

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 135 μs  | 70.0 μs              | 71.5 μs |               |                 | **5.50 μs** |               |                  |                 | 70.7 μs  |                |                  | 29.9 μs | 30.7 μs |
| create_with_components | 1.43 ms | 1.25 ms              |         | 114 μs        | 125 μs          |             | **1.04 μs**   | 17.6 μs          | 10.1 μs         | 66.4 μs  |                |                  | 18.9 μs | 26.4 μs |
| destroy                | 155 μs  | 148 μs               | 19.5 μs |               |                 |             | **1.17 μs**   | 2.88 μs          | 2.77 μs         | 122 μs   |                |                  | 8.25 μs | 4.17 μs |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------- | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 51.2 kB  | 26.9 kB              | 82.3 kB |               |                 | **1.1 kB** |               |                  |                 | 58.0 kB  |                |                  | 22.2 kB | 19.4 kB |
| create_with_components | 101.2 kB | 76.2 kB              |         | 174.5 kB      | 193.3 kB        |            | **1.1 kB**    | 16.7 kB          | 16.7 kB         | 103.8 kB |                |                  | 37.9 kB | 35.0 kB |
| destroy                | 4.0 kB   | 4.0 kB               | 11.3 kB |               |                 |            | 367 B         | **0 B**          | 0 B             | 0 B      |                |                  | 3.2 kB  | 1.1 kB  |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :--------- | :------ |
| get    | 667 ns  | 542 ns               | 1.71 μs |               |                 | 583 ns  |               |                  |                 | 875 ns   |                |                  | **208 ns** | 250 ns  |
| set    | 792 ns  | 583 ns               | 1.79 μs |               |                 | 1.42 μs |               |                  |                 | 917 ns   |                |                  | **208 ns** | 250 ns  |
| add    | 251 μs  | 234 μs               |         | 71.2 μs       | 74.2 μs         |         | **458 ns**    | 5.29 μs          | 4.29 μs         |          | 48.1 μs        | 45.3 μs          | 4.50 μs    | 3.54 μs |
| remove | 1.08 ms | 969 μs               | 41.2 μs |               |                 |         | **875 ns**    | 5.63 μs          | 4.04 μs         | 30.0 μs  |                |                  | 2.21 μs    | 1.75 μs |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| get    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B     | 0 B     |
| set    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B     | 0 B     |
| add    | 29.0 kB | 29.0 kB              |         | 67.2 kB       | 67.2 kB         |         | 367 B         | **0 B**          | 0 B             |          | 43.8 kB        | 35.2 kB          | 10.9 kB | 12.1 kB |
| remove | 4.0 kB  | 4.0 kB               | 23.4 kB |               |                 |         | 367 B         | **0 B**          | 0 B             | 15.6 kB  |                |                  | 0 B     | 1.1 kB  |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :--------- | :------ |
| has    | 583 ns  | 500 ns               | 1.46 μs |               |                 | 333 ns  |               |                  |                 | 292 ns   |                |                  | **125 ns** | 125 ns  |
| add    | 253 μs  | 225 μs               |         | 55.3 μs       | 59.0 μs         |         | **500 ns**    | 5.46 μs          | 4.58 μs         |          | 47.7 μs        | 42.7 μs          | 3.50 μs    | 2.62 μs |
| remove | 1.07 ms | 1.04 ms              | 38.8 μs |               |                 |         | **792 ns**    | 6.00 μs          | 4.75 μs         | 29.9 μs  |                |                  | 2.17 μs    | 3.08 μs |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| has    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| add    | 19.6 kB | 19.6 kB              |         | 51.5 kB       | 51.5 kB         |         | 367 B         | **0 B**          | 0 B             |          | 35.2 kB        | 26.6 kB          | 0 B  | 1.1 kB  |
| remove | 4.0 kB  | 4.0 kB               | 23.4 kB |               |                 |         | 367 B         | **0 B**          | 0 B             | 15.6 kB  |                |                  | 0 B  | 1.1 kB  |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs     |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :--------- | :---------- |
| throughput    | 1.04 μs |                      | 5.33 μs |               |                 | **375 ns** |               |                  |                 | 1.46 μs  |                |                  | 375 ns     | 375 ns      |
| overlap       | 13.4 μs |                      | 12.0 μs |               |                 | 1.21 μs    |               |                  |                 | 1.92 μs  |                |                  | **708 ns** | 1.46 μs     |
| fragmented    | 1.17 μs |                      | 7.50 μs |               |                 | 1.58 μs    |               |                  |                 | 792 ns   |                |                  | 375 ns     | **292 ns**  |
| chained       | 2.71 μs |                      | 22.8 μs |               |                 | 1.71 μs    |               |                  |                 | 4.58 μs  |                |                  | 1.25 μs    | **1.12 μs** |
| multi_20      | 7.50 μs |                      | 67.0 μs |               |                 | 10.2 μs    |               |                  |                 | 16.9 μs  |                |                  | 5.54 μs    | **4.96 μs** |
| empty_systems | 1.29 μs |                      | 2.62 μs |               |                 | 8.58 μs    |               |                  |                 | 750 ns   |                |                  | 958 ns     | **250 ns**  |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 18.5 kB  |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 53.8 kB  |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 12.3 kB  |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 71.2 kB  |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 182.1 kB |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |

## 1000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 1.10 ms | 521 μs               | 714 μs  |               |                 | **38.6 μs** |               |                  |                 | 607 μs   |                |                  | 173 μs  | 173 μs  |
| create_with_components | 3.53 ms | 2.63 ms              |         | 1.31 ms       | 1.38 ms         |             | **7.50 μs**   | 178 μs           | 108 μs          | 1.15 ms  |                |                  | 445 μs  | 148 μs  |
| destroy                | 1.05 ms | 1.13 ms              | 120 μs  |               |                 |             | **8.88 μs**   | 40.3 μs          | 25.6 μs         | 10.8 ms  |                |                  | 90.1 μs | 121 μs  |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :--------------------- | :------- | :------------------- | :------- | :------------ | :-------------- | :--------- | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create_empty           | 376.4 kB | 141.3 kB             | 667.7 kB |               |                 | **8.1 kB** |               |                  |                 | 500.0 kB |                |                  | 62.5 kB  | 70.6 kB  |
| create_with_components | 876.4 kB | 626.4 kB             |          | 1.6 MB        | 1.8 MB          |            | **8.1 kB**    | 164.4 kB         | 164.4 kB        | 946.4 kB |                |                  | 218.8 kB | 226.9 kB |
| destroy                | 32.0 kB  | 32.0 kB              | 81.3 kB  |               |                 |            | 367 B         | **0 B**          | 0 B             | 0 B      |                |                  | 24.2 kB  | 8.1 kB   |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| get    | 12.2 μs | 11.9 μs              | 19.0 μs |               |                 | 5.67 μs |               |                  |                 | 8.75 μs  |                |                  | **4.21 μs** | 4.25 μs |
| set    | 14.5 μs | 13.5 μs              | 19.5 μs |               |                 | 15.3 μs |               |                  |                 | 9.50 μs  |                |                  | **4.54 μs** | 4.58 μs |
| add    | 692 μs  | 790 μs               |         | 662 μs        | 649 μs          |         | **2.25 μs**   | 54.8 μs          | 47.0 μs         |          | 474 μs         | 474 μs           | 51.5 μs     | 36.2 μs |
| remove | 1.66 ms | 1.06 ms              | 350 μs  |               |                 |         | **2.29 μs**   | 57.9 μs          | 39.2 μs         | 297 μs   |                |                  | 18.9 μs     | 13.7 μs |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| get    | **0 B**  | 0 B                  | 85.9 kB  |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B      | 0 B      |
| set    | **0 B**  | 0 B                  | 85.9 kB  |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B      | 0 B      |
| add    | 282.0 kB | 282.0 kB             |          | 657.6 kB      | 657.6 kB        |         | 367 B         | **0 B**          | 0 B             |          | 469.5 kB       | 383.6 kB         | 109.4 kB | 117.5 kB |
| remove | 32.0 kB  | 32.0 kB              | 220.1 kB |               |                 |         | 367 B         | **0 B**          | 0 B             | 156.2 kB |                |                  | 0 B      | 8.1 kB   |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| has    | 21.7 μs | 22.0 μs              | 13.8 μs |               |                 | 3.71 μs |               |                  |                 | 3.17 μs  |                |                  | **1.92 μs** | 1.96 μs |
| add    | 673 μs  | 800 μs               |         | 500 μs        | 565 μs          |         | **1.54 μs**   | 55.1 μs          | 41.2 μs         |          | 506 μs         | 458 μs           | 40.4 μs     | 26.7 μs |
| remove | 1.66 ms | 1.10 ms              | 343 μs  |               |                 |         | **1.75 μs**   | 61.5 μs          | 48.4 μs         | 298 μs   |                |                  | 18.7 μs     | 13.5 μs |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| has    | **0 B**  | 0 B                  | 85.9 kB  |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| add    | 188.2 kB | 188.2 kB             |          | 501.3 kB      | 501.3 kB        |         | 367 B         | **0 B**          | 0 B             |          | 383.6 kB       | 297.6 kB         | 0 B  | 8.1 kB  |
| remove | 32.0 kB  | 32.0 kB              | 220.1 kB |               |                 |         | 367 B         | **0 B**          | 0 B             | 156.2 kB |                |                  | 0 B  | 8.1 kB  |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs    |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :------ | :--------- |
| throughput    | 9.92 μs |                      | 32.4 μs |               |                 | **1.75 μs** |               |                  |                 | 19.6 μs  |                |                  | 5.12 μs | 5.12 μs    |
| overlap       | 20.1 μs |                      | 76.5 μs |               |                 | **2.42 μs** |               |                  |                 | 22.0 μs  |                |                  | 9.42 μs | 10.4 μs    |
| fragmented    | 7.17 μs |                      | 26.6 μs |               |                 | **2.50 μs** |               |                  |                 | 11.1 μs  |                |                  | 3.96 μs | 3.88 μs    |
| chained       | 26.8 μs |                      | 149 μs  |               |                 | **3.58 μs** |               |                  |                 | 52.4 μs  |                |                  | 25.5 μs | 25.4 μs    |
| multi_20      | 168 μs  |                      | 621 μs  |               |                 | **20.4 μs** |               |                  |                 | 205 μs   |                |                  | 65.3 μs | 63.8 μs    |
| empty_systems | 1.50 μs |                      | 3.33 μs |               |                 | 5.46 μs     |               |                  |                 | 708 ns   |                |                  | 917 ns  | **292 ns** |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 173.2 kB |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 517.9 kB |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 93.5 kB  |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 690.0 kB |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 1.7 MB   |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |

## 10000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 10.9 ms | 5.43 ms              | 4.89 ms |               |                 | **383 μs** |               |                  |                 | 6.14 ms  |                |                  | 2.36 ms | 1.54 ms |
| create_with_components | 11.9 ms | 10.7 ms              |         | 9.55 ms       | 14.4 ms         |            | **125 μs**    | 2.10 ms          | 1.51 ms         | 12.1 ms  |                |                  | 1.68 ms | 2.22 ms |
| destroy                | 3.81 ms | 3.74 ms              | 1.82 ms |               |                 |            | **83.0 μs**   | 343 μs           | 273 μs          | 1.00 s   |                |                  | 775 μs  | 511 μs  |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved      | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :--------------------- | :------- | :------------------- | :------ | :------------ | :-------------- | :----------- | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create_empty           | 4.0 MB   | 1.5 MB               | 7.1 MB  |               |                 | **128.1 kB** |               |                  |                 | 5.0 MB   |                |                  | 625.0 kB | 753.1 kB |
| create_with_components | 9.0 MB   | 6.5 MB               |         | 16.4 MB       | 18.2 MB         |              | **78.4 kB**   | 1.7 MB           | 1.7 MB          | 9.2 MB   |                |                  | 2.2 MB   | 2.3 MB   |
| destroy                | 448.0 kB | 448.0 kB             | 1.3 MB  |               |                 |              | 367 B         | **0 B**          | 0 B             | 0 B      |                |                  | 384.2 kB | 128.1 kB |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| get    | 255 μs  | 231 μs               | 1.10 ms |               |                 | 70.1 μs |               |                  |                 | 157 μs   |                |                  | **45.3 μs** | 89.0 μs |
| set    | 275 μs  | 253 μs               | 1.22 ms |               |                 | 152 μs  |               |                  |                 | 160 μs   |                |                  | **48.6 μs** | 55.6 μs |
| add    | 4.19 ms | 4.15 ms              |         | 8.77 ms       | 8.72 ms         |         | **15.9 μs**   | 545 μs           | 456 μs          |          | 5.57 ms        | 5.04 ms          | 1.02 ms     | 1.44 ms |
| remove | 5.57 ms | 4.89 ms              | 6.86 ms |               |                 |         | **13.8 μs**   | 628 μs           | 441 μs          | 3.11 ms  |                |                  | 212 μs      | 128 μs  |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata   | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :----- | :------- |
| get    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B    | 0 B      |
| set    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B    | 0 B      |
| add    | 2.9 MB   | 2.9 MB               |          | 6.9 MB        | 6.9 MB          |         | 367 B         | **0 B**          | 0 B             |          | 4.4 MB         | 3.5 MB           | 1.1 MB | 1.2 MB   |
| remove | 448.0 kB | 448.0 kB             | 2.5 MB   |               |                 |         | 367 B         | **0 B**          | 0 B             | 1.6 MB   |                |                  | 0 B    | 128.1 kB |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| has    | 182 μs  | 178 μs               | 795 μs  |               |                 | 33.3 μs |               |                  |                 | 68.9 μs  |                |                  | **17.8 μs** | 30.1 μs |
| add    | 4.00 ms | 3.62 ms              |         | 6.76 ms       | 8.17 ms         |         | **12.7 μs**   | 556 μs           | 456 μs          |          | 5.51 ms        | 4.77 ms          | 510 μs      | 356 μs  |
| remove | 4.78 ms | 4.88 ms              | 6.70 ms |               |                 |         | **14.0 μs**   | 627 μs           | 502 μs          | 3.21 ms  |                |                  | 209 μs      | 102 μs  |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :--- | :------- |
| has    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B      |
| add    | 2.0 MB   | 2.0 MB               |          | 5.3 MB        | 5.3 MB          |         | 367 B         | **0 B**          | 0 B             |          | 3.5 MB         | 2.7 MB           | 0 B  | 128.1 kB |
| remove | 448.0 kB | 448.0 kB             | 2.5 MB   |               |                 |         | 367 B         | **0 B**          | 0 B             | 1.6 MB   |                |                  | 0 B  | 128.1 kB |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs    |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :------ | :--------- |
| throughput    | 118 μs  |                      | 1.13 ms |               |                 | **13.1 μs** |               |                  |                 | 246 μs   |                |                  | 50.5 μs | 51.8 μs    |
| overlap       | 170 μs  |                      | 2.92 ms |               |                 | **12.4 μs** |               |                  |                 | 357 μs   |                |                  | 93.4 μs | 106 μs     |
| fragmented    | 94.7 μs |                      | 911 μs  |               |                 | **11.5 μs** |               |                  |                 | 163 μs   |                |                  | 37.8 μs | 38.2 μs    |
| chained       | 629 μs  |                      | 6.62 ms |               |                 | **21.1 μs** |               |                  |                 | 1.00 ms  |                |                  | 297 μs  | 317 μs     |
| multi_20      | 2.66 ms |                      | 21.9 ms |               |                 | **116 μs**  |               |                  |                 | 5.49 ms  |                |                  | 1.15 ms | 1.26 ms    |
| empty_systems | 38.5 μs |                      | 4.33 μs |               |                 | 6.58 μs     |               |                  |                 | 1.00 μs  |                |                  | 958 ns  | **333 ns** |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-deferred | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :--------------- | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 1.7 MB   |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 5.2 MB   |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 905.6 kB |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 6.9 MB   |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 17.2 MB  |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B     |               |                  |                 | 0 B      |                |                  | 0 B  | 0 B     |
