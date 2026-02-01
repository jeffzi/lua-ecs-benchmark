import argparse
import math
import platform
import re
import subprocess
from pathlib import Path
from typing import cast

import altair as alt
import humanize
import polars as pl
import psutil
from tabulate import tabulate

# =============================================================================
# Constants
# =============================================================================


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
README_PATH = REPO_ROOT / "README.md"

TIME = "s"
MEMORY = "kb"

UNIT_DISPLAY_NAMES = {
    TIME: "Execution Time",
    MEMORY: "Memory Usage",
}

TIME_UNITS = {
    "m": 60 * 1e9,
    "s": 1e9,
    "ms": 1e6,
    "µs": 1e3,
    "ns": 1,
}

INTERPRETER_ORDER = ["luajit-on", "luajit-off", "lua5.1", "lua5.4"]

MAX_RELATIVE_PERFORMANCE = 20.0


# =============================================================================
# Colors
# =============================================================================

# Wong colorblind-safe palette: https://davidmathlogic.com/colorblind/
COLORBLIND_PALETTE = [
    "#0173b2",  # blue
    "#de8f05",  # orange
    "#029e73",  # bluish green
    "#cc78bc",  # reddish purple
    "#d55e00",  # vermillion
    "#56b4e9",  # sky blue
    "#f0e442",  # yellow
    "#949494",  # gray (fallback)
]


def generate_variant_shades(hex_color: str, count: int) -> list[str]:
    """Generate up to 3 shades of a base color for variants."""
    multipliers = [1.0, 0.7, 0.5][:count]
    r, g, b = int(hex_color[1:3], 16), int(hex_color[3:5], 16), int(hex_color[5:7], 16)
    return [
        f"#{int(r + (255 - r) * (1 - m)):02x}"
        f"{int(g + (255 - g) * (1 - m)):02x}"
        f"{int(b + (255 - b) * (1 - m)):02x}"
        for m in multipliers
    ]


def find_base(name: str, frameworks: set[str]) -> str:
    """Find root ancestor that exists in framework set."""
    while "-" in name:
        parent = name.rsplit("-", 1)[0]
        if parent not in frameworks:
            break
        name = parent
    return name


def build_framework_color_scale(frameworks: list[str]) -> tuple[list[str], list[str]]:
    """Build color scale mapping frameworks to colors, returning (domain, range)."""
    unique_frameworks = set(frameworks)

    base_to_variants: dict[str, list[str]] = {}
    for framework in sorted(frameworks):
        base = find_base(framework, unique_frameworks)
        base_to_variants.setdefault(base, []).append(framework)

    domain, colors = [], []
    for i, variants in enumerate(base_to_variants.values()):
        base_color = COLORBLIND_PALETTE[i] if i < len(COLORBLIND_PALETTE) else "#949494"
        shades = generate_variant_shades(base_color, len(variants))
        domain.extend(variants)
        colors.extend(shades)

    return domain, colors


# =============================================================================
# Results Loading
# =============================================================================


def load_results(results_dir: Path) -> pl.DataFrame:
    """Load CSVs from interpreter subdirs, adding interpreter column.

    Args:
        results_dir: Directory containing interpreter subdirectories,
            each with a results.csv file.

    Returns:
        Combined DataFrame with interpreter column added.
    """
    dfs = []
    for csv_path in sorted(results_dir.glob("*/results.csv")):
        interpreter = csv_path.parent.name
        df = pl.read_csv(csv_path).with_columns(
            pl.lit(interpreter).alias("interpreter")
        )
        dfs.append(df)

    if not dfs:
        raise ValueError(
            f"No results.csv files found in subdirectories of {results_dir}"
        )

    return pl.concat(dfs, how="diagonal")


# =============================================================================
# System Info
# =============================================================================


def get_cpu_model() -> str:
    """Get CPU model name."""
    system = platform.system()
    try:
        if system == "Darwin":
            result = subprocess.run(
                ["sysctl", "-n", "machdep.cpu.brand_string"],
                capture_output=True,
                text=True,
                check=True,
            )
            return result.stdout.strip()
        if system == "Linux":
            with open("/proc/cpuinfo") as f:
                for line in f:
                    if line.startswith("model name"):
                        return line.split(":")[1].strip()
    except (subprocess.CalledProcessError, FileNotFoundError, OSError):
        pass
    return platform.processor() or platform.machine()


