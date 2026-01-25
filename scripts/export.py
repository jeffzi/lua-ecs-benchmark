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

DEFAULT_TIME_UNIT = "s"
DEFAULT_MEMORY_UNIT = "kb"

EXCLUDED_FROM_PLOTS = {"nata"}

UNIT_DISPLAY_NAMES = {
    DEFAULT_TIME_UNIT: "Execution Time",
    DEFAULT_MEMORY_UNIT: "Memory Usage",
}

TIME_UNITS = {
    "m": 60 * 1e9,
    "s": 1e9,
    "ms": 1e6,
    "µs": 1e3,
    "ns": 1,
}

CWD = Path.cwd()
_SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = _SCRIPT_DIR.parent
README_PATH = REPO_ROOT / "README.md"

TIME_LABEL_EXPR = (
    "datum.value >= 1 ? format(datum.value, '.0f') + 's'"
    " : datum.value >= 0.001 ? format(datum.value * 1000, '.0f') + 'ms'"
    " : datum.value >= 0.000001 ? format(datum.value * 1e6, '.0f') + 'µs'"
    " : format(datum.value * 1e9, '.0f') + 'ns'"
)
MEMORY_LABEL_EXPR = (
    "datum.value >= 1000000 ? format(datum.value / 1000000, '.0f') + ' GB'"
    " : datum.value >= 1000 ? format(datum.value / 1000, '.0f') + ' MB'"
    " : datum.value >= 1 ? format(datum.value, '.0f') + ' kB'"
    " : format(datum.value * 1000, '.0f') + ' B'"
)

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


def _generate_variant_shades(hex_color: str, count: int) -> list[str]:
    """Generate up to 3 shades of a base color for variants."""
    # Lightness multipliers: base, lighter, lightest
    multipliers = [1.0, 0.7, 0.5][:count]
    shades = []
    r, g, b = int(hex_color[1:3], 16), int(hex_color[3:5], 16), int(hex_color[5:7], 16)
    for mult in multipliers:
        # Blend toward white for lighter shades
        nr = int(r + (255 - r) * (1 - mult))
        ng = int(g + (255 - g) * (1 - mult))
        nb = int(b + (255 - b) * (1 - mult))
        shades.append(f"#{nr:02x}{ng:02x}{nb:02x}")
    return shades


def _find_base(fw: str, fw_set: set[str]) -> str:
    """Find root ancestor that exists in framework set."""
    while "-" in fw:
        parent = fw.rsplit("-", 1)[0]
        if parent in fw_set:
            fw = parent
        else:
            break
    return fw


def _build_framework_color_scale(frameworks: list[str]) -> tuple[list[str], list[str]]:
    """Build color scale mapping frameworks to colors, returning (domain, range)."""
    fw_set = set(frameworks)

    base_to_variants: dict[str, list[str]] = {}
    for fw in sorted(frameworks):
        base = _find_base(fw, fw_set)
        base_to_variants.setdefault(base, []).append(fw)

    domain = []
    colors = []
    for i, (base, variants) in enumerate(base_to_variants.items()):
        # Assign colors from palette cyclically, gray fallback if exhausted
        base_color = COLORBLIND_PALETTE[i] if i < len(COLORBLIND_PALETTE) else "#949494"
        shades = _generate_variant_shades(base_color, len(variants))
        for variant, shade in zip(variants, shades):
            domain.append(variant)
            colors.append(shade)

    return domain, colors


# =============================================================================
# System Info
# =============================================================================


def _get_lua_info() -> tuple[str, str | None]:
    """Get Lua version and JIT status (if LuaJIT)."""
    try:
        result = subprocess.run(
            ["lua", "-v"],  # noqa: S607
            capture_output=True,
            text=True,
            check=True,
        )
        # Extract just version (e.g., "LuaJIT 2.1.0" from full output)
        version = result.stdout.strip().split("--")[0].strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "not found", None

    if "LuaJIT" not in version:
        return version, None

    try:
        result = subprocess.run(
            ["lua", "-e", "print(jit.status() and 'enabled' or 'disabled')"],  # noqa: S607
            capture_output=True,
            text=True,
            check=True,
        )
        jit_status = result.stdout.strip()
        return version, jit_status
    except (subprocess.CalledProcessError, FileNotFoundError):
        return version, None


def _get_cpu_model() -> str:
    """Get CPU model name."""
    system = platform.system()
    if system == "Darwin":
        try:
            result = subprocess.run(
                ["sysctl", "-n", "machdep.cpu.brand_string"],
                capture_output=True,
                text=True,
                check=True,
            )
            return result.stdout.strip()
        except (subprocess.CalledProcessError, FileNotFoundError):
            pass
    elif system == "Linux":
        try:
            with open("/proc/cpuinfo") as f:
                for line in f:
                    if line.startswith("model name"):
                        return line.split(":")[1].strip()
        except FileNotFoundError:
            pass
    return platform.processor() or platform.machine()


