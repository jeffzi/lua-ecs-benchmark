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

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| create_empty           | 173 μs  | 78.0 μs              | 92.2 μs |               |                 | **8.33 μs** |               |                 | 118 μs   |                |                  | 49.0 μs | 31.4 μs     |
| create_with_components | 319 μs  | 247 μs               |         | 351 μs        | 380 μs          |             | **11.0 μs**   | 46.8 μs         | 267 μs   |                |                  | 60.5 μs | 43.7 μs     |
| destroy                | 70.7 μs | 69.4 μs              | 53.5 μs |               |                 |             | 19.6 μs       | 44.8 μs         | 1.71 ms  |                |                  | 44.1 μs | **15.8 μs** |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------- | :------------------- | :------- | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 77.7 kB  | 41.0 kB              | 120.0 kB |               |                 | **2.1 kB** |               |                 | 78.5 kB  |                |                  | 34.2 kB | 28.4 kB |
| create_with_components | 152.7 kB | 115.2 kB             |          | 234.1 kB      | 248.1 kB        |            | **2.4 kB**    | 2.5 kB          | 137.7 kB |                |                  | 56.1 kB | 50.2 kB |
| destroy                | 7.0 kB   | 7.0 kB               | 18.3 kB  |               |                 |            | 398 B         | **0 B**         | 0 B      |                |                  | 5.1 kB  | 2.1 kB  |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| get    | 2.50 μs | 2.46 μs              | 20.5 μs |               |                 | 16.1 μs |               |                 | 5.79 μs  |                |                  | **2.21 μs** | 2.21 μs |
| set    | 2.71 μs | 2.71 μs              | 21.0 μs |               |                 | 49.2 μs |               |                 | 6.08 μs  |                |                  | **2.46 μs** | 2.54 μs |
| add    | 98.5 μs | 98.3 μs              |         | 181 μs        | 195 μs          |         | **5.83 μs**   | 61.5 μs         |          | 137 μs         | 121 μs           | 24.9 μs     | 15.8 μs |
| remove | 61.4 μs | 60.4 μs              | 104 μs  |               |                 |         | **5.33 μs**   | 68.2 μs         | 69.3 μs  |                |                  | 20.0 μs     | 10.8 μs |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| get    | **0 B** | 0 B                  | 7.8 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B     | 0 B     |
| set    | **0 B** | 0 B                  | 7.8 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B     | 0 B     |
| add    | 44.5 kB | 44.5 kB              |         | 75.9 kB       | 77.5 kB         |         | 398 B         | **0 B**         |          | 51.6 kB        | 43.8 kB          | 10.2 kB | 12.3 kB |
| remove | 7.0 kB  | 7.0 kB               | 27.5 kB |               |                 |         | 398 B         | **0 B**         | 21.9 kB  |                |                  | 0 B     | 2.1 kB  |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| has    | 14.0 μs | 14.0 μs              | 19.7 μs |               |                 | 7.46 μs |               |                 | 2.04 μs  |                |                  | **1.62 μs** | 1.62 μs |
| add    | 89.9 μs | 89.5 μs              |         | 140 μs        | 153 μs          |         | **5.42 μs**   | 61.0 μs         |          | 124 μs         | 109 μs           | 20.4 μs     | 11.5 μs |
| remove | 61.2 μs | 59.5 μs              | 104 μs  |               |                 |         | **5.46 μs**   | 66.7 μs         | 69.1 μs  |                |                  | 19.9 μs     | 11.0 μs |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| has    | **0 B** | 0 B                  | 7.8 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| add    | 28.8 kB | 28.8 kB              |         | 57.9 kB       | 59.5 kB         |         | 398 B         | **0 B**         |          | 39.8 kB        | 32.0 kB          | 0 B  | 2.1 kB  |
| remove | 7.0 kB  | 7.0 kB               | 27.5 kB |               |                 |         | 398 B         | **0 B**         | 21.9 kB  |                |                  | 0 B  | 2.1 kB  |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys    | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :---------- | :------------- | :--------------- | :---------- | :------ |
| throughput    | 6.00 μs |                      | 50.5 μs |               |                 | 6.29 μs |               |                 | 12.7 μs     |                |                  | **5.46 μs** | 7.38 μs |
| overlap       | 7.21 μs |                      | 141 μs  |               |                 | 8.88 μs |               |                 | 18.2 μs     |                |                  | **6.71 μs** | 9.67 μs |
| fragmented    | 3.75 μs |                      | 44.1 μs |               |                 | 11.7 μs |               |                 | 7.58 μs     |                |                  | **3.38 μs** | 5.38 μs |
| chained       | 11.3 μs |                      | 186 μs  |               |                 | 11.6 μs |               |                 | 45.2 μs     |                |                  | **10.4 μs** | 18.1 μs |
| multi_20      | 52.5 μs |                      | 551 μs  |               |                 | 61.6 μs |               |                 | 132 μs      |                |                  | **52.4 μs** | 88.6 μs |
| empty_systems | 2.62 μs |                      | 9.42 μs |               |                 | 22.7 μs |               |                 | **2.12 μs** |                |                  | 2.42 μs     | 3.21 μs |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 16.9 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 49.4 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 12.8 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 65.0 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 166.9 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.8 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