def get_os_version() -> str:
    """Get concise OS version string."""
    system = platform.system()
    if system == "Darwin":
        return f"macOS {platform.mac_ver()[0]}" if platform.mac_ver()[0] else "macOS"
    if system == "Linux":
        try:
            import distro

            return distro.name(pretty=True)
        except ImportError:
            pass
    return f"{system} {platform.release()}"


def get_specs() -> str:
    """Build formatted system specifications string."""
    specs = [
        f"OS: {get_os_version()}",
        f"CPU: {get_cpu_model()}",
        f"Cores: {psutil.cpu_count(logical=False)} cores ({psutil.cpu_count(logical=True)} threads)",
    ]
    cpu_freq = psutil.cpu_freq()
    if cpu_freq and cpu_freq.max:
        specs.append(f"Max Frequency: {cpu_freq.max / 1000:.2f} GHz")
    specs.append(f"Memory: {psutil.virtual_memory().total / (1024**3):.0f} GB")
    return "\n".join(specs)


# =============================================================================
# Formatting
# =============================================================================


def update_section(content: str, marker: str, new_content: str) -> str:
    """Replace content between AUTO-GENERATED-CONTENT markers."""
    pattern = rf"(<!-- AUTO-GENERATED-CONTENT:START \({marker}\) -->\n).*?(\n<!-- AUTO-GENERATED-CONTENT:END -->)"
    replacement = rf"\g<1>{new_content}\g<2>"
    return re.sub(pattern, replacement, content, flags=re.DOTALL)


def natural_duration(ns: float) -> str:
    """Convert nanoseconds to human-readable duration string."""
    for unit, factor in TIME_UNITS.items():
        if ns >= factor:
            return f"{ns / factor:.3g} {unit}"
    return f"{ns} ns"


def format_value_expr(col: str, unit: str) -> pl.Expr:
    """Format a column value based on unit type (TIME or MEMORY)."""
    c = pl.col(col)
    if unit == TIME:
        return (
            pl.when(c >= 1)
            .then(c.round(0).cast(pl.Utf8) + " s")
            .when(c >= 0.001)
            .then((c * 1000).round(0).cast(pl.Utf8) + " ms")
            .when(c >= 0.000001)
            .then((c * 1e6).round(0).cast(pl.Utf8) + " µs")
            .otherwise((c * 1e9).round(0).cast(pl.Utf8) + " ns")
        )
    return (
        pl.when(c >= 1000000)
        .then((c / 1000000).round(0).cast(pl.Utf8) + " GB")
        .when(c >= 1000)
        .then((c / 1000).round(0).cast(pl.Utf8) + " MB")
        .when(c >= 1)
        .then(c.round(0).cast(pl.Utf8) + " kB")
        .otherwise((c * 1000).round(0).cast(pl.Utf8) + " B")
    )


def format_value(value: float | None, unit: str, bold: bool = False) -> str:
    """Format a metric value with appropriate unit, optionally bold."""
    if value is None:
        return ""
    if unit == TIME:
        formatted = natural_duration(value * 1e9)
    else:
        formatted = humanize.naturalsize(value * 1e3).replace("Bytes", "B")
    return f"**{formatted}**" if bold else formatted


# =============================================================================
# Markdown Tables
# =============================================================================


def pivot_with_best_framework(
    df: pl.DataFrame, has_groups: bool
) -> tuple[pl.DataFrame, list[str]]:
    """Pivot dataframe by framework and identify best performer per row."""
    index_cols = ["unit", "entities", "test"]
    if has_groups:
        index_cols = ["group"] + index_cols

    pivoted = df.pivot(on="framework", index=index_cols, values="median")
    framework_cols = pivoted.select(pl.exclude(*index_cols)).columns

    sort_cols = ["entities", "_unit_order", "test"]
    if has_groups:
        sort_cols = ["group"] + sort_cols

    pivoted = (
        pivoted.with_columns(
            pl.col("unit").replace_strict({TIME: 0, MEMORY: 1}).alias("_unit_order"),
            pl.concat_list([pl.col(fw) for fw in framework_cols])
            .list.arg_min()
            .replace_strict(dict(enumerate(framework_cols)))
            .alias("_best_framework"),
        )
        .sort(sort_cols)
        .drop("_unit_order")
    )

    return pivoted, framework_cols


