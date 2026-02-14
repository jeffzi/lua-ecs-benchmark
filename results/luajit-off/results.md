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
| create_empty           | 136 μs  | 70.8 μs              | 58.1 μs |               |                 | 73.1 μs  |                |                  | 29.8 μs     | **29.7 μs** |
| create_with_components | 255 μs  | 182 μs               |         | 157 μs        | 242 μs          | 125 μs   |                |                  | **34.2 μs** | 34.2 μs     |
| destroy                | 57.0 μs | 57.7 μs              | 42.4 μs |               |                 | 460 μs   |                |                  | 31.3 μs     | **13.5 μs** |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :--------------------- | :------- | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| create_empty           | 51.2 kB  | 26.9 kB              | 82.3 kB |               |                 | 58.0 kB  |                |                  | 22.2 kB | **19.4 kB** |
| create_with_components | 101.2 kB | 76.2 kB              |         | 174.5 kB      | 193.3 kB        | 103.8 kB |                |                  | 37.9 kB | **35.0 kB** |
| destroy                | 4.0 kB   | 4.0 kB               | 11.3 kB |               |                 | **0 B**  |                |                  | 3.2 kB  | 1.1 kB      |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| get    | 1.25 μs | 1.21 μs              | 10.8 μs |               |                 | 3.96 μs  |                |                  | 1.08 μs | **1.00 μs** |
| set    | 1.38 μs | 1.33 μs              | 10.9 μs |               |                 | 4.04 μs  |                |                  | 1.21 μs | **1.12 μs** |
| add    | 74.4 μs | 76.1 μs              |         | 102 μs        | 130 μs          |          | 62.6 μs        | 57.5 μs          | 11.7 μs | **9.25 μs** |
| remove | 56.0 μs | 55.9 μs              | 73.9 μs |               |                 | 36.2 μs  |                |                  | 9.50 μs | **6.92 μs** |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :---------- | :------ |
| get    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B      |                |                  | 0 B         | 0 B     |
| set    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B      |                |                  | 0 B         | 0 B     |
| add    | 29.0 kB | 29.0 kB              |         | 67.2 kB       | 67.2 kB         |          | 43.8 kB        | 35.2 kB          | **10.9 kB** | 12.1 kB |
| remove | 4.0 kB  | 4.0 kB               | 23.4 kB |               |                 | 15.6 kB  |                |                  | **0 B**     | 1.1 kB  |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| has    | 7.42 μs | 7.40 μs              | 12.9 μs |               |                 | 3.88 μs  |                |                  | 2.42 μs | **1.88 μs** |
| add    | 67.6 μs | 69.0 μs              |         | 88.3 μs       | 108 μs          |          | 59.7 μs        | 55.4 μs          | 10.1 μs | **7.33 μs** |
| remove | 55.3 μs | 56.5 μs              | 73.9 μs |               |                 | 36.2 μs  |                |                  | 9.48 μs | **7.08 μs** |

#### Memory Usage

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| has    | **0 B** | 0 B                  | 8.6 kB  |               |                 | 0 B      |                |                  | 0 B     | 0 B     |
| add    | 19.6 kB | 19.6 kB              |         | 51.5 kB       | 51.5 kB         |          | 35.2 kB        | 26.6 kB          | **0 B** | 1.1 kB  |
| remove | 4.0 kB  | 4.0 kB               | 23.4 kB |               |                 | 15.6 kB  |                |                  | **0 B** | 1.1 kB  |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys   | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------- | :--------------- | :---------- | :------ |
| throughput    | 3.33 μs |                      | 27.2 μs |               |                 | 6.29 μs    |                |                  | **2.58 μs** | 3.38 μs |
| overlap       | 4.33 μs |                      | 77.2 μs |               |                 | 8.50 μs    |                |                  | **3.08 μs** | 4.38 μs |
| fragmented    | 1.92 μs |                      | 25.1 μs |               |                 | 3.75 μs    |                |                  | **1.58 μs** | 2.42 μs |
| chained       | 6.65 μs |                      | 102 μs  |               |                 | 19.2 μs    |                |                  | **4.96 μs** | 7.83 μs |
| multi_20      | 45.0 μs |                      | 270 μs  |               |                 | 64.4 μs    |                |                  | **31.9 μs** | 40.1 μs |
| empty_systems | 1.92 μs |                      | 7.25 μs |               |                 | **917 ns** |                |                  | 1.21 μs     | 2.21 μs |

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

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata   | tinyecs    |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :----- | :--------- |
| create_empty           | 1.12 ms | 525 μs               | 737 μs  |               |                 | 650 μs   |                |                  | 179 μs | **176 μs** |
| create_with_components | 2.37 ms | 1.66 ms              |         | 1.90 ms       | 2.43 ms         | 1.46 ms  |                |                  | 244 μs | **216 μs** |
| destroy                | 501 μs  | 513 μs               | 337 μs  |               |                 | 49.0 ms  |                |                  | 291 μs | **196 μs** |

