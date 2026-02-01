## Benchmark Environment

```
OS: macOS 26.2
CPU: Apple M2 Max
Cores: 12 cores (12 threads)
Max Frequency: 3.50 GHz
Memory: 64 GB
```

## Component

### 10 entities

#### Execution Time

| test         | tinyecs     | concord   |
|:-------------|:------------|:----------|
| add          | **1.56 µs** | 3.08 µs   |
| add_multi    | **2.08 µs** | 4.85 µs   |
| get          | **42 ns**   | 42 ns     |
| get_multi    | **42 ns**   | 42 ns     |
| remove       | **1.08 µs** | 1.5 µs    |
| remove_multi | **1.21 µs** | 1.92 µs   |

#### Memory Usage

| test         | tinyecs    | concord   |
|:-------------|:-----------|:----------|
| add          | **2.3 kB** | 2.9 kB    |
| add_multi    | **3.8 kB** | 7.9 kB    |
| get          | **0 B**    | 0 B       |
| get_multi    | **0 B**    | 0 B       |
| remove       | 695 B      | **398 B** |
| remove_multi | 695 B      | **398 B** |

### 100 entities

#### Execution Time

| test         | tinyecs     | concord   |
|:-------------|:------------|:----------|
| add          | **20.7 µs** | 34.1 µs   |
| add_multi    | **26.3 µs** | 54.8 µs   |
| get          | **125 ns**  | 167 ns    |
| get_multi    | **167 ns**  | 292 ns    |
| remove       | **18.2 µs** | 23.1 µs   |
| remove_multi | **17.7 µs** | 24.3 µs   |

#### Memory Usage

| test         | tinyecs     | concord    |
|:-------------|:------------|:-----------|
| add          | **20.8 kB** | 29.0 kB    |
| add_multi    | **36.4 kB** | 79.0 kB    |
| get          | **0 B**     | 0 B        |
| get_multi    | **0 B**     | 0 B        |
| remove       | 5.1 kB      | **4.0 kB** |
| remove_multi | 5.1 kB      | **4.0 kB** |

## Entity

### 10 entities

#### Execution Time

| test                   | tinyecs     | concord   |
|:-----------------------|:------------|:----------|
| create_empty           | **1.1 µs**  | 5.48 µs   |
| create_with_components | **1.5 µs**  | 9.65 µs   |
| destroy                | **1.62 µs** | 6.25 µs   |

#### Memory Usage

| test                   | tinyecs    | concord   |
|:-----------------------|:-----------|:----------|
| create_empty           | **1.8 kB** | 4.3 kB    |
| create_with_components | **4.0 kB** | 10.3 kB   |
| destroy                | **703 B**  | 796 B     |

### 100 entities

#### Execution Time

| test                   | tinyecs     | concord   |
|:-----------------------|:------------|:----------|
| create_empty           | **14.6 µs** | 133 µs    |
| create_with_components | **25.6 µs** | 115 µs    |
| destroy                | **22.1 µs** | 47 µs     |

#### Memory Usage

| test                   | tinyecs     | concord   |
|:-----------------------|:------------|:----------|
| create_empty           | **12.0 kB** | 43.1 kB   |
| create_with_components | **38.0 kB** | 102.5 kB  |
| destroy                | **5.1 kB**  | 7.9 kB    |

## System

### 10 entities

#### Execution Time

| test   | tinyecs   | concord     |
|:-------|:----------|:------------|
| update | 13.5 µs   | **3.58 µs** |

#### Memory Usage

| test   | tinyecs   | concord   |
|:-------|:----------|:----------|
| update | 2.7 kB    | **609 B** |

### 100 entities

#### Execution Time

| test   | tinyecs     | concord   |
|:-------|:------------|:----------|
| update | **63.5 µs** | 76.4 µs   |

#### Memory Usage

| test   | tinyecs   | concord    |
|:-------|:----------|:-----------|
| update | 6.6 kB    | **5.9 kB** |
