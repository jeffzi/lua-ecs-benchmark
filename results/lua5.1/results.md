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

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| create_empty           | 173 μs  | 77.8 μs              | 93.4 μs |               |                 | 118 μs   |                |                  | 49.2 μs | **31.7 μs** |
| create_with_components | 318 μs  | 245 μs               |         | 349 μs        | 381 μs          | 266 μs   |                |                  | 60.7 μs | **44.6 μs** |
| destroy                | 70.5 μs | 69.5 μs              | 53.2 μs |               |                 | 1.71 ms  |                |                  | 44.2 μs | **16.0 μs** |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :--------------------- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| create_empty           | 77.7 kB  | 41.0 kB              | 120.0 kB |               |                 | 78.5 kB  |                |                  | 34.2 kB | **28.4 kB** |
| create_with_components | 152.7 kB | 115.2 kB             |          | 234.1 kB      | 248.1 kB        | 137.7 kB |                |                  | 56.1 kB | **50.2 kB** |
| destroy                | 7.0 kB   | 7.0 kB               | 18.3 kB  |               |                 | **0 B**  |                |                  | 5.1 kB  | 2.1 kB      |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :---------- |
| get    | 2.50 μs | 2.46 μs              | 20.1 μs |               |                 | 5.75 μs  |                |                  | **2.17 μs** | 2.25 μs     |
| set    | 2.75 μs | 2.71 μs              | 20.5 μs |               |                 | 6.08 μs  |                |                  | **2.46 μs** | 2.50 μs     |
| add    | 99.2 μs | 97.5 μs              |         | 182 μs        | 194 μs          |          | 136 μs         | 121 μs           | 26.0 μs     | **15.9 μs** |
| remove | 61.8 μs | 60.0 μs              | 104 μs  |               |                 | 68.9 μs  |                |                  | 20.0 μs     | **10.8 μs** |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| get    | **0 B** | 0 B                  | 7.8 kB  |               |                 | 0 B      |                |                  | 0 B         | 0 B     |
| set    | **0 B** | 0 B                  | 7.8 kB  |               |                 | 0 B      |                |                  | 0 B         | 0 B     |
| add    | 44.5 kB | 44.5 kB              |         | 75.9 kB       | 77.5 kB         |          | 51.6 kB        | 43.8 kB          | **10.2 kB** | 12.3 kB |
| remove | 7.0 kB  | 7.0 kB               | 27.5 kB |               |                 | 21.9 kB  |                |                  | **0 B**     | 2.1 kB  |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :---------- |
| has    | 13.9 μs | 13.9 μs              | 19.5 μs |               |                 | 2.00 μs  |                |                  | **1.62 μs** | 1.62 μs     |
| add    | 90.4 μs | 89.0 μs              |         | 140 μs        | 153 μs          |          | 123 μs         | 108 μs           | 20.4 μs     | **11.3 μs** |
| remove | 60.9 μs | 60.2 μs              | 105 μs  |               |                 | 68.9 μs  |                |                  | 19.9 μs     | **10.8 μs** |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| has    | **0 B** | 0 B                  | 7.8 kB  |               |                 | 0 B      |                |                  | 0 B     | 0 B     |
| add    | 28.8 kB | 28.8 kB              |         | 57.9 kB       | 59.5 kB         |          | 39.8 kB        | 32.0 kB          | **0 B** | 2.1 kB  |
| remove | 7.0 kB  | 7.0 kB               | 27.5 kB |               |                 | 21.9 kB  |                |                  | **0 B** | 2.1 kB  |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys    | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------- | :--------------- | :---------- | :------ |
| throughput    | 5.96 μs |                      | 51.0 μs |               |                 | 12.6 μs     |                |                  | **5.46 μs** | 7.38 μs |
| overlap       | 7.21 μs |                      | 140 μs  |               |                 | 18.1 μs     |                |                  | **6.71 μs** | 9.67 μs |
| fragmented    | 3.71 μs |                      | 44.4 μs |               |                 | 7.58 μs     |                |                  | **3.38 μs** | 5.54 μs |
| chained       | 11.3 μs |                      | 186 μs  |               |                 | 42.4 μs     |                |                  | **10.4 μs** | 18.1 μs |
| multi_20      | 52.8 μs |                      | 544 μs  |               |                 | 131 μs      |                |                  | **52.5 μs** | 88.6 μs |
| empty_systems | 2.62 μs |                      | 9.46 μs |               |                 | **2.12 μs** |                |                  | 2.42 μs     | 3.17 μs |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 16.9 kB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 49.4 kB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 12.8 kB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 65.0 kB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 166.9 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.8 kB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