def format_table_row(row: dict, unit: str, framework_cols: list[str]) -> dict[str, str]:
    """Format a single row for markdown table output."""
    best = row["_best_framework"]
    formatted = {"test": row["test"]}
    for fw in framework_cols:
        formatted[fw] = format_value(row[fw], unit, bold=(fw == best))
    return formatted


def to_markdown_tables(df: pl.DataFrame) -> str:
    """Convert benchmark results to markdown tables grouped by group, then entity count."""
    has_groups = "group" in df.columns
    pivoted, framework_cols = pivot_with_best_framework(df, has_groups)
    sections = []

    if has_groups:
        for (group,), group_df in pivoted.group_by(["group"], maintain_order=True):
            sections.append(f"## {group.title()}")
            sections.append(_format_entity_tables(group_df, framework_cols))
    else:
        sections.append(_format_entity_tables(pivoted, framework_cols))

    return "\n\n".join(sections)


def _format_entity_tables(df: pl.DataFrame, framework_cols: list[str]) -> str:
    """Format tables grouped by entity count and unit."""
    sections = []

    for (entities,), entity_group in df.group_by(["entities"], maintain_order=True):
        sections.append(f"### {entities} entities")

        for (unit,), unit_group in entity_group.group_by(["unit"], maintain_order=True):
            sections.append(f"#### {UNIT_DISPLAY_NAMES[unit]}")
            rows = [
                format_table_row(row, unit, framework_cols)
                for row in unit_group.to_dicts()
            ]
            sections.append(tabulate(rows, headers="keys", tablefmt="pipe"))

    return "\n\n".join(sections)


# =============================================================================
# Charts
# =============================================================================


def create_unit_row(
    df: pl.DataFrame,
    framework_order: list[str],
    color_domain: list[str],
    color_range: list[str],
    present_interpreters: list[str],
    show_legend: bool,
    show_header: bool,
) -> alt.FacetChart:
    """Create a single row chart for one unit (Time or Memory), faceted by interpreter."""
    # Compute dynamic tick values for this unit
    max_raw = df["relative"].max()
    max_val = 1.0 if max_raw is None else cast(float, max_raw)
    max_tick = max(1, math.ceil(max_val))
    base_ticks = [1, 2, 5, 10, 15, 20]
    y_ticks = [t for t in base_ticks if t <= max_tick]
    # Only add max_tick if it's not too close to the last base tick (>10% gap)
    if y_ticks and max_tick not in y_ticks:
        if (max_tick - y_ticks[-1]) / max_tick > 0.1:
            y_ticks.append(max_tick)
    elif not y_ticks:
        y_ticks = [1, max_tick]

    base = alt.Chart(df)

    bars = base.mark_bar().encode(
        x=alt.X(
            "entities:N",
            title=None,
            axis=alt.Axis(grid=False, labelAngle=0, labelFontSize=9),
        ),
        y=alt.Y(
            "relative:Q",
            title=None,
            scale=alt.Scale(domain=[0, int(max_tick)]),
            axis=alt.Axis(
                grid=True,
                gridDash=[1, 3],
                gridColor="#ccc",
                labelExpr="datum.value + '×'",
                labelOverlap=True,
                labelFontSize=9,
                values=y_ticks,
                tickCount=len(y_ticks),
            ),
        ),
        xOffset=alt.XOffset("framework:N", sort=framework_order),
        color=alt.Color(
            "framework:N",
            scale=alt.Scale(domain=color_domain, range=color_range),
            legend=alt.Legend(title=None, labelFontSize=9) if show_legend else None,
        ),
    )

    labels = base.mark_text(
        angle=270,
        align="left",
        baseline="middle",
        dx=1,
        dy=0,
        fontSize=8,
        fontStyle="italic",
        font="Helvetica, Arial, sans-serif",
    ).encode(
        x=alt.X("entities:N"),
        xOffset=alt.XOffset("framework:N", sort=framework_order),
        y=alt.Y("relative:Q"),
        text="display_label:N",
    )

    return (
        (bars + labels)
        .properties(width=300, height=150)
        .facet(
            column=alt.Column(
                "interpreter:N",
                sort=present_interpreters,
                title=None,
                header=alt.Header(
                    labelAngle=0,
                    labelAlign="center",
                    labelFontSize=10,
                    labelFontWeight="bold",
                    labelPadding=0,
                )
                if show_header
                else alt.Header(labels=False),
            ),
            row=alt.Row(
                "unit_label:N",
                title=None,
                header=alt.Header(
                    labelAngle=-90,
                    labelAlign="center",
                    labelFontSize=10,
                    labelFontWeight="bold",
                    labelPadding=0,
                ),
            ),
        )
        .resolve_axis(x="independent")
        .resolve_axis(y="independent")
    )