def _get_os_version() -> str:
    """Get concise OS version string."""
    system = platform.system()
    if system == "Darwin":
        mac_ver = platform.mac_ver()[0]
        return f"macOS {mac_ver}" if mac_ver else "macOS"
    if system == "Linux":
        try:
            import distro

            return distro.name(pretty=True)
        except ImportError:
            return f"Linux {platform.release()}"
    return f"{system} {platform.release()}"


def _get_specs() -> str:
    """Build formatted system specifications string."""
    lua_version, jit_status = _get_lua_info()
    lua_str = f"{lua_version} (JIT {jit_status})" if jit_status else lua_version

    physical = psutil.cpu_count(logical=False)
    logical = psutil.cpu_count(logical=True)
    cores_str = f"{physical} cores ({logical} threads)"

    specs = [
        f"Lua: {lua_str}",
        f"OS: {_get_os_version()}",
        f"CPU: {_get_cpu_model()}",
        f"Cores: {cores_str}",
    ]

    cpu_freq = psutil.cpu_freq()
    if cpu_freq and cpu_freq.max:
        specs.append(f"Max Frequency: {cpu_freq.max / 1000:.2f} GHz")

    mem = psutil.virtual_memory()
    specs.append(f"Memory: {mem.total / (1024**3):.0f} GB")

    return "\n".join(specs)


# =============================================================================
# Formatting
# =============================================================================


def _update_section(content: str, marker: str, new_content: str) -> str:
    """Replace content between AUTO-GENERATED-CONTENT markers."""
    pattern = rf"(<!-- AUTO-GENERATED-CONTENT:START \({marker}\) -->\n).*?(\n<!-- AUTO-GENERATED-CONTENT:END -->)"
    replacement = rf"\g<1>{new_content}\g<2>"
    return re.sub(pattern, replacement, content, flags=re.DOTALL)


def _natural_duration(ns: float) -> str:
    """Convert nanoseconds to human-readable duration string."""
    for unit, factor in TIME_UNITS.items():
        if ns >= factor:
            return f"{ns / factor:.3g} {unit}"
    return f"{ns} ns"


def _format_value(value: float | None, unit: str, bold: bool = False) -> str:
    """Format a metric value with appropriate unit, optionally bold."""
    if value is None:
        return ""
    if unit == DEFAULT_TIME_UNIT:
        formatted = _natural_duration(value * 1e9)
    else:
        formatted = humanize.naturalsize(value * 1e3).replace("Bytes", "B")
    return f"**{formatted}**" if bold else formatted


# =============================================================================
# Markdown Tables
# =============================================================================


def _pivot_with_best_framework(df: pl.DataFrame) -> tuple[pl.DataFrame, list[str]]:
    """Pivot dataframe by framework and identify best performer per row."""
    pivoted = df.pivot(
        on="framework", index=["unit", "entities", "test"], values="median"
    )
    framework_cols = pivoted.select(pl.exclude("unit", "entities", "test")).columns

    min_val = pl.min_horizontal(pl.col(fw) for fw in framework_cols)
    best_fw_expr = pl.coalesce(
        *[pl.when(pl.col(fw) == min_val).then(pl.lit(fw)) for fw in framework_cols]
    )

    pivoted = (
        pivoted.with_columns(
            pl.col("unit")
            .replace_strict({DEFAULT_TIME_UNIT: 0, DEFAULT_MEMORY_UNIT: 1})
            .alias("_unit_order"),
            best_fw_expr.alias("_best_framework"),
        )
        .sort(["entities", "_unit_order", "test"])
        .drop("_unit_order")
    )
    return pivoted, framework_cols


def _to_markdown_tables(df: pl.DataFrame) -> str:
    """Convert benchmark results to markdown tables grouped by entity count."""
    pivoted, framework_cols = _pivot_with_best_framework(df)
    mds: list[str] = []

    for (entities,), group in pivoted.group_by(["entities"], maintain_order=True):
        mds.append(f"#### {entities} entities")

        for (unit,), unit_group in group.group_by(["unit"], maintain_order=True):
            mds.append(f"##### {UNIT_DISPLAY_NAMES[unit]}")
            rows = []
            for row in unit_group.to_dicts():
                best_fw = row["_best_framework"]
                formatted = {"test": row["test"]}
                for fw in framework_cols:
                    formatted[fw] = _format_value(row[fw], unit, bold=(fw == best_fw))
                rows.append(formatted)
            mds.append(tabulate(rows, headers="keys", tablefmt="pipe"))

    return "\n\n".join(mds)


# =============================================================================
# Charts
# =============================================================================