## 1000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata   | tinyecs    |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :----- | :--------- |
| create_empty           | 1.59 ms | 686 μs               | 810 μs  |               |                 | 1.16 ms  |                |                  | 404 μs | **276 μs** |
| create_with_components | 3.04 ms | 2.28 ms              |         | 3.35 ms       | 3.59 ms         | 2.60 ms  |                |                  | 503 μs | **381 μs** |
| destroy                | 699 μs  | 676 μs               | 469 μs  |               |                 | 167 ms   |                |                  | 436 μs | **406 μs** |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata         | tinyecs  |
| :--------------------- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :----------- | :------- |
| create_empty           | 549.4 kB | 196.6 kB             | 950.2 kB |               |                 | 625.0 kB |                |                  | **62.5 kB**  | 78.6 kB  |
| create_with_components | 1.3 MB   | 924.4 kB             |          | 2.1 MB        | 2.2 MB          | 1.2 MB   |                |                  | **281.2 kB** | 297.4 kB |
| destroy                | 56.0 kB  | 56.0 kB              | 137.3 kB |               |                 | **0 B**  |                |                  | 40.1 kB      | 16.1 kB  |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :---------- |
| get    | 31.3 μs | 28.4 μs              | 215 μs  |               |                 | 63.2 μs  |                |                  | **23.5 μs** | 24.2 μs     |
| set    | 34.8 μs | 30.0 μs              | 213 μs  |               |                 | 65.8 μs  |                |                  | **26.1 μs** | 26.8 μs     |
| add    | 945 μs  | 931 μs               |         | 1.79 ms       | 1.92 ms         |          | 1.39 ms        | 1.23 ms          | 264 μs      | **155 μs**  |
| remove | 580 μs  | 563 μs               | 1.04 ms |               |                 | 691 μs   |                |                  | 210 μs      | **95.5 μs** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata         | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :----------- | :------- |
| get    | **0 B**  | 0 B                  | 78.1 kB  |               |                 | 0 B      |                |                  | 0 B          | 0 B      |
| set    | **0 B**  | 0 B                  | 78.1 kB  |               |                 | 0 B      |                |                  | 0 B          | 0 B      |
| add    | 431.0 kB | 431.0 kB             |          | 736.5 kB      | 752.2 kB        |          | 579.6 kB       | 501.5 kB         | **101.6 kB** | 117.7 kB |
| remove | 56.0 kB  | 56.0 kB              | 252.2 kB |               |                 | 218.8 kB |                |                  | **0 B**      | 16.1 kB  |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs    |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :--------- |
| has    | 140 μs  | 139 μs               | 202 μs  |               |                 | 21.3 μs  |                |                  | **15.7 μs** | 15.9 μs    |
| add    | 868 μs  | 848 μs               |         | 1.40 ms       | 1.53 ms         |          | 1.26 ms        | 1.10 ms          | 215 μs      | **103 μs** |
| remove | 585 μs  | 570 μs               | 1.06 ms |               |                 | 691 μs   |                |                  | 210 μs      | **100 μs** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| has    | **0 B**  | 0 B                  | 78.1 kB  |               |                 | 0 B      |                |                  | 0 B     | 0 B     |
| add    | 274.7 kB | 274.7 kB             |          | 556.8 kB      | 572.5 kB        |          | 462.4 kB       | 384.3 kB         | **0 B** | 16.1 kB |
| remove | 56.0 kB  | 56.0 kB              | 252.2 kB |               |                 | 218.8 kB |                |                  | **0 B** | 16.1 kB |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys    | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------- | :--------------- | :---------- | :------ |
| throughput    | 54.4 μs |                      | 484 μs  |               |                 | 121 μs      |                |                  | **51.8 μs** | 69.5 μs |
| overlap       | 73.0 μs |                      | 1.31 ms |               |                 | 180 μs      |                |                  | **65.5 μs** | 90.9 μs |
| fragmented    | 31.0 μs |                      | 296 μs  |               |                 | 76.4 μs     |                |                  | **30.0 μs** | 48.5 μs |
| chained       | 125 μs  |                      | 1.82 ms |               |                 | 439 μs      |                |                  | **113 μs**  | 183 μs  |
| multi_20      | 569 μs  |                      | 5.48 ms |               |                 | 1.54 ms     |                |                  | **516 μs**  | 894 μs  |
| empty_systems | 2.75 μs |                      | 9.71 μs |               |                 | **2.12 μs** |                |                  | 2.42 μs     | 3.17 μs |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 157.5 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 471.3 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 86.6 kB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 627.5 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 1.6 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.8 kB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