### Structural_Scaling

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create        | 1.50 ms |                      |         | 368 μs        | 395 μs          |         | **11.0 μs**   | 46.9 μs         | 701 μs   |                |                  | 196 μs  | 220 μs  |
| add_component | 703 μs  |                      |         | 182 μs        | 195 μs          |         | **7.92 μs**   | 61.6 μs         |          | 137 μs         | 121 μs           | 46.1 μs | 175 μs  |
| destroy       | 747 μs  |                      | 61.7 μs |               |                 |         | **21.2 μs**   | 44.1 μs         | 2.04 ms  |                |                  | 339 μs  | 213 μs  |

#### Memory Usage

| test          | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :------------ | :------- | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create        | 152.7 kB |                      |         | 236.9 kB      | 250.9 kB        |         | **2.4 kB**    | 2.6 kB          | 325.2 kB |                |                  | 56.1 kB | 50.2 kB |
| add_component | 44.5 kB  |                      |         | 75.9 kB       | 77.5 kB         |         | 398 B         | **0 B**         |          | 51.6 kB        | 43.8 kB          | 10.2 kB | 12.3 kB |
| destroy       | 7.0 kB   |                      | 20.3 kB |               |                 |         | 398 B         | **0 B**         | 0 B      |                |                  | 5.1 kB  | 2.1 kB  |