def _create_metric_chart(
    df: pl.DataFrame,
    name: str,
    unit: str,
    color_domain: list[str],
    color_range: list[str],
) -> alt.Chart:
    """Create a grouped bar chart for a single metric (time or memory)."""
    unit_df = df.filter(pl.col("unit") == unit).sort("median")
    y_min = float(unit_df["median"].min())  # type: ignore[arg-type]
    y_max = float(unit_df["median"].max())  # type: ignore[arg-type]
    baseline = y_min * 0.3

    # Generate tick values at 1, 5 intervals per decade
    min_exp = math.floor(math.log10(baseline))
    max_exp = math.ceil(math.log10(y_max * 2))
    tick_values = []
    for exp in range(min_exp, max_exp + 1):
        for mult in (1, 5):
            tick_values.append(mult * 10**exp)

    # Get framework order (fastest first)
    fw_order = unit_df["framework"].to_list()
    fw_set = set(fw_order)
    unit_df = unit_df.with_columns(pl.lit(baseline).alias("_baseline"))

    # Filter color scale to only include frameworks present in this chart
    filtered_domain = []
    filtered_range = []
    for dom, col in zip(color_domain, color_range):
        if dom in fw_set:
            filtered_domain.append(dom)
            filtered_range.append(col)

    y_axis = (
        alt.Axis(grid=False, values=tick_values, labelExpr=TIME_LABEL_EXPR)
        if unit == DEFAULT_TIME_UNIT
        else alt.Axis(grid=False, values=tick_values, labelExpr=MEMORY_LABEL_EXPR)
    )

    return (
        alt.Chart(unit_df)
        .mark_bar()
        .encode(
            x=alt.X("entities:N", title="Entities", axis=alt.Axis(grid=False)),
            y=alt.Y(
                "median:Q",
                scale=alt.Scale(type="log", base=10, domain=[baseline, y_max * 2]),
                title=None,
                axis=y_axis,
            ),
            y2="_baseline:Q",
            xOffset=alt.XOffset("framework:N", sort=fw_order),
            color=alt.Color(
                "framework:N",
                scale=alt.Scale(domain=filtered_domain, range=filtered_range),
                sort=fw_order,
                legend=alt.Legend(
                    title="Framework",
                    orient="none",
                    legendX=10,
                    legendY=10,
                    fillColor="white",
                    strokeColor="lightgray",
                    padding=5,
                ),
            ),
        )
        .properties(
            title=name,
            width=400,
            height=300,
        )
    )


def _export_plots(
    df: pl.DataFrame, out_dir: Path, excluded_frameworks: set[str]
) -> list[Path]:
    """Export benchmark charts as SVG files, returning list of paths."""
    df = df.filter(~pl.col("framework").is_in(excluded_frameworks)).sort("framework")

    # Build consistent color scale for all frameworks
    all_frameworks = df["framework"].unique().sort().to_list()
    color_domain, color_range = _build_framework_color_scale(all_frameworks)

    plot_paths = []
    for test in df["test"].unique(maintain_order=False).sort().to_list():
        test_df = df.filter(pl.col("test") == test)
        time_chart = _create_metric_chart(
            test_df, "Time", DEFAULT_TIME_UNIT, color_domain, color_range
        )
        memory_chart = _create_metric_chart(
            test_df, "Memory", DEFAULT_MEMORY_UNIT, color_domain, color_range
        )

        plot_path = out_dir / f"{test}.svg"
        combined = (
            alt.hconcat(time_chart, memory_chart)
            .resolve_scale(color="independent")
            .resolve_legend(color="independent")
            .properties(title=test)
        )
        combined.save(plot_path)
        plot_paths.append(plot_path)

    return plot_paths


def _plots_to_markdown(plot_paths: list[Path]) -> str:
    """Convert plot paths to markdown image sections."""
    sections = []
    for plot_path in sorted(plot_paths):
        test = plot_path.stem
        relative_path = plot_path.relative_to(REPO_ROOT)
        sections.append(f"#### {test}\n![{test} Plot]({relative_path})")
    return "\n\n".join(sections)


# =============================================================================
# Main
# =============================================================================


def _main(path: Path, out_dir: Path, skip_readme: bool) -> None:
    """Export benchmark results to plots, markdown tables, and README."""
    df = pl.read_csv(path)

    plot_dir = out_dir / "img"
    plot_dir.mkdir(exist_ok=True)
    plot_paths = _export_plots(df, plot_dir, EXCLUDED_FROM_PLOTS)
    print(f"Exported plots to {plot_dir} directory.")

    table_md = _to_markdown_tables(df)

    results_md_path = out_dir / "results.md"
    results_md_path.write_text(table_md)
    print(f"Exported markdown tables to {results_md_path}.")

    if skip_readme:
        return

    plot_md = _plots_to_markdown(plot_paths)
    readme = README_PATH.read_text()
    readme = _update_section(
        readme, "BENCHMARK_ENVIRONMENT", f"```\n{_get_specs()}\n```"
    )
    readme = _update_section(readme, "PLOTS", plot_md)
    readme = _update_section(readme, "TABLES", table_md)
    README_PATH.write_text(readme)
    print(f"Updated {README_PATH}.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Export benchmark results to plots and markdown tables."
    )
    parser.add_argument("path", type=Path, help="CSV containing benchmark results")
    parser.add_argument(
        "out_dir",
        type=Path,
        nargs="?",
        default=CWD,
        help="Directory to store the charts and markdown tables",
    )
    parser.add_argument(
        "--skip-readme", action="store_true", help="Skip README.md generation"
    )
    args = parser.parse_args()
    _main(args.path.resolve(), args.out_dir.resolve(), args.skip_readme)
