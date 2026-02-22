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

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 280 μs  | 76.9 μs              | 47.6 μs |               |                 | **583 ns** |               |                 | 48.8 μs  |                |                  | 16.2 μs | 24.4 μs |
| create_with_components | 222 μs  | 159 μs               |         | 119 μs        | 121 μs          |            | **1.88 μs**   | 2.00 μs         | 134 μs   |                |                  | 22.9 μs | 28.3 μs |
| destroy                | 62.6 μs | 56.9 μs              | 20.5 μs |               |                 |            | **1.17 μs**   | 2.67 μs         | 122 μs   |                |                  | 9.38 μs | 4.54 μs |

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
| get    | 500 ns  | 458 ns               | 1.71 μs |               |                 | 667 ns  |               |                 | 833 ns   |                |                  | **292 ns** | 292 ns  |
| set    | 542 ns  | 500 ns               | 1.79 μs |               |                 | 1.29 μs |               |                 | 917 ns   |                |                  | **292 ns** | 292 ns  |
| add    | 86.4 μs | 80.8 μs              |         | 66.5 μs       | 76.8 μs         |         | **542 ns**    | 4.71 μs         |          | 50.8 μs        | 45.5 μs          | 4.46 μs    | 3.46 μs |
| remove | 74.8 μs | 66.2 μs              | 39.5 μs |               |                 |         | **917 ns**    | 4.21 μs         | 30.3 μs  |                |                  | 2.00 μs    | 2.92 μs |

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
| has    | 458 ns  | 417 ns               | 1.50 μs |               |                 | 333 ns  |               |                 | 292 ns   |                |                  | **125 ns** | 125 ns  |
| add    | 79.1 μs | 70.3 μs              |         | 55.1 μs       | 59.5 μs         |         | **542 ns**    | 4.38 μs         |          | 49.8 μs        | 43.8 μs          | 3.46 μs    | 2.54 μs |
| remove | 76.2 μs | 71.1 μs              | 40.7 μs |               |                 |         | **958 ns**    | 5.21 μs         | 30.5 μs  |                |                  | 1.96 μs    | 1.54 μs |

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
| throughput    | 750 ns  |                      | 5.38 μs |               |                 | 667 ns  |               |                 | 1.50 μs  |                |                  | **375 ns** | 375 ns      |
| overlap       | 917 ns  |                      | 12.3 μs |               |                 | 1.08 μs |               |                 | 1.75 μs  |                |                  | **708 ns** | 1.46 μs     |
| fragmented    | 542 ns  |                      | 8.96 μs |               |                 | 1.58 μs |               |                 | 833 ns   |                |                  | 375 ns     | **333 ns**  |
| chained       | 2.12 μs |                      | 24.4 μs |               |                 | 1.46 μs |               |                 | 4.08 μs  |                |                  | 1.25 μs    | **1.12 μs** |
| multi_20      | 7.33 μs |                      | 65.4 μs |               |                 | 11.8 μs |               |                 | 18.3 μs  |                |                  | 5.96 μs    | **5.42 μs** |
| empty_systems | 1.21 μs |                      | 2.83 μs |               |                 | 5.50 μs |               |                 | 708 ns   |                |                  | 917 ns     | **208 ns**  |

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
| create_empty           | 946 μs  | 330 μs               | 527 μs  |               |                 | **5.38 μs** |               |                 | 621 μs   |                |                  | 42.6 μs | 122 μs  |
| create_with_components | 1.83 ms | 1.09 ms              |         | 1.15 ms       | 1.79 ms         |             | 16.0 μs       | **15.3 μs**     | 1.28 ms  |                |                  | 444 μs  | 151 μs  |
| destroy                | 414 μs  | 340 μs               | 123 μs  |               |                 |             | **8.75 μs**   | 38.2 μs         | 9.93 ms  |                |                  | 86.5 μs | 119 μs  |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :--------------------- | :------- | :------------------- | :------- | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create_empty           | 376.4 kB | 141.3 kB             | 667.7 kB |               |                 | **8.1 kB** |               |                 | 500.0 kB |                |                  | 62.5 kB  | 70.6 kB  |
| create_with_components | 876.4 kB | 626.4 kB             |          | 1.6 MB        | 1.8 MB          |            | **8.1 kB**    | 8.4 kB          | 946.4 kB |                |                  | 218.8 kB | 226.9 kB |
| destroy                | 32.0 kB  | 32.0 kB              | 81.3 kB  |               |                 |            | 367 B         | **0 B**         | 0 B      |                |                  | 24.2 kB  | 8.1 kB   |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| get    | 7.13 μs | 5.12 μs              | 32.7 μs |               |                 | 6.96 μs |               |                 | 9.31 μs  |                |                  | 4.54 μs | **4.46 μs** |
| set    | 6.29 μs | 5.42 μs              | 19.3 μs |               |                 | 13.3 μs |               |                 | 9.62 μs  |                |                  | 4.75 μs | **4.71 μs** |
| add    | 586 μs  | 490 μs               |         | 636 μs        | 725 μs          |         | **2.21 μs**   | 47.3 μs         |          | 521 μs         | 481 μs           | 50.7 μs | 34.9 μs     |
| remove | 549 μs  | 378 μs               | 360 μs  |               |                 |         | **2.42 μs**   | 40.0 μs         | 312 μs   |                |                  | 20.2 μs | 13.2 μs     |

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
| has    | 5.25 μs | 4.94 μs              | 16.9 μs |               |                 | 2.88 μs |               |                 | 3.25 μs  |                |                  | **2.17 μs** | 2.25 μs |
| add    | 602 μs  | 536 μs               |         | 523 μs        | 564 μs          |         | **1.92 μs**   | 46.6 μs         |          | 519 μs         | 463 μs           | 41.1 μs     | 27.6 μs |
| remove | 492 μs  | 490 μs               | 366 μs  |               |                 |         | **2.33 μs**   | 48.9 μs         | 313 μs   |                |                  | 21.3 μs     | 15.0 μs |

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
| throughput    | 9.58 μs |                      | 32.2 μs |               |                 | **1.54 μs** |               |                 | 15.8 μs  |                |                  | 5.25 μs | 5.17 μs    |
| overlap       | 10.5 μs |                      | 90.1 μs |               |                 | **2.42 μs** |               |                 | 21.0 μs  |                |                  | 9.71 μs | 10.3 μs    |
| fragmented    | 6.42 μs |                      | 27.5 μs |               |                 | **2.58 μs** |               |                 | 11.3 μs  |                |                  | 4.25 μs | 4.00 μs    |
| chained       | 26.8 μs |                      | 190 μs  |               |                 | **3.25 μs** |               |                 | 50.7 μs  |                |                  | 26.1 μs | 26.0 μs    |
| multi_20      | 97.4 μs |                      | 651 μs  |               |                 | **20.5 μs** |               |                 | 210 μs   |                |                  | 75.3 μs | 72.5 μs    |
| empty_systems | 1.25 μs |                      | 3.46 μs |               |                 | 6.58 μs     |               |                 | 667 ns   |                |                  | 958 ns  | **292 ns** |

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

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 7.70 ms | 3.76 ms              | 3.45 ms |               |                 | **90.1 μs** |               |                 | 6.32 ms  |                |                  | 1.04 ms | 1.06 ms |
| create_with_components | 14.1 ms | 8.90 ms              |         | 9.76 ms       | 18.7 ms         |             | **148 μs**    | 384 μs          | 13.4 ms  |                |                  | 1.70 ms | 1.49 ms |
| destroy                | 3.99 ms | 4.05 ms              | 2.05 ms |               |                 |             | **87.9 μs**   | 282 μs          | 969 ms   |                |                  | 813 μs  | 512 μs  |

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
| get    | 263 μs  | 210 μs               | 1.20 ms |               |                 | **70.6 μs** |               |                 | 258 μs   |                |                  | 88.0 μs     | 87.8 μs |
| set    | 272 μs  | 231 μs               | 1.23 ms |               |                 | 154 μs      |               |                 | 255 μs   |                |                  | **84.4 μs** | 97.7 μs |
| add    | 4.52 ms | 4.48 ms              |         | 8.17 ms       | 9.49 ms         |             | **16.2 μs**   | 555 μs          |          | 5.85 ms        | 5.29 ms          | 1.15 ms     | 1.51 ms |
| remove | 4.81 ms | 4.52 ms              | 7.24 ms |               |                 |             | **13.1 μs**   | 435 μs          | 3.54 ms  |                |                  | 236 μs      | 141 μs  |

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
| has    | 171 μs  | 154 μs               | 760 μs  |               |                 | **33.2 μs** |               |                 | 115 μs   |                |                  | 52.5 μs | 53.4 μs |
| add    | 4.00 ms | 3.91 ms              |         | 7.02 ms       | 8.21 ms         |             | **13.0 μs**   | 442 μs          |          | 5.67 ms        | 4.94 ms          | 550 μs  | 347 μs  |
| remove | 4.38 ms | 4.69 ms              | 7.19 ms |               |                 |             | **13.8 μs**   | 531 μs          | 3.49 ms  |                |                  | 244 μs  | 126 μs  |

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
| throughput    | 108 μs  |                      | 1.21 ms |               |                 | **13.2 μs** |               |                 | 186 μs   |                |                  | 52.0 μs | 53.1 μs    |
| overlap       | 198 μs  |                      | 2.97 ms |               |                 | **12.0 μs** |               |                 | 394 μs   |                |                  | 96.4 μs | 108 μs     |
| fragmented    | 101 μs  |                      | 896 μs  |               |                 | **11.8 μs** |               |                 | 185 μs   |                |                  | 43.6 μs | 44.5 μs    |
| chained       | 681 μs  |                      | 6.59 ms |               |                 | **21.0 μs** |               |                 | 956 μs   |                |                  | 334 μs  | 313 μs     |
| multi_20      | 3.08 ms |                      | 22.6 ms |               |                 | **118 μs**  |               |                 | 5.43 ms  |                |                  | 1.32 ms | 1.50 ms    |
| empty_systems | 1.42 μs |                      | 5.58 μs |               |                 | 6.62 μs     |               |                 | 708 ns   |                |                  | 958 ns  | **292 ns** |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 1.7 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 5.2 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 905.6 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 6.9 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 17.2 MB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
