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

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 137 μs  | 70.0 μs              | 71.5 μs |               |                 | **5.46 μs** |               |                 | 74.7 μs  |                |                  | 31.2 μs | 30.7 μs |
| create_with_components | 868 μs  | 1.31 ms              |         | 111 μs        | 129 μs          |             | **1.04 μs**   | 3.58 μs         | 61.0 μs  |                |                  | 18.8 μs | 26.4 μs |
| destroy                | 148 μs  | 135 μs               | 20.2 μs |               |                 |             | **1.12 μs**   | 2.62 μs         | 122 μs   |                |                  | 9.29 μs | 4.62 μs |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------- | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 51.2 kB  | 26.9 kB              | 82.3 kB |               |                 | **1.1 kB** |               |                 | 58.0 kB  |                |                  | 22.2 kB | 19.4 kB |
| create_with_components | 101.2 kB | 76.2 kB              |         | 174.5 kB      | 193.3 kB        |            | **1.1 kB**    | 1.4 kB          | 103.8 kB |                |                  | 37.9 kB | 35.0 kB |
| destroy                | 4.0 kB   | 4.0 kB               | 11.3 kB |               |                 |            | 367 B         | **0 B**         | 0 B      |                |                  | 3.2 kB  | 1.1 kB  |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs    |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :--------- |
| get    | 625 ns  | 583 ns               | 1.75 μs |               |                 | 625 ns  |               |                 | 833 ns   |                |                  | 333 ns     | **292 ns** |
| set    | 667 ns  | 583 ns               | 1.88 μs |               |                 | 1.46 μs |               |                 | 875 ns   |                |                  | **292 ns** | 292 ns     |
| add    | 243 μs  | 215 μs               |         | 69.0 μs       | 74.6 μs         |         | **500 ns**    | 4.92 μs         |          | 50.5 μs        | 46.4 μs          | 4.50 μs    | 4.17 μs    |
| remove | 984 μs  | 1.06 ms              | 40.3 μs |               |                 |         | **917 ns**    | 4.25 μs         | 31.0 μs  |                |                  | 2.08 μs    | 2.96 μs    |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| get    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B     | 0 B     |
| set    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B     | 0 B     |
| add    | 29.0 kB | 29.0 kB              |         | 67.2 kB       | 67.2 kB         |         | 367 B         | **0 B**         |          | 43.8 kB        | 35.2 kB          | 10.9 kB | 12.1 kB |
| remove | 4.0 kB  | 4.0 kB               | 23.4 kB |               |                 |         | 367 B         | **0 B**         | 15.6 kB  |                |                  | 0 B     | 1.1 kB  |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :------ |
| has    | 583 ns  | 500 ns               | 1.25 μs |               |                 | 333 ns  |               |                 | 292 ns   |                |                  | **125 ns** | 125 ns  |
| add    | 242 μs  | 208 μs               |         | 55.9 μs       | 59.9 μs         |         | **500 ns**    | 4.83 μs         |          | 49.1 μs        | 44.7 μs          | 3.42 μs    | 2.54 μs |
| remove | 965 μs  | 858 μs               | 39.6 μs |               |                 |         | **792 ns**    | 4.79 μs         | 31.2 μs  |                |                  | 1.92 μs    | 1.58 μs |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| has    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| add    | 19.6 kB | 19.6 kB              |         | 51.5 kB       | 51.5 kB         |         | 367 B         | **0 B**         |          | 35.2 kB        | 26.6 kB          | 0 B  | 1.1 kB  |
| remove | 4.0 kB  | 4.0 kB               | 23.4 kB |               |                 |         | 367 B         | **0 B**         | 15.6 kB  |                |                  | 0 B  | 1.1 kB  |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| throughput    | 1.08 μs |                      | 4.88 μs |               |                 | **375 ns** |               |                 | 1.38 μs  |                |                  | 417 ns  | 375 ns      |
| overlap       | 3.48 μs |                      | 11.7 μs |               |                 | 1.21 μs    |               |                 | 1.42 μs  |                |                  | 583 ns  | **542 ns**  |
| fragmented    | 1.00 μs |                      | 7.71 μs |               |                 | 1.54 μs    |               |                 | 708 ns   |                |                  | 375 ns  | **292 ns**  |
| chained       | 2.75 μs |                      | 22.5 μs |               |                 | 1.71 μs    |               |                 | 3.88 μs  |                |                  | 1.29 μs | **1.12 μs** |
| multi_20      | 30.2 μs |                      | 67.5 μs |               |                 | 10.9 μs    |               |                 | 15.0 μs  |                |                  | 5.58 μs | **4.92 μs** |
| empty_systems | 1.83 μs |                      | 2.58 μs |               |                 | 8.54 μs    |               |                 | 708 ns   |                |                  | 958 ns  | **250 ns**  |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 18.5 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 53.8 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 12.3 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 71.2 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 182.1 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