## 10000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| create_empty           | 15.7 ms | 6.68 ms              | 8.91 ms |               |                 | 11.7 ms  |                |                  | 4.21 ms | **1.73 ms** |
| create_with_components | 30.5 ms | 23.2 ms              |         | 34.8 ms       | 37.6 ms         | 26.3 ms  |                |                  | 5.25 ms | **2.76 ms** |
| destroy                | 7.94 ms | 7.57 ms              | 5.28 ms |               |                 | 16.6 s   |                |                  | 4.51 ms | **2.15 ms** |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata         | tinyecs  |
| :--------------------- | :------- | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :----------- | :------- |
| create_empty           | 5.9 MB   | 2.2 MB               | 10.3 MB |               |                 | 6.2 MB   |                |                  | **625.0 kB** | 881.1 kB |
| create_with_components | 13.4 MB  | 9.7 MB               |         | 21.7 MB       | 23.1 MB         | 12.5 MB  |                |                  | **2.8 MB**   | 3.1 MB   |
| destroy                | 768.0 kB | 768.0 kB             | 2.2 MB  |               |                 | **0 B**  |                |                  | 640.1 kB     | 256.1 kB |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :---------- |
| get    | 1.28 ms | 1.11 ms              | 5.83 ms |               |                 | 1.28 ms  |                |                  | **478 μs** | 636 μs      |
| set    | 1.28 ms | 1.12 ms              | 5.98 ms |               |                 | 1.43 ms  |                |                  | **493 μs** | 638 μs      |
| add    | 10.2 ms | 9.90 ms              |         | 21.2 ms       | 22.7 ms         |          | 14.1 ms        | 12.5 ms          | 2.81 ms    | **1.89 ms** |
| remove | 7.09 ms | 6.84 ms              | 15.1 ms |               |                 | 7.39 ms  |                |                  | 2.30 ms    | **1.27 ms** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :------- |
| get    | **0 B**  | 0 B                  | 781.2 kB |               |                 | 0 B      |                |                  | 0 B        | 0 B      |
| set    | **0 B**  | 0 B                  | 781.2 kB |               |                 | 0 B      |                |                  | 0 B        | 0 B      |
| add    | 4.5 MB   | 4.5 MB               |          | 7.8 MB        | 8.0 MB          |          | 5.2 MB         | 4.4 MB           | **1.0 MB** | 1.3 MB   |
| remove | 768.0 kB | 768.0 kB             | 3.0 MB   |               |                 | 2.2 MB   |                |                  | **0 B**    | 256.1 kB |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :---------- |
| has    | 2.06 ms | 2.12 ms              | 4.02 ms |               |                 | 618 μs   |                |                  | **214 μs** | 278 μs      |
| add    | 9.67 ms | 9.30 ms              |         | 17.2 ms       | 18.4 ms         |          | 12.7 ms        | 11.2 ms          | 2.33 ms    | **1.39 ms** |
| remove | 7.01 ms | 6.46 ms              | 15.3 ms |               |                 | 7.52 ms  |                |                  | 2.29 ms    | **1.26 ms** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------- |
| has    | **0 B**  | 0 B                  | 781.2 kB |               |                 | 0 B      |                |                  | 0 B     | 0 B      |
| add    | 3.0 MB   | 3.0 MB               |          | 6.0 MB        | 6.2 MB          |          | 4.0 MB         | 3.2 MB           | **0 B** | 256.1 kB |
| remove | 768.0 kB | 768.0 kB             | 3.0 MB   |               |                 | 2.2 MB   |                |                  | **0 B** | 256.1 kB |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys    | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------- | :--------------- | :---------- | :------ |
| throughput    | 585 μs  |                      | 6.68 ms |               |                 | 1.24 ms     |                |                  | **513 μs**  | 689 μs  |
| overlap       | 993 μs  |                      | 16.2 ms |               |                 | 1.97 ms     |                |                  | **660 μs**  | 905 μs  |
| fragmented    | 506 μs  |                      | 5.21 ms |               |                 | 795 μs      |                |                  | **295 μs**  | 480 μs  |
| chained       | 2.16 ms |                      | 26.9 ms |               |                 | 4.63 ms     |                |                  | **1.32 ms** | 2.03 ms |
| multi_20      | 10.9 ms |                      | 101 ms  |               |                 | 32.0 ms     |                |                  | **7.95 ms** | 13.2 ms |
| empty_systems | 2.79 μs |                      | 11.2 μs |               |                 | **2.12 μs** |                |                  | 2.38 μs     | 3.21 μs |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 1.6 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 4.7 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 824.9 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 6.3 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 15.6 MB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.8 kB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