def create_relative_chart(
    df: pl.DataFrame,
    test_name: str,
    framework_order: list[str],
    color_domain: list[str],
    color_range: list[str],
    present_interpreters: list[str],
) -> alt.VConcatChart:
    """Create a relative performance chart with vconcat for units, facet for interpreters."""
    # Compute relative performance per (interpreter, entities, unit) group
    df = df.with_columns(
        (pl.col("median") / pl.col("median").min())
        .over(["interpreter", "entities", "unit"])
        .alias("relative"),
    )

    # Filter out outliers
    df = df.filter(pl.col("relative") <= MAX_RELATIVE_PERFORMANCE)

    # Compute rank for label filtering (fastest=1, slowest=max)
    df = df.with_columns(
        pl.col("relative")
        .rank("min")
        .over(["interpreter", "entities", "unit"])
        .alias("rank"),
        pl.col("framework")
        .n_unique()
        .over(["interpreter", "entities", "unit"])
        .alias("n_frameworks"),
    )

    # Format labels based on unit type
    df = df.with_columns(
        pl.when(pl.col("unit") == TIME)
        .then(format_value_expr("median", TIME))
        .otherwise(format_value_expr("median", MEMORY))
        .alias("value_label")
    )

    # Mark which rows should have labels (fastest and slowest only)
    df = df.with_columns(
        pl.when((pl.col("rank") == 1) | (pl.col("rank") == pl.col("n_frameworks")))
        .then(pl.col("value_label"))
        .otherwise(pl.lit(""))
        .alias("display_label"),
        pl.col("unit")
        .replace_strict({TIME: "Time", MEMORY: "Memory"})
        .alias("unit_label"),
    )

    time_row = create_unit_row(
        df.filter(pl.col("unit") == TIME),
        framework_order,
        color_domain,
        color_range,
        present_interpreters,
        show_legend=True,
        show_header=True,
    )

    # Check if all memory values are effectively 0 (< 1 byte, displays as "0.0 B")
    memory_df = df.filter(pl.col("unit") == MEMORY)
    max_memory = cast(float | None, memory_df["median"].max())
    all_memory_zero = max_memory is None or max_memory < 0.001  # < 1 byte in kb

    if all_memory_zero:
        note_text = (
            alt.Chart(pl.DataFrame({"text": ["Note: memory omitted (no allocation)"]}))
            .mark_text(align="left", fontSize=8, fontStyle="italic", color="#666")
            .encode(text="text:N")
            .properties(width=300, height=15)
        )
        rows = alt.vconcat(time_row, note_text)
    else:
        memory_row = create_unit_row(
            memory_df,
            framework_order,
            color_domain,
            color_range,
            present_interpreters,
            show_legend=False,
            show_header=False,
        )
        rows = alt.vconcat(time_row, memory_row)

    return (
        rows.properties(
            title=alt.Title(
                test_name,
                subtitle="1× = best, by entity count",
                fontSize=12,
                subtitleFontSize=9,
            )
        )
        .configure_view(strokeWidth=0)
        .configure_legend(padding=0, offset=5)
        .resolve_legend(color="shared")
    )


def export_plots(
    df: pl.DataFrame, out_dir: Path, present_interpreters: list[str]
) -> dict[str, list[Path]]:
    """Export benchmark charts as SVG files, returning dict of group -> paths."""
    all_frameworks = df["framework"].unique().sort().to_list()
    color_domain, color_range = build_framework_color_scale(all_frameworks)

    has_groups = "group" in df.columns
    plot_paths: dict[str, list[Path]] = {}

    for (test,), test_df in df.sort("test").group_by(["test"], maintain_order=True):
        framework_order = sorted(test_df["framework"].unique().to_list())
        unique_frameworks = set(framework_order)
        filtered_domain = [d for d in color_domain if d in unique_frameworks]
        filtered_range = [
            c for d, c in zip(color_domain, color_range) if d in unique_frameworks
        ]

        if has_groups:
            group = cast(str, test_df["group"].first())
            chart_title = f"{group}/{test}"
            group_dir = out_dir / group
            group_dir.mkdir(exist_ok=True)
            plot_path = group_dir / f"{test}.svg"
        else:
            group = ""
            chart_title = cast(str, test)
            plot_path = out_dir / f"{test}.svg"

        chart = create_relative_chart(
            test_df,
            chart_title,
            framework_order,
            filtered_domain,
            filtered_range,
            present_interpreters,
        )

        chart.save(plot_path)
        plot_paths.setdefault(group, []).append(plot_path)

    return plot_paths