## 1000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 1.12 ms | 526 μs               | 727 μs  |               |                 | **39.2 μs** |               |                 | 657 μs   |                |                  | 178 μs  | 178 μs  |
| create_with_components | 4.00 ms | 2.51 ms              |         | 1.31 ms       | 1.40 ms         |             | **7.54 μs**   | 18.3 μs         | 1.01 ms  |                |                  | 423 μs  | 149 μs  |
| destroy                | 1.04 ms | 1.59 ms              | 124 μs  |               |                 |             | **8.75 μs**   | 26.7 μs         | 11.9 ms  |                |                  | 86.5 μs | 120 μs  |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :--------------------- | :------- | :------------------- | :------- | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create_empty           | 376.4 kB | 141.3 kB             | 667.7 kB |               |                 | **8.1 kB** |               |                 | 500.0 kB |                |                  | 62.5 kB  | 70.6 kB  |
| create_with_components | 876.4 kB | 626.4 kB             |          | 1.6 MB        | 1.8 MB          |            | **8.1 kB**    | 8.4 kB          | 946.4 kB |                |                  | 218.8 kB | 226.9 kB |
| destroy                | 32.0 kB  | 32.0 kB              | 81.3 kB  |               |                 |            | 367 B         | **0 B**         | 0 B      |                |                  | 24.2 kB  | 8.1 kB   |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| get    | 13.7 μs | 11.2 μs              | 23.1 μs |               |                 | 6.88 μs |               |                 | 8.88 μs  |                |                  | **4.58 μs** | 4.58 μs |
| set    | 14.9 μs | 12.9 μs              | 23.5 μs |               |                 | 15.3 μs |               |                 | 9.58 μs  |                |                  | **4.71 μs** | 4.75 μs |
| add    | 738 μs  | 820 μs               |         | 623 μs        | 687 μs          |         | **2.21 μs**   | 45.2 μs         |          | 544 μs         | 492 μs           | 51.9 μs     | 38.1 μs |
| remove | 1.65 ms | 1.16 ms              | 379 μs  |               |                 |         | **1.79 μs**   | 43.2 μs         | 323 μs   |                |                  | 20.2 μs     | 13.9 μs |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| get    | **0 B**  | 0 B                  | 85.9 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B      | 0 B      |
| set    | **0 B**  | 0 B                  | 85.9 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B      | 0 B      |
| add    | 282.0 kB | 282.0 kB             |          | 657.6 kB      | 657.6 kB        |         | 367 B         | **0 B**         |          | 469.5 kB       | 383.6 kB         | 109.4 kB | 117.5 kB |
| remove | 32.0 kB  | 32.0 kB              | 220.1 kB |               |                 |         | 367 B         | **0 B**         | 156.2 kB |                |                  | 0 B      | 8.1 kB   |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| has    | 20.3 μs | 19.9 μs              | 19.3 μs |               |                 | 2.88 μs |               |                 | 3.42 μs  |                |                  | **1.92 μs** | 2.00 μs |
| add    | 700 μs  | 766 μs               |         | 501 μs        | 555 μs          |         | **1.83 μs**   | 46.7 μs         |          | 520 μs         | 461 μs           | 40.7 μs     | 27.0 μs |
| remove | 1.74 ms | 1.15 ms              | 365 μs  |               |                 |         | **2.17 μs**   | 47.1 μs         | 315 μs   |                |                  | 20.8 μs     | 14.8 μs |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| has    | **0 B**  | 0 B                  | 85.9 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| add    | 188.2 kB | 188.2 kB             |          | 501.3 kB      | 501.3 kB        |         | 367 B         | **0 B**         |          | 383.6 kB       | 297.6 kB         | 0 B  | 8.1 kB  |
| remove | 32.0 kB  | 32.0 kB              | 220.1 kB |               |                 |         | 367 B         | **0 B**         | 156.2 kB |                |                  | 0 B  | 8.1 kB  |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs    |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :--------- |
| throughput    | 9.79 μs |                      | 32.1 μs |               |                 | **1.79 μs** |               |                 | 17.5 μs  |                |                  | 5.08 μs | 4.96 μs    |
| overlap       | 31.8 μs |                      | 73.1 μs |               |                 | **2.25 μs** |               |                 | 18.6 μs  |                |                  | 9.38 μs | 9.46 μs    |
| fragmented    | 7.21 μs |                      | 28.7 μs |               |                 | **2.67 μs** |               |                 | 10.0 μs  |                |                  | 3.96 μs | 3.88 μs    |
| chained       | 27.0 μs |                      | 214 μs  |               |                 | **3.62 μs** |               |                 | 46.7 μs  |                |                  | 26.4 μs | 27.2 μs    |
| multi_20      | 179 μs  |                      | 614 μs  |               |                 | **20.4 μs** |               |                 | 200 μs   |                |                  | 65.1 μs | 63.8 μs    |
| empty_systems | 2.17 μs |                      | 3.00 μs |               |                 | 6.62 μs     |               |                 | 708 ns   |                |                  | 958 ns  | **292 ns** |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 173.2 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 517.9 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 93.5 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 690.0 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 1.7 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

