"""Spot-check benchmark results for anomalies across interpreters."""

from __future__ import annotations

from itertools import combinations
from pathlib import Path

import polars as pl

RESULTS_DIR = Path(__file__).resolve().parent.parent / "results"

TIME = "s"
MEMORY = "kb"

TIME_NOISE_FLOOR = 1e-5  # 10µs — timer quantization floor
MEMORY_NOISE_FLOOR = 1  # 1 KB — allocator granularity floor

MUTATING_OPS = {"add", "remove", "set"}
READONLY_OPS = {"get", "has"}

_DEDICATED_PAIRS = (
    frozenset({"lua5.1", "luajit-on"}),
    frozenset({"lua5.1", "luajit-off"}),
    frozenset({"luajit-off", "luajit-on"}),
)

BATCH_PAIRS: dict[str, str] = {
    "ecs-lua-nobatch": "ecs-lua-batch",
    "evolved-nobatch": "evolved-batch",
    "lovetoys-nobatch": "lovetoys-batch",
}


# =============================================================================
# Data Loadingbwbbbb
# =============================================================================


def load_all_results(results_dir: Path) -> pl.DataFrame:
    """Load all results CSVs, tagging each with its interpreter name."""
    dfs = []
    for csv_path in sorted(results_dir.glob("*/results.csv")):
        interpreter = csv_path.parent.name
        df = pl.read_csv(csv_path).with_columns(
            pl.lit(interpreter).alias("interpreter"),
        )
        dfs.append(df)

    if not dfs:
        msg = f"No results.csv files found in {results_dir}"
        raise FileNotFoundError(msg)

    return pl.concat(dfs, how="diagonal")


# =============================================================================
# Check Helpers
# =============================================================================


def _print_check(name: str, findings: list[str]) -> int:
    """Print findings for a check, return count."""
    if findings:
        print(f"\n### {name} ({len(findings)} findings)")
        for f in findings:
            print(f)
    else:
        print(f"\n### {name}: OK")
    return len(findings)


# =============================================================================
# Checks
# =============================================================================


def check_data_completeness(df: pl.DataFrame) -> int:
    """Flag missing (group,test,framework) combos and unpaired s/kb rows."""
    findings: list[str] = []

    # Expected combos: every (group, test, framework) should appear in all interpreters
    combos = df.select("group", "test", "framework").unique()
    interpreters = df.select("interpreter").unique()
    join_cols = ["group", "test", "framework", "interpreter"]

    expected = combos.join(interpreters, how="cross")
    actual = df.select(join_cols).unique()
    missing = expected.join(actual, on=join_cols, how="anti").sort(join_cols)

    findings.extend(
        f"  {row['group']}/{row['test']} [{row['framework']}] missing in: {row['interpreter']}"
        for row in missing.to_dicts()
    )

    # Check for unpaired s/kb: every (interpreter, entities, group, test, framework) needs both
    key_cols = ["interpreter", "entities", "group", "test", "framework"]
    unit_counts = df.group_by(key_cols).agg(pl.col("unit").n_unique().alias("n_units"))
    unpaired = unit_counts.filter(pl.col("n_units") != 2)
    findings.extend(
        f"  {row['interpreter']}: {row['group']}/{row['test']}"
        f" [{row['framework']}] entities={row['entities']} has {row['n_units']} unit(s)"
        for row in unpaired.to_dicts()
    )

    return _print_check("Data Completeness", findings)


def check_cross_interpreter_time(df: pl.DataFrame) -> int:
    """Flag cross-interpreter time anomalies."""
    findings: list[str] = []
    time_df = df.filter(pl.col("unit") == TIME)

    key_cols = ["entities", "group", "test", "framework"]
    pivoted = time_df.pivot(on="interpreter", index=key_cols, values="median")

    interpreters = [c for c in pivoted.columns if c not in key_cols]

    for row in pivoted.to_dicts():
        label = f"{row['group']}/{row['test']} [{row['framework']}] entities={row['entities']}"
        values: dict[str, float] = {i: row[i] for i in interpreters if row.get(i) is not None}

        # luajit-on should be fastest; flag ≥1.5x slower than any baseline
        for baseline in ("lua5.1", "luajit-off"):
            if "luajit-on" in values and baseline in values:
                ratio = values["luajit-on"] / values[baseline]
                if ratio >= 1.5:
                    findings.append(f"  {label}: luajit-on {ratio:.2f}x SLOWER than {baseline}")

        if "luajit-off" in values and "lua5.1" in values:
            ratio = max(values["luajit-off"], values["lua5.1"]) / min(
                values["luajit-off"],
                values["lua5.1"],
            )
            if ratio > 5:
                findings.append(f"  {label}: luajit-off vs lua5.1 ratio={ratio:.2f}x")

        for a, b in combinations(sorted(values), 2):
            if {a, b} in _DEDICATED_PAIRS:
                continue
            ratio = max(values[a], values[b]) / min(values[a], values[b])
            if ratio > 10:
                findings.append(f"  {label}: {a} vs {b} ratio={ratio:.2f}x")

    return _print_check("Cross-Interpreter Time", findings)