## 1000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata   | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :----- | :------ |
| create_empty           | 1.61 ms | 688 μs               | 815 μs  |               |                 | **77.4 μs** |               |                 | 1.19 ms  |                |                  | 408 μs | 281 μs  |
| create_with_components | 3.06 ms | 2.29 ms              |         | 3.39 ms       | 3.69 ms         |             | **94.5 μs**   | 453 μs          | 2.63 ms  |                |                  | 513 μs | 393 μs  |
| destroy                | 704 μs  | 682 μs               | 471 μs  |               |                 |             | **169 μs**    | 448 μs          | 168 ms   |                |                  | 430 μs | 408 μs  |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :--------------------- | :------- | :------------------- | :------- | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create_empty           | 549.4 kB | 196.6 kB             | 950.2 kB |               |                 | **16.1 kB** |               |                 | 625.0 kB |                |                  | 62.5 kB  | 78.6 kB  |
| create_with_components | 1.3 MB   | 924.4 kB             |          | 2.1 MB        | 2.2 MB          |             | **16.4 kB**   | 16.5 kB         | 1.2 MB   |                |                  | 281.2 kB | 297.4 kB |
| destroy                | 56.0 kB  | 56.0 kB              | 137.3 kB |               |                 |             | 398 B         | **0 B**         | 0 B      |                |                  | 40.1 kB  | 16.1 kB  |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| get    | 29.4 μs | 27.8 μs              | 222 μs  |               |                 | 160 μs  |               |                 | 61.6 μs  |                |                  | **23.9 μs** | 24.1 μs |
| set    | 31.4 μs | 30.1 μs              | 222 μs  |               |                 | 493 μs  |               |                 | 64.8 μs  |                |                  | **26.2 μs** | 27.3 μs |
| add    | 950 μs  | 942 μs               |         | 1.81 ms       | 1.93 ms         |         | **29.0 μs**   | 619 μs          |          | 1.40 ms        | 1.24 ms          | 265 μs      | 161 μs  |
| remove | 587 μs  | 573 μs               | 1.04 ms |               |                 |         | **22.8 μs**   | 688 μs          | 693 μs   |                |                  | 212 μs      | 101 μs  |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| get    | **0 B**  | 0 B                  | 78.1 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B      | 0 B      |
| set    | **0 B**  | 0 B                  | 78.1 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B      | 0 B      |
| add    | 431.0 kB | 431.0 kB             |          | 736.5 kB      | 752.2 kB        |         | 398 B         | **0 B**         |          | 579.6 kB       | 501.5 kB         | 101.6 kB | 117.7 kB |
| remove | 56.0 kB  | 56.0 kB              | 252.2 kB |               |                 |         | 398 B         | **0 B**         | 218.8 kB |                |                  | 0 B      | 16.1 kB  |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| has    | 139 μs  | 139 μs               | 202 μs  |               |                 | 73.5 μs |               |                 | 20.8 μs  |                |                  | **15.8 μs** | 15.8 μs |
| add    | 868 μs  | 863 μs               |         | 1.41 ms       | 1.54 ms         |         | **22.9 μs**   | 614 μs          |          | 1.26 ms        | 1.11 ms          | 216 μs      | 104 μs  |
| remove | 585 μs  | 568 μs               | 1.06 ms |               |                 |         | **22.9 μs**   | 671 μs          | 695 μs   |                |                  | 211 μs      | 102 μs  |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| has    | **0 B**  | 0 B                  | 78.1 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| add    | 274.7 kB | 274.7 kB             |          | 556.8 kB      | 572.5 kB        |         | 398 B         | **0 B**         |          | 462.4 kB       | 384.3 kB         | 0 B  | 16.1 kB |
| remove | 56.0 kB  | 56.0 kB              | 252.2 kB |               |                 |         | 398 B         | **0 B**         | 218.8 kB |                |                  | 0 B  | 16.1 kB |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys    | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :---------- | :------------- | :--------------- | :------ | :------ |
| throughput    | 54.6 μs |                      | 490 μs  |               |                 | **41.3 μs** |               |                 | 121 μs      |                |                  | 51.7 μs | 69.5 μs |
| overlap       | 73.1 μs |                      | 1.31 ms |               |                 | **37.3 μs** |               |                 | 180 μs      |                |                  | 65.5 μs | 91.1 μs |
| fragmented    | 31.1 μs |                      | 294 μs  |               |                 | **29.2 μs** |               |                 | 75.2 μs     |                |                  | 30.0 μs | 48.5 μs |
| chained       | 124 μs  |                      | 1.83 ms |               |                 | **54.1 μs** |               |                 | 444 μs      |                |                  | 113 μs  | 181 μs  |
| multi_20      | 568 μs  |                      | 5.54 ms |               |                 | **332 μs**  |               |                 | 1.54 ms     |                |                  | 518 μs  | 903 μs  |
| empty_systems | 2.75 μs |                      | 9.67 μs |               |                 | 22.0 μs     |               |                 | **2.12 μs** |                |                  | 2.42 μs | 3.25 μs |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 157.5 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 471.3 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 86.6 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 627.5 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 1.6 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.8 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

