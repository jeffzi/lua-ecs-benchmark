# Benchmark Environment

```text
OS: macOS 26.3.1
CPU: Apple M2 Max
Cores: 12 cores (12 threads)
Max Frequency: 3.50 GHz
Memory: 64 GB
```

- **[100 entities](#100-entities):**
  [Entity](#entity) · [Component](#component) · [Tag](#tag) · [System](#system) · [Structural_Scaling](#structural_scaling)
- **[1000 entities](#1000-entities):**
  [Entity](#entity) · [Component](#component) · [Tag](#tag) · [System](#system) · [Structural_Scaling](#structural_scaling)
- **[10000 entities](#10000-entities):**
  [Entity](#entity) · [Component](#component) · [Tag](#tag) · [System](#system) · [Structural_Scaling](#structural_scaling)

## 100 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 137 μs  | 71.6 μs              | 72.8 μs |               |                 | **5.50 μs** |               |                 | 72.3 μs  |                |                  | 29.2 μs | 30.7 μs |
| create_with_components | 1.35 ms | 1.21 ms              |         | 112 μs        | 131 μs          |             | **1.04 μs**   | 3.46 μs         | 67.6 μs  |                |                  | 19.2 μs | 26.8 μs |
| destroy                | 434 μs  | 240 μs               | 20.6 μs |               |                 |             | **1.12 μs**   | 3.00 μs         | 124 μs   |                |                  | 9.38 μs | 4.54 μs |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------- | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 51.2 kB  | 26.9 kB              | 82.3 kB |               |                 | **1.1 kB** |               |                 | 58.0 kB  |                |                  | 22.2 kB | 19.4 kB |
| create_with_components | 101.2 kB | 76.2 kB              |         | 174.5 kB      | 193.3 kB        |            | **1.1 kB**    | 1.4 kB          | 103.8 kB |                |                  | 37.9 kB | 35.0 kB |
| destroy                | 4.0 kB   | 4.0 kB               | 11.3 kB |               |                 |            | 367 B         | **0 B**         | 0 B      |                |                  | 3.2 kB  | 1.1 kB  |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :------ |
| get    | 7.08 μs | 6.96 μs              | 1.71 μs |               |                 | 625 ns  |               |                 | 875 ns   |                |                  | **292 ns** | 292 ns  |
| set    | 8.54 μs | 8.08 μs              | 1.79 μs |               |                 | 1.42 μs |               |                 | 917 ns   |                |                  | **292 ns** | 292 ns  |
| add    | 246 μs  | 251 μs               |         | 71.0 μs       | 76.2 μs         |         | **458 ns**    | 4.71 μs         |          | 49.9 μs        | 46.2 μs          | 4.33 μs    | 3.83 μs |
| remove | 1.09 ms | 862 μs               | 41.8 μs |               |                 |         | **917 ns**    | 4.21 μs         | 30.2 μs  |                |                  | 2.17 μs    | 1.62 μs |

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
| has    | 14.7 μs | 14.8 μs              | 1.42 μs |               |                 | 333 ns  |               |                 | 333 ns   |                |                  | **125 ns** | 125 ns  |
| add    | 240 μs  | 243 μs               |         | 55.4 μs       | 59.6 μs         |         | **542 ns**    | 4.25 μs         |          | 49.3 μs        | 44.2 μs          | 3.42 μs    | 2.54 μs |
| remove | 1.10 ms | 1.04 ms              | 39.4 μs |               |                 |         | **917 ns**    | 4.62 μs         | 30.4 μs  |                |                  | 1.92 μs    | 1.54 μs |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| has    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| add    | 19.6 kB | 19.6 kB              |         | 51.5 kB       | 51.5 kB         |         | 367 B         | **0 B**         |          | 35.2 kB        | 26.6 kB          | 0 B  | 1.1 kB  |
| remove | 4.0 kB  | 4.0 kB               | 23.4 kB |               |                 |         | 367 B         | **0 B**         | 15.6 kB  |                |                  | 0 B  | 1.1 kB  |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs     |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :---------- |
| throughput    | 1.04 μs |                      | 5.46 μs |               |                 | 833 ns  |               |                 | 1.46 μs  |                |                  | 417 ns     | **375 ns**  |
| overlap       | 7.75 μs |                      | 12.0 μs |               |                 | 1.21 μs |               |                 | 1.67 μs  |                |                  | **833 ns** | 833 ns      |
| fragmented    | 1.50 μs |                      | 8.08 μs |               |                 | 1.33 μs |               |                 | 792 ns   |                |                  | 333 ns     | **292 ns**  |
| chained       | 3.75 μs |                      | 23.3 μs |               |                 | 1.50 μs |               |                 | 4.29 μs  |                |                  | 1.25 μs    | **1.12 μs** |
| multi_20      | 99.2 μs |                      | 72.5 μs |               |                 | 11.0 μs |               |                 | 15.5 μs  |                |                  | 5.79 μs    | **5.21 μs** |
| empty_systems | 1.42 μs |                      | 2.62 μs |               |                 | 6.58 μs |               |                 | 667 ns   |                |                  | 958 ns     | **292 ns**  |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 18.5 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 53.8 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 12.3 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 71.2 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 182.1 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

### Structural_Scaling

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create        | 1.38 ms |                      |         | 134 μs        | 168 μs          |         | **1.42 μs**   | 3.46 μs         | 165 μs   |                |                  | 42.0 μs | 183 μs  |
| add_component | 566 μs  |                      |         | 66.7 μs       | 75.4 μs         |         | **792 ns**    | 4.29 μs         |          | 49.2 μs        | 43.3 μs          | 17.6 μs | 174 μs  |
| destroy       | 605 μs  |                      | 23.3 μs |               |                 |         | 3.58 μs       | **2.96 μs**     | 150 μs   |                |                  | 34.6 μs | 59.3 μs |

#### Memory Usage

| test          | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :------------ | :------- | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create        | 101.2 kB |                      |         | 176.2 kB      | 195.0 kB        |         | **1.1 kB**    | 1.4 kB          | 275.7 kB |                |                  | 37.9 kB | 35.0 kB |
| add_component | 29.0 kB  |                      |         | 67.2 kB       | 67.2 kB         |         | 367 B         | **0 B**         |          | 43.8 kB        | 35.2 kB          | 10.9 kB | 12.1 kB |
| destroy       | 4.0 kB   |                      | 13.0 kB |               |                 |         | 367 B         | **0 B**         | 0 B      |                |                  | 3.2 kB  | 1.1 kB  |

## 1000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 1.12 ms | 542 μs               | 724 μs  |               |                 | **38.6 μs** |               |                 | 631 μs   |                |                  | 177 μs  | 174 μs  |
| create_with_components | 3.57 ms | 2.74 ms              |         | 1.37 ms       | 1.94 ms         |             | **7.88 μs**   | 15.4 μs         | 645 μs   |                |                  | 515 μs  | 154 μs  |
| destroy                | 1.06 ms | 1.05 ms              | 124 μs  |               |                 |             | **8.56 μs**   | 32.9 μs         | 10.1 ms  |                |                  | 90.9 μs | 119 μs  |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :--------------------- | :------- | :------------------- | :------- | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create_empty           | 376.4 kB | 141.3 kB             | 667.7 kB |               |                 | **8.1 kB** |               |                 | 500.0 kB |                |                  | 62.5 kB  | 70.6 kB  |
| create_with_components | 876.4 kB | 626.4 kB             |          | 1.6 MB        | 1.8 MB          |            | **8.1 kB**    | 8.4 kB          | 946.4 kB |                |                  | 218.8 kB | 226.9 kB |
| destroy                | 32.0 kB  | 32.0 kB              | 81.3 kB  |               |                 |            | 367 B         | **0 B**         | 0 B      |                |                  | 24.2 kB  | 8.1 kB   |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :---------- |
| get    | 12.6 μs | 12.5 μs              | 20.2 μs |               |                 | 6.71 μs |               |                 | 9.25 μs  |                |                  | 4.54 μs     | **4.42 μs** |
| set    | 14.6 μs | 13.7 μs              | 20.5 μs |               |                 | 14.9 μs |               |                 | 9.79 μs  |                |                  | **4.71 μs** | 4.71 μs     |
| add    | 721 μs  | 791 μs               |         | 674 μs        | 741 μs          |         | **2.12 μs**   | 42.2 μs         |          | 542 μs         | 493 μs           | 49.8 μs     | 34.2 μs     |
| remove | 1.66 ms | 1.39 ms              | 348 μs  |               |                 |         | **2.21 μs**   | 42.5 μs         | 310 μs   |                |                  | 21.0 μs     | 14.1 μs     |

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
| has    | 19.6 μs | 19.9 μs              | 16.9 μs |               |                 | 2.79 μs |               |                 | 3.25 μs  |                |                  | **1.92 μs** | 1.96 μs |
| add    | 689 μs  | 735 μs               |         | 498 μs        | 558 μs          |         | **1.92 μs**   | 46.6 μs         |          | 509 μs         | 464 μs           | 41.2 μs     | 27.3 μs |
| remove | 1.69 ms | 1.73 ms              | 349 μs  |               |                 |         | **2.21 μs**   | 45.8 μs         | 311 μs   |                |                  | 21.2 μs     | 14.8 μs |

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
| throughput    | 9.83 μs |                      | 32.5 μs |               |                 | **1.92 μs** |               |                 | 18.0 μs  |                |                  | 5.04 μs | 5.00 μs    |
| overlap       | 11.3 μs |                      | 76.8 μs |               |                 | **2.46 μs** |               |                 | 22.3 μs  |                |                  | 9.46 μs | 9.88 μs    |
| fragmented    | 10.1 μs |                      | 27.3 μs |               |                 | **2.25 μs** |               |                 | 11.2 μs  |                |                  | 3.96 μs | 4.00 μs    |
| chained       | 33.8 μs |                      | 180 μs  |               |                 | **3.50 μs** |               |                 | 50.8 μs  |                |                  | 27.3 μs | 27.2 μs    |
| multi_20      | 173 μs  |                      | 618 μs  |               |                 | **20.3 μs** |               |                 | 201 μs   |                |                  | 68.6 μs | 67.8 μs    |
| empty_systems | 2.31 μs |                      | 3.08 μs |               |                 | 6.62 μs     |               |                 | 667 ns   |                |                  | 958 ns  | **292 ns** |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 173.2 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 517.9 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 93.5 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 690.0 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 1.7 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

### Structural_Scaling

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata   | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :----- | :------ |
| create        | 9.16 ms |                      |         | 1.13 ms       | 1.46 ms         |         | **12.4 μs**   | 15.5 μs         | 2.61 ms  |                |                  | 314 μs | 1.65 ms |
| add_component | 4.09 ms |                      |         | 620 μs        | 695 μs          |         | **1.71 μs**   | 47.8 μs         |          | 477 μs         | 433 μs           | 188 μs | 1.66 ms |
| destroy       | 3.36 ms |                      | 140 μs  |               |                 |         | **14.5 μs**   | 33.8 μs         | 17.8 ms  |                |                  | 331 μs | 845 μs  |

#### Memory Usage

| test          | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :------------ | :------- | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create        | 876.4 kB |                      |         | 1.6 MB        | 1.8 MB          |         | **8.1 kB**    | 8.4 kB          | 2.7 MB   |                |                  | 218.8 kB | 226.9 kB |
| add_component | 282.0 kB |                      |         | 657.6 kB      | 657.6 kB        |         | 367 B         | **0 B**         |          | 469.5 kB       | 383.6 kB         | 109.4 kB | 117.5 kB |
| destroy       | 32.0 kB  |                      | 83.0 kB |               |                 |         | 367 B         | **0 B**         | 0 B      |                |                  | 24.2 kB  | 8.1 kB   |

## 10000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 11.1 ms | 5.69 ms              | 5.30 ms |               |                 | **384 μs** |               |                 | 6.45 ms  |                |                  | 2.34 ms | 1.56 ms |
| create_with_components | 11.0 ms | 11.5 ms              |         | 9.80 ms       | 19.6 ms         |            | **138 μs**    | 173 μs          | 6.88 ms  |                |                  | 1.82 ms | 2.39 ms |
| destroy                | 4.10 ms | 4.03 ms              | 2.01 ms |               |                 |            | **83.1 μs**   | 276 μs          | 990 ms   |                |                  | 826 μs  | 518 μs  |

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
| get    | 246 μs  | 196 μs               | 1.27 ms |               |                 | **69.4 μs** |               |                 | 282 μs   |                |                  | 84.3 μs     | 84.8 μs |
| set    | 249 μs  | 193 μs               | 1.23 ms |               |                 | 165 μs      |               |                 | 270 μs   |                |                  | **81.3 μs** | 86.3 μs |
| add    | 4.31 ms | 4.52 ms              |         | 8.34 ms       | 9.83 ms         |             | **15.8 μs**   | 494 μs          |          | 5.92 ms        | 5.35 ms          | 1.14 ms     | 1.68 ms |
| remove | 5.05 ms | 5.04 ms              | 6.91 ms |               |                 |             | **13.0 μs**   | 435 μs          | 3.51 ms  |                |                  | 246 μs      | 139 μs  |

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
| has    | 178 μs  | 182 μs               | 736 μs  |               |                 | 32.5 μs |               |                 | 76.6 μs  |                |                  | **17.5 μs** | 33.6 μs |
| add    | 3.87 ms | 3.84 ms              |         | 7.12 ms       | 7.43 ms         |         | **12.8 μs**   | 473 μs          |          | 5.41 ms        | 4.80 ms          | 512 μs      | 307 μs  |
| remove | 4.96 ms | 5.17 ms              | 6.79 ms |               |                 |         | **14.3 μs**   | 505 μs          | 3.47 ms  |                |                  | 238 μs      | 121 μs  |

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
| throughput    | 122 μs  |                      | 1.13 ms |               |                 | **13.5 μs** |               |                 | 175 μs   |                |                  | 49.1 μs | 50.0 μs    |
| overlap       | 205 μs  |                      | 2.95 ms |               |                 | **12.3 μs** |               |                 | 379 μs   |                |                  | 93.3 μs | 99.8 μs    |
| fragmented    | 102 μs  |                      | 1.00 ms |               |                 | **11.5 μs** |               |                 | 132 μs   |                |                  | 38.5 μs | 38.1 μs    |
| chained       | 749 μs  |                      | 7.06 ms |               |                 | **21.0 μs** |               |                 | 989 μs   |                |                  | 302 μs  | 297 μs     |
| multi_20      | 2.86 ms |                      | 23.2 ms |               |                 | **116 μs**  |               |                 | 5.09 ms  |                |                  | 1.18 ms | 1.29 ms    |
| empty_systems | 17.3 μs |                      | 4.67 μs |               |                 | 5.42 μs     |               |                 | 667 ns   |                |                  | 958 ns  | **333 ns** |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 1.7 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 5.2 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 905.6 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 6.9 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 17.2 MB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

### Structural_Scaling

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create        | 73.4 ms |                      |         | 12.1 ms       | 14.6 ms         |         | **126 μs**    | 334 μs          | 25.9 ms  |                |                  | 3.03 ms | 12.8 ms |
| add_component | 39.1 ms |                      |         | 8.46 ms       | 9.36 ms         |         | **19.3 μs**   | 474 μs          |          | 6.20 ms        | 5.45 ms          | 1.98 ms | 13.5 ms |
| destroy       | 36.5 ms |                      | 1.94 ms |               |                 |         | **98.5 μs**   | 314 μs          | 993 ms   |                |                  | 3.23 ms | 10.3 ms |

#### Memory Usage

| test          | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :------------ | :------- | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create        | 9.0 MB   |                      |         | 16.4 MB       | 18.2 MB         |         | **78.4 kB**   | 128.4 kB        | 26.4 MB  |                |                  | 2.2 MB   | 2.3 MB   |
| add_component | 2.9 MB   |                      |         | 6.9 MB        | 6.9 MB          |         | 367 B         | **0 B**         |          | 4.4 MB         | 3.5 MB           | 1.1 MB   | 1.2 MB   |
| destroy       | 448.0 kB |                      | 1.3 MB  |               |                 |         | 367 B         | **0 B**         | 0 B      |                |                  | 384.2 kB | 128.1 kB |
