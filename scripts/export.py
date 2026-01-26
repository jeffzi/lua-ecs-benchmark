import argparse
import math
import platform
import re
import subprocess
from pathlib import Path

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

UNIT_AXIS_CONFIG = {
    TIME: {
        "title": "Time",
        "label_expr": (
            "datum.value >= 1 ? format(datum.value, '.0f') + 's'"
            " : datum.value >= 0.001 ? format(datum.value * 1000, '.0f') + 'ms'"
            " : datum.value >= 0.000001 ? format(datum.value * 1e6, '.0f') + 'µs'"
            " : format(datum.value * 1e9, '.0f') + 'ns'"
        ),
    },
    MEMORY: {
        "title": "Memory",
        "label_expr": (
            "datum.value >= 1000000 ? format(datum.value / 1000000, '.0f') + ' GB'"
            " : datum.value >= 1000 ? format(datum.value / 1000, '.0f') + ' MB'"
            " : datum.value >= 1 ? format(datum.value, '.0f') + ' kB'"
            " : format(datum.value * 1000, '.0f') + ' B'"
        ),
    },
}

INTERPRETER_ORDER = ["luajit-on", "luajit-off", "lua5.1", "lua5.4"]


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
        if parent in frameworks:
            name = parent
        else:
            break
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

    return pl.concat(dfs)


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


def pivot_with_best_framework(df: pl.DataFrame) -> tuple[pl.DataFrame, list[str]]:
    """Pivot dataframe by framework and identify best performer per row."""
    pivoted = df.pivot(
        on="framework", index=["unit", "entities", "test"], values="median"
    )
    framework_cols = pivoted.select(pl.exclude("unit", "entities", "test")).columns
    min_val = pl.min_horizontal(pl.col(framework) for framework in framework_cols)

    pivoted = (
        pivoted.with_columns(
            pl.col("unit").replace_strict({TIME: 0, MEMORY: 1}).alias("_unit_order"),
            pl.coalesce(
                *[
                    pl.when(pl.col(fw) == min_val).then(pl.lit(fw))
                    for fw in framework_cols
                ]
            ).alias("_best_framework"),
        )
        .sort(["entities", "_unit_order", "test"])
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
    """Convert benchmark results to markdown tables grouped by entity count."""
    pivoted, framework_cols = pivot_with_best_framework(df)
    sections = []

    for (entities,), entity_group in pivoted.group_by(
        ["entities"], maintain_order=True
    ):
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


def create_unit_chart(
    df: pl.DataFrame,
    unit: str,
    framework_order: list[str],
    color_domain: list[str],
    color_range: list[str],
    present_interpreters: list[str],
) -> alt.Chart:
    """Create a chart for a single unit (time or memory)."""
    config = UNIT_AXIS_CONFIG[unit]

    # Compute baseline and domain for log scale bars (bars can't start from 0)
    y_min, y_max = df.select(
        pl.col("median").min().cast(pl.Float64).alias("min"),
        pl.col("median").max().cast(pl.Float64).alias("max"),
    ).row(0)
    baseline = y_min * 0.3
    df = df.with_columns(pl.lit(baseline).alias("_baseline"))

    # Generate tick values at powers of 10 only
    min_exp = math.floor(math.log10(baseline))
    max_exp = math.ceil(math.log10(y_max * 2))
    tick_values = [10**exp for exp in range(min_exp, max_exp + 1)]

    return (
        alt.Chart(df)
        .mark_bar()
        .encode(
            x=alt.X(
                "entities:N",
                title="Entities",
                axis=alt.Axis(grid=False, titleFontSize=10, titleFontWeight="normal"),
            ),
            y=alt.Y(
                "median:Q",
                scale=alt.Scale(type="log", base=10, domain=[baseline, y_max * 2]),
                title=None,
                axis=alt.Axis(
                    grid=False, labelExpr=config["label_expr"], values=tick_values
                ),
            ),
            y2="_baseline:Q",
            xOffset=alt.XOffset("framework:N", sort=framework_order),
            color=alt.Color(
                "framework:N",
                scale=alt.Scale(domain=color_domain, range=color_range),
                sort=framework_order,
                legend=alt.Legend(title="Framework"),
            ),
            row=alt.Row(
                "interpreter:N",
                sort=present_interpreters,
                title=None,
                header=alt.Header(labelAngle=0, labelAlign="left"),
            ),
        )
        .resolve_scale(y="independent")
        .resolve_axis(x="independent")
        .properties(
            width=350,
            height=150,
            title=alt.Title(config["title"], anchor="middle", dx=40),
        )
    )


def export_plots(
    df: pl.DataFrame, out_dir: Path, present_interpreters: list[str]
) -> list[Path]:
    """Export benchmark charts as SVG files, returning list of paths."""
    df = df.sort("framework")

    all_frameworks = df["framework"].unique().sort().to_list()
    color_domain, color_range = build_framework_color_scale(all_frameworks)

    plot_paths = []
    for (test,), test_df in df.sort("test").group_by(["test"], maintain_order=True):
        test_df = test_df.sort("median")
        framework_order = sorted(test_df["framework"].unique().to_list())
        unique_frameworks = set(framework_order)
        filtered_domain = [
            d for d, _ in zip(color_domain, color_range) if d in unique_frameworks
        ]
        filtered_range = [
            c for d, c in zip(color_domain, color_range) if d in unique_frameworks
        ]

        charts = []
        for (unit,), unit_df in test_df.group_by(["unit"], maintain_order=True):
            if unit in UNIT_AXIS_CONFIG:
                charts.append(
                    create_unit_chart(
                        unit_df,
                        unit,
                        framework_order,
                        filtered_domain,
                        filtered_range,
                        present_interpreters,
                    )
                )
        plot_path = out_dir / f"{test}.svg"
        chart = (
            alt.hconcat(*charts).resolve_legend(color="shared").properties(title=test)
        )
        chart.save(plot_path)
        plot_paths.append(plot_path)

    return plot_paths


def plots_to_markdown(plot_paths: list[Path]) -> str:
    """Convert plot paths to markdown image sections."""
    return "\n\n".join(
        f"#### {p.stem}\n![{p.stem} Plot]({p.relative_to(REPO_ROOT)})"
        for p in sorted(plot_paths)
    )


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
    interpreters = set(df["interpreter"].unique().to_list())
    present_interpreters = [i for i in INTERPRETER_ORDER if i in interpreters]
    present_interpreters.extend(
        i for i in interpreters if i not in present_interpreters
    )

    plot_dir = results_dir / "img"
    plot_dir.mkdir(exist_ok=True)
    plot_paths = export_plots(df, plot_dir, present_interpreters)
    print(f"Exported plots to {plot_dir.relative_to(Path.cwd())}")
    export_markdown_tables(df, results_dir, specs)

    if not skip_readme:
        readme = README_PATH.read_text()
        readme = update_section(readme, "BENCHMARK_ENVIRONMENT", f"```\n{specs}\n```")
        readme = update_section(readme, "PLOTS", plots_to_markdown(plot_paths))
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