### Structural_Scaling

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create        | 14.9 ms |                      |         | 3.45 ms       | 3.71 ms         |         | **95.7 μs**   | 453 μs          | 6.97 ms  |                |                  | 1.88 ms | 2.20 ms |
| add_component | 7.03 ms |                      |         | 1.81 ms       | 1.94 ms         |         | **31.1 μs**   | 617 μs          |          | 1.39 ms        | 1.23 ms          | 480 μs  | 1.76 ms |
| destroy       | 7.60 ms |                      | 475 μs  |               |                 |         | **164 μs**    | 442 μs          | 171 ms   |                |                  | 3.26 ms | 3.35 ms |

#### Memory Usage

| test          | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :------------ | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create        | 1.3 MB   |                      |          | 2.1 MB        | 2.2 MB          |         | **16.4 kB**   | 16.6 kB         | 3.1 MB   |                |                  | 281.2 kB | 297.4 kB |
| add_component | 431.0 kB |                      |          | 736.5 kB      | 752.2 kB        |         | 398 B         | **0 B**         |          | 579.6 kB       | 501.5 kB         | 101.6 kB | 117.7 kB |
| destroy       | 56.0 kB  |                      | 139.3 kB |               |                 |         | 398 B         | **0 B**         | 0 B      |                |                  | 40.1 kB  | 16.1 kB  |

## 10000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 15.9 ms | 6.75 ms              | 9.11 ms |               |                 | **762 μs** |               |                 | 11.8 ms  |                |                  | 4.28 ms | 1.77 ms |
| create_with_components | 30.8 ms | 23.6 ms              |         | 35.4 ms       | 38.3 ms         |            | **951 μs**    | 4.53 ms         | 26.5 ms  |                |                  | 5.35 ms | 2.93 ms |
| destroy                | 8.05 ms | 7.76 ms              | 5.42 ms |               |                 |            | **1.66 ms**   | 4.50 ms         | 16.7 s   |                |                  | 4.50 ms | 2.16 ms |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved      | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :--------------------- | :------- | :------------------- | :------ | :------------ | :-------------- | :----------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create_empty           | 5.9 MB   | 2.2 MB               | 10.3 MB |               |                 | **256.1 kB** |               |                 | 6.2 MB   |                |                  | 625.0 kB | 881.1 kB |
| create_with_components | 13.4 MB  | 9.7 MB               |         | 21.7 MB       | 23.1 MB         |              | **256.4 kB**  | 256.5 kB        | 12.5 MB  |                |                  | 2.8 MB   | 3.1 MB   |
| destroy                | 768.0 kB | 768.0 kB             | 2.2 MB  |               |                 |              | 398 B         | **0 B**         | 0 B      |                |                  | 640.1 kB | 256.1 kB |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :------ |
| get    | 1.41 ms | 1.26 ms              | 5.73 ms |               |                 | 1.61 ms |               |                 | 1.37 ms  |                |                  | **494 μs** | 630 μs  |
| set    | 1.36 ms | 1.27 ms              | 5.86 ms |               |                 | 4.95 ms |               |                 | 1.25 ms  |                |                  | **516 μs** | 646 μs  |
| add    | 10.5 ms | 10.1 ms              |         | 21.8 ms       | 23.0 ms         |         | **261 μs**    | 6.20 ms         |          | 14.3 ms        | 12.7 ms          | 2.88 ms    | 1.97 ms |
| remove | 7.27 ms | 6.86 ms              | 14.9 ms |               |                 |         | **198 μs**    | 6.84 ms         | 7.39 ms  |                |                  | 2.31 ms    | 1.29 ms |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata   | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :----- | :------- |
| get    | **0 B**  | 0 B                  | 781.2 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B    | 0 B      |
| set    | **0 B**  | 0 B                  | 781.2 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B    | 0 B      |
| add    | 4.5 MB   | 4.5 MB               |          | 7.8 MB        | 8.0 MB          |         | 398 B         | **0 B**         |          | 5.2 MB         | 4.4 MB           | 1.0 MB | 1.3 MB   |
| remove | 768.0 kB | 768.0 kB             | 3.0 MB   |               |                 |         | 398 B         | **0 B**         | 2.2 MB   |                |                  | 0 B    | 256.1 kB |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :------ |
| has    | 2.17 ms | 2.21 ms              | 4.52 ms |               |                 | 737 μs  |               |                 | 604 μs   |                |                  | **209 μs** | 286 μs  |
| add    | 9.80 ms | 9.58 ms              |         | 17.5 ms       | 18.7 ms         |         | **199 μs**    | 6.17 ms         |          | 12.8 ms        | 11.3 ms          | 2.46 ms    | 1.35 ms |
| remove | 7.20 ms | 6.65 ms              | 15.7 ms |               |                 |         | **198 μs**    | 6.73 ms         | 7.40 ms  |                |                  | 2.30 ms    | 1.31 ms |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------- |
| has    | **0 B**  | 0 B                  | 781.2 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B      |
| add    | 3.0 MB   | 3.0 MB               |          | 6.0 MB        | 6.2 MB          |         | 398 B         | **0 B**         |          | 4.0 MB         | 3.2 MB           | 0 B  | 256.1 kB |
| remove | 768.0 kB | 768.0 kB             | 3.0 MB   |               |                 |         | 398 B         | **0 B**         | 2.2 MB   |                |                  | 0 B  | 256.1 kB |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys    | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :---------- | :------------- | :--------------- | :------ | :------ |
| throughput    | 573 μs  |                      | 7.10 ms |               |                 | **391 μs**  |               |                 | 1.24 ms     |                |                  | 514 μs  | 693 μs  |
| overlap       | 997 μs  |                      | 16.7 ms |               |                 | **322 μs**  |               |                 | 1.96 ms     |                |                  | 663 μs  | 907 μs  |
| fragmented    | 464 μs  |                      | 5.51 ms |               |                 | **225 μs**  |               |                 | 787 μs      |                |                  | 294 μs  | 481 μs  |
| chained       | 2.19 ms |                      | 28.4 ms |               |                 | **477 μs**  |               |                 | 4.63 ms     |                |                  | 1.30 ms | 2.01 ms |
| multi_20      | 11.2 ms |                      | 103 ms  |               |                 | **3.77 ms** |               |                 | 32.8 ms     |                |                  | 7.99 ms | 13.5 ms |
| empty_systems | 2.83 μs |                      | 11.2 μs |               |                 | 22.0 μs     |               |                 | **2.12 μs** |                |                  | 2.42 μs | 3.29 μs |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 1.6 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 4.7 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 824.9 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 6.3 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 15.6 MB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.8 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

