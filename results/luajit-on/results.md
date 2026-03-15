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

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 197 μs  | 71.0 μs              | 46.1 μs |               |                 | **667 ns** |               |                 | 36.7 μs  |                |                  | 16.7 μs | 25.2 μs |
| create_with_components | 183 μs  | 116 μs               |         | 125 μs        | 125 μs          |            | **1.88 μs**   | 2.29 μs         | 129 μs   |                |                  | 22.1 μs | 27.5 μs |
| destroy                | 34.4 μs | 35.3 μs              | 20.6 μs |               |                 |            | **1.17 μs**   | 2.62 μs         | 125 μs   |                |                  | 8.29 μs | 4.17 μs |

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
| get    | 375 ns  | 458 ns               | 1.67 μs |               |                 | 583 ns  |               |                 | 875 ns   |                |                  | **292 ns** | 292 ns  |
| set    | 458 ns  | 500 ns               | 1.71 μs |               |                 | 1.33 μs |               |                 | 917 ns   |                |                  | **292 ns** | 292 ns  |
| add    | 46.7 μs | 52.6 μs              |         | 65.7 μs       | 72.8 μs         |         | **458 ns**    | 4.67 μs         |          | 51.1 μs        | 44.7 μs          | 4.54 μs    | 3.62 μs |
| remove | 45.9 μs | 52.4 μs              | 38.9 μs |               |                 |         | **1.00 μs**   | 4.33 μs         | 30.1 μs  |                |                  | 2.00 μs    | 1.62 μs |

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
| has    | 375 ns  | 333 ns               | 1.29 μs |               |                 | 333 ns  |               |                 | 333 ns   |                |                  | **125 ns** | 125 ns  |
| add    | 48.9 μs | 57.2 μs              |         | 55.1 μs       | 58.7 μs         |         | **708 ns**    | 4.17 μs         |          | 47.4 μs        | 42.6 μs          | 3.21 μs    | 2.50 μs |
| remove | 43.0 μs | 51.3 μs              | 39.0 μs |               |                 |         | **792 ns**    | 4.79 μs         | 30.2 μs  |                |                  | 1.92 μs    | 1.58 μs |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| has    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| add    | 19.6 kB | 19.6 kB              |         | 51.5 kB       | 51.5 kB         |         | 367 B         | **0 B**         |          | 35.2 kB        | 26.6 kB          | 0 B  | 1.1 kB  |
| remove | 4.0 kB  | 4.0 kB               | 23.4 kB |               |                 |         | 367 B         | **0 B**         | 15.6 kB  |                |                  | 0 B  | 1.1 kB  |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs     |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :---------- |
| throughput    | 500 ns  |                      | 5.25 μs |               |                 | **375 ns** |               |                 | 1.46 μs  |                |                  | 417 ns     | 417 ns      |
| overlap       | 833 ns  |                      | 12.0 μs |               |                 | 1.17 μs    |               |                 | 1.83 μs  |                |                  | **708 ns** | 1.38 μs     |
| fragmented    | 375 ns  |                      | 7.92 μs |               |                 | 1.42 μs    |               |                 | 792 ns   |                |                  | 375 ns     | **292 ns**  |
| chained       | 1.88 μs |                      | 23.0 μs |               |                 | 1.62 μs    |               |                 | 4.29 μs  |                |                  | 1.25 μs    | **1.12 μs** |
| multi_20      | 6.58 μs |                      | 66.2 μs |               |                 | 11.1 μs    |               |                 | 17.8 μs  |                |                  | 5.79 μs    | **5.17 μs** |
| empty_systems | 1.17 μs |                      | 2.62 μs |               |                 | 8.42 μs    |               |                 | 667 ns   |                |                  | 958 ns     | **208 ns**  |

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
| create        | 848 μs  |                      |         | 139 μs        | 168 μs          |         | **1.42 μs**   | 3.58 μs         | 154 μs   |                |                  | 42.9 μs | 171 μs  |
| add_component | 424 μs  |                      |         | 66.2 μs       | 73.9 μs         |         | **708 ns**    | 5.54 μs         |          | 46.4 μs        | 45.7 μs          | 17.9 μs | 156 μs  |
| destroy       | 309 μs  |                      | 23.9 μs |               |                 |         | 4.67 μs       | **3.54 μs**     | 148 μs   |                |                  | 34.2 μs | 61.8 μs |

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
| create_empty           | 1.34 ms | 352 μs               | 508 μs  |               |                 | **5.50 μs** |               |                 | 380 μs   |                |                  | 43.9 μs | 125 μs  |
| create_with_components | 1.22 ms | 893 μs               |         | 1.19 ms       | 1.75 ms         |             | **15.8 μs**   | 30.2 μs         | 1.25 ms  |                |                  | 435 μs  | 155 μs  |
| destroy                | 377 μs  | 324 μs               | 129 μs  |               |                 |             | **8.83 μs**   | 27.7 μs         | 12.0 ms  |                |                  | 91.5 μs | 122 μs  |

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
| get    | 4.54 μs | **4.38 μs**          | 20.7 μs |               |                 | 5.71 μs |               |                 | 9.21 μs  |                |                  | 4.46 μs     | 4.38 μs |
| set    | 5.33 μs | 5.12 μs              | 19.2 μs |               |                 | 15.0 μs |               |                 | 9.58 μs  |                |                  | **4.67 μs** | 4.71 μs |
| add    | 465 μs  | 446 μs               |         | 622 μs        | 694 μs          |         | **1.79 μs**   | 44.8 μs         |          | 516 μs         | 476 μs           | 52.1 μs     | 37.5 μs |
| remove | 283 μs  | 375 μs               | 365 μs  |               |                 |         | **2.25 μs**   | 42.8 μs         | 308 μs   |                |                  | 20.2 μs     | 14.0 μs |

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
| has    | 4.21 μs | 4.13 μs              | 14.9 μs |               |                 | 2.79 μs |               |                 | 3.17 μs  |                |                  | **2.17 μs** | 2.21 μs |
| add    | 574 μs  | 451 μs               |         | 512 μs        | 566 μs          |         | **1.96 μs**   | 52.8 μs         |          | 495 μs         | 445 μs           | 38.6 μs     | 27.0 μs |
| remove | 348 μs  | 292 μs               | 356 μs  |               |                 |         | **1.75 μs**   | 48.5 μs         | 309 μs   |                |                  | 21.0 μs     | 14.6 μs |

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
| throughput    | 9.00 μs |                      | 31.2 μs |               |                 | **1.75 μs** |               |                 | 16.7 μs  |                |                  | 5.12 μs | 5.08 μs    |
| overlap       | 13.1 μs |                      | 74.6 μs |               |                 | **2.29 μs** |               |                 | 21.7 μs  |                |                  | 9.79 μs | 11.6 μs    |
| fragmented    | 5.21 μs |                      | 26.5 μs |               |                 | **2.25 μs** |               |                 | 11.3 μs  |                |                  | 3.96 μs | 4.00 μs    |
| chained       | 27.7 μs |                      | 183 μs  |               |                 | **3.50 μs** |               |                 | 50.0 μs  |                |                  | 27.2 μs | 27.3 μs    |
| multi_20      | 83.3 μs |                      | 704 μs  |               |                 | **20.5 μs** |               |                 | 203 μs   |                |                  | 68.8 μs | 67.8 μs    |
| empty_systems | 1.79 μs |                      | 2.83 μs |               |                 | 6.54 μs     |               |                 | 667 ns   |                |                  | 958 ns  | **292 ns** |

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
| create        | 7.89 ms |                      |         | 1.18 ms       | 1.45 ms         |         | **12.4 μs**   | 36.6 μs         | 1.74 ms  |                |                  | 367 μs | 1.56 ms |
| add_component | 4.00 ms |                      |         | 611 μs        | 677 μs          |         | **1.71 μs**   | 52.3 μs         |          | 521 μs         | 459 μs           | 192 μs | 1.60 ms |
| destroy       | 2.54 ms |                      | 142 μs  |               |                 |         | **9.04 μs**   | 28.9 μs         | 17.7 ms  |                |                  | 334 μs | 865 μs  |