## 10000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 11.0 ms | 5.49 ms              | 5.27 ms |               |                 | **395 μs** |               |                 | 6.66 ms  |                |                  | 2.41 ms | 1.59 ms |
| create_with_components | 12.0 ms | 12.0 ms              |         | 13.9 ms       | 14.4 ms         |            | **124 μs**    | 321 μs          | 10.3 ms  |                |                  | 1.74 ms | 2.30 ms |
| destroy                | 3.87 ms | 4.16 ms              | 1.98 ms |               |                 |            | **88.9 μs**   | 296 μs          | 958 ms   |                |                  | 811 μs  | 520 μs  |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved      | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :--------------------- | :------- | :------------------- | :------ | :------------ | :-------------- | :----------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create_empty           | 4.0 MB   | 1.5 MB               | 7.1 MB  |               |                 | **128.1 kB** |               |                 | 5.0 MB   |                |                  | 625.0 kB | 753.1 kB |
| create_with_components | 9.0 MB   | 6.5 MB               |         | 16.4 MB       | 18.2 MB         |              | **78.4 kB**   | 128.4 kB        | 9.2 MB   |                |                  | 2.2 MB   | 2.3 MB   |
| destroy                | 448.0 kB | 448.0 kB             | 1.3 MB  |               |                 |              | 367 B         | **0 B**         | 0 B      |                |                  | 384.2 kB | 128.1 kB |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| get    | 238 μs  | 225 μs               | 1.30 ms |               |                 | **71.2 μs** |               |                 | 279 μs   |                |                  | 86.4 μs     | 95.6 μs |
| set    | 257 μs  | 233 μs               | 1.34 ms |               |                 | 154 μs      |               |                 | 245 μs   |                |                  | **87.1 μs** | 88.6 μs |
| add    | 4.50 ms | 4.37 ms              |         | 8.30 ms       | 9.57 ms         |             | **15.9 μs**   | 501 μs          |          | 5.83 ms        | 5.28 ms          | 1.07 ms     | 1.57 ms |
| remove | 5.43 ms | 4.65 ms              | 7.27 ms |               |                 |             | **13.6 μs**   | 435 μs          | 3.52 ms  |                |                  | 238 μs      | 145 μs  |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata   | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :----- | :------- |
| get    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B    | 0 B      |
| set    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B    | 0 B      |
| add    | 2.9 MB   | 2.9 MB               |          | 6.9 MB        | 6.9 MB          |         | 367 B         | **0 B**         |          | 4.4 MB         | 3.5 MB           | 1.1 MB | 1.2 MB   |
| remove | 448.0 kB | 448.0 kB             | 2.5 MB   |               |                 |         | 367 B         | **0 B**         | 1.6 MB   |                |                  | 0 B    | 128.1 kB |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| has    | 196 μs  | 182 μs               | 775 μs  |               |                 | 33.3 μs |               |                 | 75.6 μs  |                |                  | **17.5 μs** | 36.5 μs |
| add    | 3.96 ms | 3.89 ms              |         | 7.11 ms       | 8.17 ms         |         | **12.5 μs**   | 532 μs          |          | 5.63 ms        | 5.02 ms          | 513 μs      | 324 μs  |
| remove | 4.95 ms | 4.78 ms              | 7.17 ms |               |                 |         | **13.6 μs**   | 539 μs          | 3.54 ms  |                |                  | 243 μs      | 125 μs  |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------- |
| has    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B      |
| add    | 2.0 MB   | 2.0 MB               |          | 5.3 MB        | 5.3 MB          |         | 367 B         | **0 B**         |          | 3.5 MB         | 2.7 MB           | 0 B  | 128.1 kB |
| remove | 448.0 kB | 448.0 kB             | 2.5 MB   |               |                 |         | 367 B         | **0 B**         | 1.6 MB   |                |                  | 0 B  | 128.1 kB |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs    |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :--------- |
| throughput    | 118 μs  |                      | 1.17 ms |               |                 | **13.5 μs** |               |                 | 184 μs   |                |                  | 49.6 μs | 51.5 μs    |
| overlap       | 204 μs  |                      | 2.95 ms |               |                 | **12.2 μs** |               |                 | 346 μs   |                |                  | 93.9 μs | 106 μs     |
| fragmented    | 99.9 μs |                      | 935 μs  |               |                 | **11.8 μs** |               |                 | 203 μs   |                |                  | 42.1 μs | 39.8 μs    |
| chained       | 669 μs  |                      | 6.57 ms |               |                 | **21.2 μs** |               |                 | 945 μs   |                |                  | 289 μs  | 296 μs     |
| multi_20      | 3.03 ms |                      | 23.1 ms |               |                 | **117 μs**  |               |                 | 4.58 ms  |                |                  | 1.18 ms | 1.30 ms    |
| empty_systems | 9.31 μs |                      | 5.35 μs |               |                 | 5.38 μs     |               |                 | 958 ns   |                |                  | 958 ns  | **333 ns** |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 1.7 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 5.2 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 905.6 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 6.9 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 17.2 MB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