#### Memory Usage

| test                   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata         | tinyecs  |
| :--------------------- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :----------- | :------- |
| create_empty           | 376.4 kB | 141.3 kB             | 667.7 kB |               |                 | 500.0 kB |                |                  | **62.5 kB**  | 70.6 kB  |
| create_with_components | 876.4 kB | 626.4 kB             |          | 1.6 MB        | 1.8 MB          | 946.4 kB |                |                  | **218.8 kB** | 226.9 kB |
| destroy                | 32.0 kB  | 32.0 kB              | 81.3 kB  |               |                 | **0 B**  |                |                  | 24.2 kB      | 8.1 kB   |

### Component

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| get    | 17.5 μs | 12.8 μs              | 102 μs  |               |                 | 34.5 μs  |                |                  | 11.5 μs | **10.9 μs** |
| set    | 19.0 μs | 15.8 μs              | 119 μs  |               |                 | 36.6 μs  |                |                  | 12.9 μs | **12.0 μs** |
| add    | 634 μs  | 667 μs               |         | 1.24 ms       | 1.38 ms         |          | 697 μs         | 638 μs           | 114 μs  | **78.0 μs** |
| remove | 464 μs  | 473 μs               | 703 μs  |               |                 | 377 μs   |                |                  | 92.7 μs | **55.1 μs** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata         | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :----------- | :------- |
| get    | **0 B**  | 0 B                  | 85.9 kB  |               |                 | 0 B      |                |                  | 0 B          | 0 B      |
| set    | **0 B**  | 0 B                  | 85.9 kB  |               |                 | 0 B      |                |                  | 0 B          | 0 B      |
| add    | 282.0 kB | 282.0 kB             |          | 657.6 kB      | 657.6 kB        |          | 469.5 kB       | 383.6 kB         | **109.4 kB** | 117.5 kB |
| remove | 32.0 kB  | 32.0 kB              | 220.1 kB |               |                 | 156.2 kB |                |                  | **0 B**      | 8.1 kB   |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| has    | 63.2 μs | 63.0 μs              | 126 μs  |               |                 | 37.8 μs  |                |                  | 22.8 μs | **12.0 μs** |
| add    | 576 μs  | 599 μs               |         | 853 μs        | 1.14 ms         |          | 644 μs         | 597 μs           | 104 μs  | **59.3 μs** |
| remove | 455 μs  | 468 μs               | 692 μs  |               |                 | 385 μs   |                |                  | 92.9 μs | **55.1 μs** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| has    | **0 B**  | 0 B                  | 85.9 kB  |               |                 | 0 B      |                |                  | 0 B     | 0 B     |
| add    | 188.2 kB | 188.2 kB             |          | 501.3 kB      | 501.3 kB        |          | 383.6 kB       | 297.6 kB         | **0 B** | 8.1 kB  |
| remove | 32.0 kB  | 32.0 kB              | 220.1 kB |               |                 | 156.2 kB |                |                  | **0 B** | 8.1 kB  |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys   | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------- | :--------------- | :---------- | :------ |
| throughput    | 29.1 μs |                      | 244 μs  |               |                 | 54.8 μs    |                |                  | **23.8 μs** | 29.0 μs |
| overlap       | 41.0 μs |                      | 682 μs  |               |                 | 75.5 μs    |                |                  | **31.6 μs** | 40.6 μs |
| fragmented    | 16.5 μs |                      | 147 μs  |               |                 | 31.7 μs    |                |                  | **12.6 μs** | 18.3 μs |
| chained       | 68.5 μs |                      | 890 μs  |               |                 | 180 μs     |                |                  | **52.5 μs** | 74.5 μs |
| multi_20      | 387 μs  |                      | 2.57 ms |               |                 | 699 μs     |                |                  | **361 μs**  | 404 μs  |
| empty_systems | 1.88 μs |                      | 7.79 μs |               |                 | **958 ns** |                |                  | 1.17 μs     | 2.17 μs |

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

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| create_empty           | 11.1 ms | 5.71 ms              | 5.06 ms |               |                 | 6.58 ms  |                |                  | 2.41 ms | **1.51 ms** |
| create_with_components | 20.3 ms | 16.3 ms              |         | 14.9 ms       | 24.0 ms         | 15.1 ms  |                |                  | 3.26 ms | **2.90 ms** |
| destroy                | 4.74 ms | 4.97 ms              | 4.53 ms |               |                 | 4.64 s   |                |                  | 2.70 ms | **1.31 ms** |

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
| get    | 573 μs  | 569 μs               | 4.32 ms |               |                 | 620 μs   |                |                  | **143 μs**  | 207 μs     |
| set    | 582 μs  | 551 μs               | 4.14 ms |               |                 | 646 μs   |                |                  | **157 μs**  | 224 μs     |
| add    | 6.62 ms | 7.32 ms              |         | 12.6 ms       | 15.4 ms         |          | 7.43 ms        | 6.77 ms          | **1.84 ms** | 1.96 ms    |
| remove | 5.74 ms | 5.73 ms              | 10.9 ms |               |                 | 4.18 ms  |                |                  | 1.01 ms     | **605 μs** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :------- |
| get    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B      |                |                  | 0 B        | 0 B      |
| set    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B      |                |                  | 0 B        | 0 B      |
| add    | 2.9 MB   | 2.9 MB               |          | 6.9 MB        | 6.9 MB          |          | 4.4 MB         | 3.5 MB           | **1.1 MB** | 1.2 MB   |
| remove | 448.0 kB | 448.0 kB             | 2.5 MB   |               |                 | 1.6 MB   |                |                  | **0 B**    | 128.1 kB |