def check_cross_interpreter_memory(df: pl.DataFrame) -> int:
    """Flag cross-interpreter memory anomalies."""
    findings: list[str] = []
    mem_df = df.filter(pl.col("unit") == MEMORY)

    key_cols = ["entities", "group", "test", "framework"]
    pivoted = mem_df.pivot(on="interpreter", index=key_cols, values="median")
    interpreters = [c for c in pivoted.columns if c not in key_cols]

    for row in pivoted.to_dicts():
        label = f"{row['group']}/{row['test']} [{row['framework']}] entities={row['entities']}"
        values: dict[str, float] = {i: row[i] for i in interpreters if row.get(i) is not None}

        for interp, val in values.items():
            if val <= 0:
                findings.append(f"  {label}: {interp} memory={val:.4g} (zero/negative)")

        positive = {k: v for k, v in values.items() if v > 0}
        if len(positive) >= 2:
            max_val = max(positive.values())
            min_val = min(positive.values())
            if max_val < MEMORY_NOISE_FLOOR:
                continue
            ratio = max_val / min_val
            if ratio > 3:
                findings.append(f"  {label}: memory max/min ratio={ratio:.2f}x")

    return _print_check("Cross-Interpreter Memory", findings)


def check_scaling_consistency(df: pl.DataFrame) -> int:
    """Flag metrics that decrease or explode with entity count."""
    findings: list[str] = []

    key_cols = ["interpreter", "group", "test", "framework", "unit"]
    sorted_df = df.sort("entities")

    for keys, group_df in sorted_df.group_by(key_cols, maintain_order=True):
        interp, group, test, fw, unit = keys
        label = f"{interp}: {group}/{test} [{fw}] ({unit})"

        medians = group_df["median"].to_list()
        entities = group_df["entities"].to_list()

        noise_floor = TIME_NOISE_FLOOR if unit == TIME else MEMORY_NOISE_FLOOR
        for i in range(1, len(medians)):
            prev, curr = medians[i - 1], medians[i]
            below_floor = prev < noise_floor and curr < noise_floor
            if prev > 0 and curr < prev:
                decrease_pct = (prev - curr) / prev
                if below_floor and decrease_pct < 0.1:
                    continue
                findings.append(
                    f"  {label}: DECREASED {entities[i - 1]}->{entities[i]}"
                    f" ({prev:.4g}->{curr:.4g})",
                )
            if prev > 0 and curr > 0 and not below_floor:
                entity_ratio = entities[i] / entities[i - 1]
                metric_ratio = curr / prev
                if entity_ratio <= 100 and metric_ratio > 1000:
                    findings.append(
                        f"  {label}: {entities[i - 1]}->{entities[i]}"
                        f" metric grew {metric_ratio:.0f}x for {entity_ratio:.0f}x entities",
                    )

    return _print_check("Scaling Consistency", findings)


def check_ci_red_flags(df: pl.DataFrame) -> int:
    """Flag CI width anomalies."""
    findings: list[str] = []

    for row in df.to_dicts():
        label = (
            f"{row['interpreter']}: {row['group']}/{row['test']}"
            f" [{row['framework']}] entities={row['entities']} ({row['unit']})"
        )
        median = row["median"]
        ci_lower = row["ci_lower"]
        ci_upper = row["ci_upper"]

        if median > 0:
            ci_width = ci_upper - ci_lower
            ci_ratio = ci_width / median

            if row["unit"] == TIME:
                # Time CI ratio >2 means very noisy measurement
                if ci_ratio > 2:
                    findings.append(f"  {label}: CI ratio={ci_ratio:.2f} (very wide)")
                # Collapsed CI — only flag above 10µs; below that, timer
                # quantization (~1µs) makes ci_lower == ci_upper == median expected
                if ci_ratio < 1e-6 and median > 1e-5:
                    findings.append(f"  {label}: CI collapsed (ratio={ci_ratio:.2e})")

            elif row["unit"] == MEMORY:
                # Memory CI should be collapsed (deterministic allocation);
                # below noise floor, allocator granularity makes jitter expected
                if ci_ratio > 0.1 and median >= MEMORY_NOISE_FLOOR:
                    findings.append(f"  {label}: memory CI not collapsed (ratio={ci_ratio:.2f})")

    return _print_check("CI Red Flags", findings)