### Structural_Scaling

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create        | 149 ms  |                      |         | 36.2 ms       | 37.9 ms         |         | **951 μs**    | 4.54 ms         | 70.3 ms  |                |                  | 19.0 ms | 22.8 ms |
| add_component | 72.6 ms |                      |         | 21.9 ms       | 23.0 ms         |         | **264 μs**    | 6.21 ms         |          | 15.0 ms        | 13.5 ms          | 4.99 ms | 21.5 ms |
| destroy       | 81.8 ms |                      | 5.58 ms |               |                 |         | **1.60 ms**   | 4.46 ms         | 16.8 s   |                |                  | 34.1 ms | 42.3 ms |

#### Memory Usage

| test          | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata     | tinyecs  |
| :------------ | :------- | :------------------- | :------ | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------- | :------- |
| create        | 13.4 MB  |                      |         | 21.7 MB       | 23.1 MB         |         | **256.4 kB**  | 256.6 kB        | 31.2 MB  |                |                  | 2.8 MB   | 3.1 MB   |
| add_component | 4.5 MB   |                      |         | 7.8 MB        | 8.0 MB          |         | 398 B         | **0 B**         |          | 5.2 MB         | 4.4 MB           | 1.0 MB   | 1.3 MB   |
| destroy       | 768.0 kB |                      | 2.2 MB  |               |                 |         | 398 B         | **0 B**         | 0 B      |                |                  | 640.1 kB | 256.1 kB |
