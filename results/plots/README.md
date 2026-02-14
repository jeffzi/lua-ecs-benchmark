# Benchmark Plots

```text
OS: macOS 26.2
CPU: Apple M2 Max
Cores: 12 cores (12 threads)
Max Frequency: 3.50 GHz
Memory: 64 GB
```

Memory rows are omitted from charts when all frameworks report zero allocation for a given test.

- **[Entity](#entity):** [create_empty](#entity-create_empty) · [create_with_components](#entity-create_with_components) · [destroy](#entity-destroy)
- **[Component](#component):** [get](#component-get) · [set](#component-set) · [add](#component-add) · [remove](#component-remove)
- **[Tag](#tag):** [has](#tag-has) · [add](#tag-add) · [remove](#tag-remove)
- **[System](#system):** [throughput](#system-throughput) · [overlap](#system-overlap) · [fragmented](#system-fragmented) · [chained](#system-chained) · [multi_20](#system-multi_20) · [empty_systems](#system-empty_systems)

#### Entity

<a id="entity-create_empty"></a>

##### create_empty

![create_empty Plot](entity/create_empty.svg)

<a id="entity-create_with_components"></a>

##### create_with_components

![create_with_components Plot](entity/create_with_components.svg)

<a id="entity-destroy"></a>

##### destroy

![destroy Plot](entity/destroy.svg)

#### Component

<a id="component-get"></a>

##### get

![get Plot](component/get.svg)

<a id="component-set"></a>

##### set

![set Plot](component/set.svg)

<a id="component-add"></a>

##### add

![add Plot](component/add.svg)

<a id="component-remove"></a>

##### remove

![remove Plot](component/remove.svg)

#### Tag

<a id="tag-has"></a>

##### has

![has Plot](tag/has.svg)

<a id="tag-add"></a>

##### add

![add Plot](tag/add.svg)

<a id="tag-remove"></a>

##### remove

![remove Plot](tag/remove.svg)

#### System

<a id="system-throughput"></a>

##### throughput

![throughput Plot](system/throughput.svg)

<a id="system-overlap"></a>

##### overlap

![overlap Plot](system/overlap.svg)

<a id="system-fragmented"></a>

##### fragmented

![fragmented Plot](system/fragmented.svg)

<a id="system-chained"></a>

##### chained

![chained Plot](system/chained.svg)

<a id="system-multi_20"></a>

##### multi_20

![multi_20 Plot](system/multi_20.svg)

<a id="system-empty_systems"></a>

##### empty_systems

![empty_systems Plot](system/empty_systems.svg)