def check_variant_consistency(df: pl.DataFrame) -> int:
    """Flag cases where batch variant is slower than nobatch."""
    findings: list[str] = []
    time_df = df.filter(pl.col("unit") == TIME)

    join_keys = ["interpreter", "entities", "group", "test"]
    for nobatch, batch in BATCH_PAIRS.items():
        nb_df = time_df.filter(pl.col("framework") == nobatch)
        b_df = time_df.filter(pl.col("framework") == batch).select(
            *join_keys,
            pl.col("median").alias("batch_median"),
        )
        merged = nb_df.join(b_df, on=join_keys)
        slower = merged.filter(
            pl.col("median") > 0,
            pl.col("median") < pl.col("batch_median"),
        ).with_columns(
            (pl.col("batch_median") / pl.col("median")).alias("ratio"),
        )
        findings.extend(
            f"  {row['interpreter']}: {row['group']}/{row['test']}"
            f" entities={row['entities']}: {nobatch}({row['median']:.4g}) FASTER than"
            f" {batch}({row['batch_median']:.4g}), ratio={row['ratio']:.2f}x"
            for row in slower.to_dicts()
        )

    return _print_check("Variant Consistency", findings)


def check_cross_test_consistency(df: pl.DataFrame) -> int:
    """Flag read-only ops (get/has) costing more than mutating ops."""
    findings: list[str] = []
    time_df = df.filter(pl.col("unit") == TIME)

    key_cols = ["interpreter", "entities", "group", "framework"]

    for keys, group_df in time_df.group_by(key_cols, maintain_order=True):
        interp, entities, _group, fw = keys
        tests = dict(zip(group_df["test"], group_df["median"], strict=False))

        readonly_vals = {t: tests[t] for t in READONLY_OPS if t in tests}
        mutating_vals = {t: tests[t] for t in MUTATING_OPS if t in tests}

        if not readonly_vals or not mutating_vals:
            continue

        max_ro_name, max_ro_val = max(readonly_vals.items(), key=lambda kv: kv[1])
        min_mut_name, min_mut_val = min(mutating_vals.items(), key=lambda kv: kv[1])

        if min_mut_val > 0 and max_ro_val > min_mut_val * 1.5:
            ratio = max_ro_val / min_mut_val
            findings.append(
                f"  {interp}: [{fw}] entities={entities}:"
                f" {max_ro_name}({max_ro_val:.4g})"
                f" > {min_mut_name}({min_mut_val:.4g}),"
                f" ratio={ratio:.2f}x",
            )

    # Memory: get/has should have ~0 allocation
    mem_df = df.filter(pl.col("unit") == MEMORY)
    findings.extend(
        f"  {row['interpreter']}: {row['group']}/{row['test']}"
        f" [{row['framework']}] entities={row['entities']}:"
        f" memory={row['median']:.4g} kb (high for read-only)"
        for row in mem_df.filter(pl.col("test").is_in(list(READONLY_OPS))).to_dicts()
        if row["median"] > 1  # >1 KB is suspicious for a read-only op
    )

    return _print_check("Cross-Test Consistency", findings)


# =============================================================================
# Main
# =============================================================================


def main() -> None:
    """Run all spot checks and print summary."""
    print("=" * 60)
    print("Benchmark Spot Check")
    print("=" * 60)

    df = load_all_results(RESULTS_DIR)
    interpreters = sorted(df["interpreter"].unique().to_list())
    print(
        f"\nLoaded {len(df)} rows from {len(interpreters)} interpreters: {', '.join(interpreters)}",
    )

    checks = [
        check_data_completeness,
        check_cross_interpreter_time,
        check_cross_interpreter_memory,
        check_scaling_consistency,
        check_ci_red_flags,
        check_variant_consistency,
        check_cross_test_consistency,
    ]
    total = sum(check(df) for check in checks)

    print("\n" + "=" * 60)
    print(f"Total findings: {total}")
    print("=" * 60)


if __name__ == "__main__":
    main()