def plots_to_markdown(plot_paths: dict[str, list[Path]]) -> str:
    """Convert plot paths to markdown image sections, organized by group."""
    sections = []

    for group in sorted(plot_paths.keys()):
        paths = sorted(plot_paths[group])
        if group:
            sections.append(f"#### {group.title()}")
            for p in paths:
                sections.append(
                    f"##### {p.stem}\n![{p.stem} Plot]({p.relative_to(REPO_ROOT)})"
                )
        else:
            for p in paths:
                sections.append(
                    f"#### {p.stem}\n![{p.stem} Plot]({p.relative_to(REPO_ROOT)})"
                )

    return "\n\n".join(sections)


def outputs_to_markdown(results_dir: Path, interpreters: list[str]) -> str:
    """Generate markdown table of result files per interpreter."""
    rows = []
    for interp in interpreters:
        md_path = results_dir / interp / "results.md"
        csv_path = results_dir / interp / "results.csv"
        md_link = f"[results.md]({md_path.relative_to(REPO_ROOT)})"
        csv_link = f"[results.csv]({csv_path.relative_to(REPO_ROOT)})"
        rows.append({"Interpreter": interp, "Markdown": md_link, "CSV": csv_link})

    return tabulate(rows, headers="keys", tablefmt="pipe")


# =============================================================================
# Main
# =============================================================================


def export_markdown_tables(df: pl.DataFrame, results_dir: Path, specs: str) -> None:
    """Export markdown tables per interpreter subdirectory."""
    for (interpreter,), interpreter_df in df.group_by(
        ["interpreter"], maintain_order=True
    ):
        interpreter_df = interpreter_df.drop("interpreter")
        results_md_path = results_dir / interpreter / "results.md"
        results_md_path.parent.mkdir(parents=True, exist_ok=True)
        content = f"## Benchmark Environment\n\n```\n{specs}\n```\n\n{to_markdown_tables(interpreter_df)}"
        results_md_path.write_text(content)
        print(f"Exported markdown tables to {results_md_path.relative_to(Path.cwd())}")


def main(results_dir: Path, skip_readme: bool) -> None:
    """Export benchmark results to plots, markdown tables, and README."""
    df = load_results(results_dir)
    if df.is_empty():
        print("No benchmark data available. Nothing to export.")
        return

    specs = get_specs()
    interpreters = set(df["interpreter"].unique())
    ordered = [i for i in INTERPRETER_ORDER if i in interpreters]
    unordered = [i for i in interpreters if i not in ordered]
    present_interpreters = ordered + unordered

    plot_dir = results_dir / "plots"
    plot_dir.mkdir(exist_ok=True)
    plot_paths = export_plots(df, plot_dir, present_interpreters)
    print(f"Exported plots to {plot_dir.relative_to(Path.cwd())}")
    export_markdown_tables(df, results_dir, specs)

    if not skip_readme:
        readme = README_PATH.read_text()
        readme = update_section(readme, "BENCHMARK_ENVIRONMENT", f"```\n{specs}\n```")
        readme = update_section(readme, "PLOTS", plots_to_markdown(plot_paths))
        readme = update_section(
            readme, "OUTPUTS", outputs_to_markdown(results_dir, present_interpreters)
        )
        README_PATH.write_text(readme)
        print(f"Updated {README_PATH.relative_to(Path.cwd())}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Export benchmark results to plots and markdown tables."
    )
    parser.add_argument(
        "results_dir",
        type=Path,
        help="Results directory with interpreter subdirs (e.g., results/luajit-on/results.csv)",
    )
    parser.add_argument(
        "--skip-readme", action="store_true", help="Skip README.md generation"
    )
    args = parser.parse_args()
    main(args.results_dir.resolve(), args.skip_readme)