#### Memory Usage

| test          | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :------------ | :------- | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create        | 876.4 kB |                      |         | 1.6 MB        | 1.8 MB          |         | **8.1 kB**    | 8.4 kB          | 2.7 MB   |                |                  | 218.8 kB | 226.9 kB |
| add_component | 282.0 kB |                      |         | 657.6 kB      | 657.6 kB        |         | 367 B         | **0 B**         |          | 469.5 kB       | 383.6 kB         | 109.4 kB | 117.5 kB |
| destroy       | 32.0 kB  |                      | 83.0 kB |               |                 |         | 367 B         | **0 B**         | 0 B      |                |                  | 24.2 kB  | 8.1 kB   |

## 10000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 9.00 ms | 4.15 ms              | 3.85 ms |               |                 | **94.5 μs** |               |                 | 6.41 ms  |                |                  | 1.06 ms | 1.09 ms |
| create_with_components | 8.30 ms | 7.76 ms              |         | 9.93 ms       | 18.0 ms         |             | **140 μs**    | 200 μs          | 13.1 ms  |                |                  | 1.73 ms | 2.26 ms |
| destroy                | 5.80 ms | 4.10 ms              | 2.03 ms |               |                 |             | **87.3 μs**   | 285 μs          | 991 ms   |                |                  | 787 μs  | 534 μs  |

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
| get    | 247 μs  | 189 μs               | 1.19 ms |               |                 | **69.6 μs** |               |                 | 259 μs   |                |                  | 79.1 μs     | 87.0 μs |
| set    | 255 μs  | 217 μs               | 1.23 ms |               |                 | 150 μs      |               |                 | 252 μs   |                |                  | **79.9 μs** | 88.5 μs |
| add    | 11.0 ms | 6.74 ms              |         | 8.09 ms       | 9.62 ms         |             | **15.9 μs**   | 443 μs          |          | 5.59 ms        | 5.04 ms          | 1.13 ms     | 1.51 ms |
| remove | 6.91 ms | 5.33 ms              | 7.20 ms |               |                 |             | **13.7 μs**   | 434 μs          | 3.46 ms  |                |                  | 238 μs      | 140 μs  |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata   | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :----- | :------- |
| get    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B    | 0 B      |
| set    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B    | 0 B      |
| add    | 2.9 MB   | 2.9 MB               |          | 6.9 MB        | 6.9 MB          |         | 367 B         | **0 B**         |          | 4.4 MB         | 3.5 MB           | 1.1 MB | 1.2 MB   |
| remove | 448.0 kB | 448.0 kB             | 2.5 MB   |               |                 |         | 367 B         | **0 B**         | 1.6 MB   |                |                  | 0 B    | 128.1 kB |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| has    | 155 μs  | 155 μs               | 781 μs  |               |                 | **31.8 μs** |               |                 | 111 μs   |                |                  | 45.7 μs | 51.5 μs |
| add    | 5.45 ms | 6.71 ms              |         | 6.91 ms       | 8.32 ms         |             | **12.3 μs**   | 446 μs          |          | 5.40 ms        | 4.83 ms          | 482 μs  | 285 μs  |
| remove | 4.92 ms | 5.79 ms              | 7.06 ms |               |                 |             | **12.7 μs**   | 522 μs          | 3.44 ms  |                |                  | 222 μs  | 131 μs  |

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
| throughput    | 108 μs  |                      | 1.18 ms |               |                 | **18.0 μs** |               |                 | 187 μs   |                |                  | 51.2 μs | 50.0 μs    |
| overlap       | 225 μs  |                      | 2.87 ms |               |                 | **12.2 μs** |               |                 | 430 μs   |                |                  | 101 μs  | 106 μs     |
| fragmented    | 85.3 μs |                      | 1.02 ms |               |                 | **11.7 μs** |               |                 | 130 μs   |                |                  | 38.9 μs | 39.4 μs    |
| chained       | 738 μs  |                      | 7.02 ms |               |                 | **21.2 μs** |               |                 | 983 μs   |                |                  | 303 μs  | 307 μs     |
| multi_20      | 2.93 ms |                      | 21.4 ms |               |                 | **116 μs**  |               |                 | 5.20 ms  |                |                  | 1.24 ms | 1.38 ms    |
| empty_systems | 1.29 μs |                      | 5.08 μs |               |                 | 5.33 μs     |               |                 | 646 ns   |                |                  | 958 ns  | **333 ns** |

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
| create        | 77.3 ms |                      |         | 12.1 ms       | 14.4 ms         |         | **157 μs**    | 173 μs          | 17.9 ms  |                |                  | 3.50 ms | 13.4 ms |
| add_component | 45.1 ms |                      |         | 8.03 ms       | 8.83 ms         |         | **17.4 μs**   | 531 μs          |          | 7.05 ms        | 6.58 ms          | 2.25 ms | 14.1 ms |
| destroy       | 48.0 ms |                      | 1.95 ms |               |                 |         | **64.8 μs**   | 376 μs          | 968 ms   |                |                  | 3.31 ms | 10.6 ms |

#### Memory Usage

| test          | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :------------ | :------- | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create        | 9.0 MB   |                      |         | 16.4 MB       | 18.2 MB         |         | **78.4 kB**   | 128.4 kB        | 26.4 MB  |                |                  | 2.2 MB   | 2.3 MB   |
| add_component | 2.9 MB   |                      |         | 6.9 MB        | 6.9 MB          |         | 367 B         | **0 B**         |          | 4.4 MB         | 3.5 MB           | 1.1 MB   | 1.2 MB   |
| destroy       | 448.0 kB |                      | 1.3 MB  |               |                 |         | 367 B         | **0 B**         | 0 B      |                |                  | 384.2 kB | 128.1 kB |
