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

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs     |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :---------- |
| create_empty           | 176 μs  | 78.0 μs              | 93.8 μs |               |                 | **8.33 μs** |               |                 | 121 μs   |                |                  | 48.7 μs | 31.7 μs     |
| create_with_components | 320 μs  | 246 μs               |         | 353 μs        | 383 μs          |             | **10.9 μs**   | 47.0 μs         | 270 μs   |                |                  | 60.4 μs | 41.3 μs     |
| destroy                | 72.1 μs | 70.5 μs              | 54.2 μs |               |                 |             | 19.8 μs       | 44.6 μs         | 1.71 ms  |                |                  | 44.2 μs | **15.9 μs** |

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
| get    | 2.50 μs | 2.50 μs              | 20.8 μs |               |                 | 16.1 μs |               |                 | 5.83 μs  |                |                  | **2.21 μs** | 2.25 μs |
| set    | 2.71 μs | 2.71 μs              | 21.0 μs |               |                 | 49.2 μs |               |                 | 6.17 μs  |                |                  | **2.46 μs** | 2.54 μs |
| add    | 100 μs  | 98.4 μs              |         | 182 μs        | 194 μs          |         | **5.88 μs**   | 61.7 μs         |          | 137 μs         | 122 μs           | 25.5 μs     | 15.4 μs |
| remove | 62.2 μs | 60.5 μs              | 105 μs  |               |                 |         | **5.33 μs**   | 68.5 μs         | 69.3 μs  |                |                  | 20.1 μs     | 11.0 μs |

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
| has    | 14.1 μs | 14.1 μs              | 19.6 μs |               |                 | 7.88 μs |               |                 | 2.08 μs  |                |                  | **1.62 μs** | 1.62 μs |
| add    | 90.4 μs | 89.5 μs              |         | 143 μs        | 155 μs          |         | **5.42 μs**   | 61.1 μs         |          | 123 μs         | 110 μs           | 20.4 μs     | 11.3 μs |
| remove | 62.0 μs | 62.1 μs              | 105 μs  |               |                 |         | **5.50 μs**   | 66.8 μs         | 69.1 μs  |                |                  | 20.0 μs     | 10.9 μs |

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
| throughput    | 6.04 μs |                      | 51.2 μs |               |                 | 6.29 μs |               |                 | 12.8 μs     |                |                  | **5.46 μs** | 7.38 μs |
| overlap       | 7.21 μs |                      | 140 μs  |               |                 | 8.83 μs |               |                 | 18.2 μs     |                |                  | **6.75 μs** | 10.0 μs |
| fragmented    | 3.75 μs |                      | 46.1 μs |               |                 | 11.8 μs |               |                 | 7.62 μs     |                |                  | **3.38 μs** | 5.33 μs |
| chained       | 11.3 μs |                      | 188 μs  |               |                 | 11.7 μs |               |                 | 45.3 μs     |                |                  | **10.4 μs** | 18.1 μs |
| multi_20      | 52.7 μs |                      | 548 μs  |               |                 | 61.6 μs |               |                 | 133 μs      |                |                  | **52.4 μs** | 88.6 μs |
| empty_systems | 2.62 μs |                      | 9.42 μs |               |                 | 22.2 μs |               |                 | **2.12 μs** |                |                  | 2.42 μs     | 3.17 μs |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 16.9 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 49.4 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 12.8 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 65.0 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 166.9 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.8 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

## 1000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved     | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata   | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :---------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :----- | :------ |
| create_empty           | 1.62 ms | 695 μs               | 829 μs  |               |                 | **77.2 μs** |               |                 | 1.18 ms  |                |                  | 411 μs | 287 μs  |
| create_with_components | 3.07 ms | 2.31 ms              |         | 3.40 ms       | 3.66 ms         |             | **94.5 μs**   | 454 μs          | 2.63 ms  |                |                  | 507 μs | 387 μs  |
| destroy                | 710 μs  | 683 μs               | 467 μs  |               |                 |             | **169 μs**    | 450 μs          | 168 ms   |                |                  | 444 μs | 410 μs  |

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
| get    | 33.8 μs | 32.2 μs              | 226 μs  |               |                 | 160 μs  |               |                 | 63.7 μs  |                |                  | **23.6 μs** | 24.6 μs |
| set    | 36.1 μs | 30.1 μs              | 233 μs  |               |                 | 494 μs  |               |                 | 68.1 μs  |                |                  | **26.8 μs** | 27.5 μs |
| add    | 961 μs  | 955 μs               |         | 1.80 ms       | 1.94 ms         |         | **29.0 μs**   | 622 μs          |          | 1.39 ms        | 1.25 ms          | 267 μs      | 150 μs  |
| remove | 590 μs  | 578 μs               | 1.06 ms |               |                 |         | **22.8 μs**   | 699 μs          | 691 μs   |                |                  | 213 μs      | 103 μs  |

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
| has    | 145 μs  | 143 μs               | 204 μs  |               |                 | 75.0 μs |               |                 | 21.7 μs  |                |                  | **15.9 μs** | 15.9 μs |
| add    | 882 μs  | 854 μs               |         | 1.41 ms       | 1.54 ms         |         | **22.9 μs**   | 614 μs          |          | 1.26 ms        | 1.12 ms          | 215 μs      | 104 μs  |
| remove | 584 μs  | 574 μs               | 1.06 ms |               |                 |         | **23.0 μs**   | 674 μs          | 693 μs   |                |                  | 213 μs      | 103 μs  |

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
| throughput    | 55.3 μs |                      | 492 μs  |               |                 | **41.4 μs** |               |                 | 122 μs      |                |                  | 51.7 μs | 69.4 μs |
| overlap       | 73.7 μs |                      | 1.34 ms |               |                 | **37.4 μs** |               |                 | 183 μs      |                |                  | 65.6 μs | 91.3 μs |
| fragmented    | 31.1 μs |                      | 301 μs  |               |                 | **29.2 μs** |               |                 | 75.6 μs     |                |                  | 30.0 μs | 48.6 μs |
| chained       | 126 μs  |                      | 1.91 ms |               |                 | **54.1 μs** |               |                 | 447 μs      |                |                  | 114 μs  | 180 μs  |
| multi_20      | 571 μs  |                      | 5.50 ms |               |                 | **330 μs**  |               |                 | 1.55 ms     |                |                  | 523 μs  | 893 μs  |
| empty_systems | 2.75 μs |                      | 9.71 μs |               |                 | 22.1 μs     |               |                 | **2.12 μs** |                |                  | 2.42 μs | 3.17 μs |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 157.5 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 471.3 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 86.6 kB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 627.5 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 1.6 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.8 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |

## 10000 entities

### Entity

#### Execution Time

| test                   | concord | concord-no-serialize | ecs-lua | ecs-lua-batch | ecs-lua-nobatch | evolved    | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata    | tinyecs |
| :--------------------- | :------ | :------------------- | :------ | :------------ | :-------------- | :--------- | :------------ | :-------------- | :------- | :------------- | :--------------- | :------ | :------ |
| create_empty           | 16.0 ms | 6.79 ms              | 9.13 ms |               |                 | **766 μs** |               |                 | 11.8 ms  |                |                  | 4.26 ms | 1.75 ms |
| create_with_components | 30.7 ms | 23.5 ms              |         | 35.5 ms       | 38.2 ms         |            | **950 μs**    | 4.54 ms         | 26.5 ms  |                |                  | 5.26 ms | 2.81 ms |
| destroy                | 7.95 ms | 7.67 ms              | 5.47 ms |               |                 |            | **1.66 ms**   | 4.49 ms         | 16.7 s   |                |                  | 4.57 ms | 2.16 ms |

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
| get    | 1.28 ms | 1.12 ms              | 6.03 ms |               |                 | 1.61 ms |               |                 | 1.29 ms  |                |                  | **493 μs** | 630 μs  |
| set    | 1.28 ms | 1.17 ms              | 6.11 ms |               |                 | 4.94 ms |               |                 | 1.48 ms  |                |                  | **541 μs** | 669 μs  |
| add    | 10.4 ms | 10.1 ms              |         | 21.4 ms       | 22.4 ms         |         | **261 μs**    | 6.22 ms         |          | 14.2 ms        | 12.7 ms          | 2.81 ms    | 1.93 ms |
| remove | 7.11 ms | 6.85 ms              | 14.9 ms |               |                 |         | **199 μs**    | 6.86 ms         | 7.59 ms  |                |                  | 2.30 ms    | 1.26 ms |

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
| has    | 2.14 ms | 2.18 ms              | 4.34 ms |               |                 | 740 μs  |               |                 | 638 μs   |                |                  | **222 μs** | 291 μs  |
| add    | 9.73 ms | 9.42 ms              |         | 17.6 ms       | 19.1 ms         |         | **198 μs**    | 6.19 ms         |          | 12.9 ms        | 11.5 ms          | 2.38 ms    | 1.34 ms |
| remove | 7.17 ms | 6.61 ms              | 15.5 ms |               |                 |         | **198 μs**    | 6.75 ms         | 7.48 ms  |                |                  | 2.30 ms    | 1.29 ms |

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
| throughput    | 586 μs  |                      | 7.08 ms |               |                 | **392 μs**  |               |                 | 1.25 ms     |                |                  | 513 μs  | 691 μs  |
| overlap       | 1.00 ms |                      | 16.7 ms |               |                 | **323 μs**  |               |                 | 1.96 ms     |                |                  | 665 μs  | 912 μs  |
| fragmented    | 513 μs  |                      | 5.42 ms |               |                 | **211 μs**  |               |                 | 795 μs      |                |                  | 298 μs  | 482 μs  |
| chained       | 2.17 ms |                      | 26.7 ms |               |                 | **480 μs**  |               |                 | 4.65 ms     |                |                  | 1.35 ms | 2.10 ms |
| multi_20      | 11.2 ms |                      | 103 ms  |               |                 | **3.73 ms** |               |                 | 32.0 ms     |                |                  | 8.08 ms | 13.5 ms |
| empty_systems | 2.88 μs |                      | 11.3 μs |               |                 | 22.0 μs     |               |                 | **2.12 μs** |                |                  | 2.42 μs | 3.21 μs |

#### Memory Usage

| test          | concord | concord-no-serialize | ecs-lua  | ecs-lua-batch | ecs-lua-nobatch | evolved | evolved-batch | evolved-nobatch | lovetoys | lovetoys-batch | lovetoys-nobatch | nata | tinyecs |
| :------------ | :------ | :------------------- | :------- | :------------ | :-------------- | :------ | :------------ | :-------------- | :------- | :------------- | :--------------- | :--- | :------ |
| throughput    | **0 B** |                      | 1.6 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| overlap       | **0 B** |                      | 4.7 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| fragmented    | **0 B** |                      | 824.9 kB |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| chained       | **0 B** |                      | 6.3 MB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| multi_20      | **0 B** |                      | 15.6 MB  |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
| empty_systems | **0 B** |                      | 2.8 kB   |               |                 | 0 B     |               |                 | 0 B      |                |                  | 0 B  | 0 B     |
