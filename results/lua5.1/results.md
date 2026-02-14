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

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| create_empty           | 177 μs  | 77.8 μs              | 93.9 μs |               |                 | 120 μs   |                |                  | 50.6 μs | **31.4 μs** |
| create_with_components | 322 μs  | 246 μs               |         | 349 μs        | 381 μs          | 269 μs   |                |                  | 59.3 μs | **42.9 μs** |
| destroy                | 70.8 μs | 68.8 μs              | 53.7 μs |               |                 | 1.71 ms  |                |                  | 43.8 μs | **16.1 μs** |

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
| get    | 2.62 μs | 2.54 μs              | 20.3 μs |               |                 | 5.75 μs  |                |                  | **2.21 μs** | 2.25 μs     |
| set    | 2.83 μs | 2.75 μs              | 20.7 μs |               |                 | 6.19 μs  |                |                  | **2.48 μs** | 2.54 μs     |
| add    | 98.7 μs | 97.8 μs              |         | 182 μs        | 194 μs          |          | 137 μs         | 121 μs           | 25.0 μs     | **15.4 μs** |
| remove | 61.6 μs | 58.7 μs              | 105 μs  |               |                 | 69.2 μs  |                |                  | 19.8 μs     | **11.0 μs** |

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
| has    | 13.9 μs | 13.9 μs              | 20.0 μs |               |                 | 2.08 μs  |                |                  | **1.62 μs** | 1.71 μs     |
| add    | 90.7 μs | 88.7 μs              |         | 141 μs        | 154 μs          |          | 123 μs         | 109 μs           | 20.5 μs     | **11.3 μs** |
| remove | 61.1 μs | 60.1 μs              | 104 μs  |               |                 | 69.2 μs  |                |                  | 19.8 μs     | **10.9 μs** |

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
| throughput    | 6.04 μs |                      | 51.0 μs |               |                 | 12.7 μs     |                |                  | **5.46 μs** | 7.33 μs |
| overlap       | 7.29 μs |                      | 142 μs  |               |                 | 18.3 μs     |                |                  | **6.75 μs** | 9.67 μs |
| fragmented    | 3.75 μs |                      | 43.4 μs |               |                 | 7.62 μs     |                |                  | **3.38 μs** | 5.50 μs |
| chained       | 11.4 μs |                      | 188 μs  |               |                 | 45.4 μs     |                |                  | **10.4 μs** | 18.1 μs |
| multi_20      | 52.6 μs |                      | 554 μs  |               |                 | 132 μs      |                |                  | **52.4 μs** | 88.5 μs |
| empty_systems | 2.62 μs |                      | 9.50 μs |               |                 | **2.12 μs** |                |                  | 2.42 μs     | 3.17 μs |

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
| create_empty           | 1.61 ms | 690 μs               | 839 μs  |               |                 | 1.18 ms  |                |                  | 406 μs | **282 μs** |
| create_with_components | 3.05 ms | 2.31 ms              |         | 3.41 ms       | 3.67 ms         | 2.63 ms  |                |                  | 513 μs | **388 μs** |
| destroy                | 702 μs  | 680 μs               | 471 μs  |               |                 | 168 ms   |                |                  | 440 μs | **407 μs** |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata         | tinyecs  |
| :--------------------- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :----------- | :------- |
| create_empty           | 549.4 kB | 196.6 kB             | 950.2 kB |               |                 | 625.0 kB |                |                  | **62.5 kB**  | 78.6 kB  |
| create_with_components | 1.3 MB   | 924.4 kB             |          | 2.1 MB        | 2.2 MB          | 1.2 MB   |                |                  | **281.2 kB** | 297.4 kB |
| destroy                | 56.0 kB  | 56.0 kB              | 137.3 kB |               |                 | **0 B**  |                |                  | 40.1 kB      | 16.1 kB  |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| get    | 33.7 μs | 28.0 μs              | 214 μs  |               |                 | 61.4 μs  |                |                  | 26.0 μs | **24.6 μs** |
| set    | 36.6 μs | 29.5 μs              | 215 μs  |               |                 | 65.4 μs  |                |                  | 28.0 μs | **27.9 μs** |
| add    | 953 μs  | 943 μs               |         | 1.80 ms       | 1.93 ms         |          | 1.39 ms        | 1.24 ms          | 266 μs  | **152 μs**  |
| remove | 588 μs  | 559 μs               | 1.05 ms |               |                 | 696 μs   |                |                  | 212 μs  | **103 μs**  |

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
| has    | 140 μs  | 138 μs               | 203 μs  |               |                 | 20.7 μs  |                |                  | **15.9 μs** | 16.0 μs    |
| add    | 863 μs  | 856 μs               |         | 1.42 ms       | 1.53 ms         |          | 1.26 ms        | 1.11 ms          | 218 μs      | **105 μs** |
| remove | 586 μs  | 572 μs               | 1.05 ms |               |                 | 695 μs   |                |                  | 211 μs      | **102 μs** |

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
| throughput    | 54.7 μs |                      | 483 μs  |               |                 | 123 μs      |                |                  | **51.7 μs** | 69.4 μs |
| overlap       | 73.8 μs |                      | 1.32 ms |               |                 | 181 μs      |                |                  | **65.9 μs** | 90.9 μs |
| fragmented    | 31.3 μs |                      | 296 μs  |               |                 | 75.8 μs     |                |                  | **30.0 μs** | 48.5 μs |
| chained       | 127 μs  |                      | 1.85 ms |               |                 | 446 μs      |                |                  | **115 μs**  | 180 μs  |
| multi_20      | 535 μs  |                      | 5.24 ms |               |                 | 1.53 ms     |                |                  | **518 μs**  | 874 μs  |
| empty_systems | 2.71 μs |                      | 9.83 μs |               |                 | **2.12 μs** |                |                  | 2.42 μs     | 3.17 μs |

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
| create_empty           | 15.8 ms | 6.73 ms              | 9.46 ms |               |                 | 11.9 ms  |                |                  | 4.32 ms | **1.80 ms** |
| create_with_components | 30.6 ms | 23.3 ms              |         | 35.4 ms       | 38.4 ms         | 26.7 ms  |                |                  | 5.35 ms | **2.90 ms** |
| destroy                | 7.91 ms | 7.72 ms              | 5.32 ms |               |                 | 16.7 s   |                |                  | 4.54 ms | **2.15 ms** |

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
| get    | 1.28 ms | 1.19 ms              | 5.62 ms |               |                 | 1.36 ms  |                |                  | **470 μs** | 654 μs      |
| set    | 1.29 ms | 1.19 ms              | 5.59 ms |               |                 | 1.42 ms  |                |                  | **525 μs** | 687 μs      |
| add    | 10.3 ms | 10.1 ms              |         | 21.4 ms       | 22.7 ms         |          | 14.1 ms        | 12.8 ms          | 2.86 ms    | **1.96 ms** |
| remove | 7.08 ms | 6.87 ms              | 15.3 ms |               |                 | 7.60 ms  |                |                  | 2.31 ms    | **1.28 ms** |

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
| has    | 2.08 ms | 2.12 ms              | 4.05 ms |               |                 | 612 μs   |                |                  | **221 μs** | 283 μs      |
| add    | 9.67 ms | 9.33 ms              |         | 17.5 ms       | 18.6 ms         |          | 12.8 ms        | 11.4 ms          | 2.35 ms    | **1.33 ms** |
| remove | 7.11 ms | 6.50 ms              | 15.5 ms |               |                 | 7.45 ms  |                |                  | 2.28 ms    | **1.26 ms** |

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
| throughput    | 586 μs  |                      | 6.69 ms |               |                 | 1.25 ms     |                |                  | **514 μs**  | 690 μs  |
| overlap       | 1.00 ms |                      | 16.5 ms |               |                 | 1.95 ms     |                |                  | **664 μs**  | 911 μs  |
| fragmented    | 469 μs  |                      | 5.13 ms |               |                 | 789 μs      |                |                  | **294 μs**  | 480 μs  |
| chained       | 2.17 ms |                      | 27.4 ms |               |                 | 4.68 ms     |                |                  | **1.33 ms** | 2.03 ms |
| multi_20      | 11.1 ms |                      | 103 ms  |               |                 | 32.2 ms     |                |                  | **7.91 ms** | 13.1 ms |
| empty_systems | 2.83 μs |                      | 11.4 μs |               |                 | **2.15 μs** |                |                  | 2.42 μs     | 3.21 μs |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 1.6 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 4.7 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 824.9 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 6.3 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 15.6 MB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.8 kB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