### Tag

#### Execution Time

| test   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata       | tinyecs    |
| :----- | :------ | :------------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--------- | :--------- |
| has    | 805 μs  | 920 μs               | 3.52 ms |               |                 | 443 μs   |                |                  | **111 μs** | 164 μs     |
| add    | 5.67 ms | 6.24 ms              |         | 10.8 ms       | 13.3 ms         |          | 6.91 ms        | 6.36 ms          | 1.12 ms    | **737 μs** |
| remove | 5.08 ms | 5.70 ms              | 10.9 ms |               |                 | 4.14 ms  |                |                  | 1.02 ms    | **628 μs** |

#### Memory Usage

| test   | concord  | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs  |
| :----- | :------- | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------- |
| has    | **0 B**  | 0 B                  | 859.4 kB |               |                 | 0 B      |                |                  | 0 B     | 0 B      |
| add    | 2.0 MB   | 2.0 MB               |          | 5.3 MB        | 5.3 MB          |          | 3.5 MB         | 2.7 MB           | **0 B** | 128.1 kB |
| remove | 448.0 kB | 448.0 kB             | 2.5 MB   |               |                 | 1.6 MB   |                |                  | **0 B** | 128.1 kB |

### System

#### Execution Time

| test          | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | lovetoys   | lovetoys-batch | lovetoys-nobatch | nata        | tinyecs |
| :------------ | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------- | :--------------- | :---------- | :------ |
| throughput    | 322 μs  |                      | 4.02 ms |               |                 | 553 μs     |                |                  | **237 μs**  | 281 μs  |
| overlap       | 487 μs  |                      | 8.39 ms |               |                 | 799 μs     |                |                  | **309 μs**  | 396 μs  |
| fragmented    | 242 μs  |                      | 3.04 ms |               |                 | 340 μs     |                |                  | **119 μs**  | 166 μs  |
| chained       | 1.33 ms |                      | 15.2 ms |               |                 | 2.11 ms    |                |                  | **560 μs**  | 759 μs  |
| multi_20      | 8.41 ms |                      | 57.0 ms |               |                 | 18.6 ms    |                |                  | **4.51 ms** | 5.50 ms |
| empty_systems | 1.96 μs |                      | 9.02 μs |               |                 | **958 ns** |                |                  | 1.17 μs     | 2.21 μs |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 1.7 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 5.2 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 905.6 kB |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 6.9 MB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 17.2 MB  |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.5 kB   |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
