import argparse
import math
import platform
import re
import subprocess
from collections import defaultdict
from pathlib import Path
from typing import Any, cast

import altair as alt
import humanize
import polars as pl
import psutil
from tabulate import tabulate

try:
    import distro
except ImportError:
    distro = None

# =============================================================================
# Constants
# =============================================================================


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
README_PATH = REPO_ROOT / "README.md"
PLOTS_PATH = REPO_ROOT / "results" / "plots" / "README.md"

TIME = "s"
MEMORY = "kb"

UNIT_DISPLAY_NAMES = {
    TIME: "Execution Time",
    MEMORY: "Memory Usage",
}

INTERPRETERS: dict[str, list[str]] = {
    "luajit-on": ["LuaJIT", "JIT On"],
    "luajit-off": ["LuaJIT", "JIT Off"],
    "lua5.1": ["Lua 5.1"],
    "lua5.4": ["Lua 5.4"],
}
TEST_ORDER: dict[str, list[str]] = {
    "entity": ["create_empty", "create_with_components", "destroy"],
    "component": ["get", "set", "add", "remove"],
    "tag": ["has", "add", "remove"],
    "system": ["throughput", "overlap", "fragmented", "chained", "multi_20", "empty_systems"],
}

MAX_RELATIVE_PERFORMANCE = 20.0

# Chart styling constants
FONT = "Inter, system-ui"
AXIS_LABEL_FONT_SIZE = 9
HEADER_LABEL_FONT_SIZE = 10
TITLE_FONT_SIZE = 14

VIEW_STROKE_WIDTH = 0
SUMMARY_SEPARATOR_WIDTH = 675
GRID_COLOR = "#ccc"
GRID_DASH = [1, 3]

AXIS_STYLE: dict[str, Any] = {"labelFontSize": AXIS_LABEL_FONT_SIZE}
LEGEND_STYLE: dict[str, Any] = {
    "titleFontSize": AXIS_LABEL_FONT_SIZE,
    "labelFontSize": AXIS_LABEL_FONT_SIZE,
}
HEADER_STYLE: dict[str, Any] = {
    "labelAlign": "center",
    "labelFontSize": HEADER_LABEL_FONT_SIZE,
    "labelFontWeight": "bold",
}

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

# Rank chart constants (dict order defines domain)
RANK_ORDER = {"1st": 1, "2nd": 2, "3rd": 3, "4th+": 4}
RANK_FILL = ["#55b748", "#1696d2", "#fdbf11", "#d2d2d2"]


# =============================================================================
# Framework Variants
# =============================================================================


def find_basename(name: str, frameworks: set[str]) -> str:
    """Find root ancestor that exists in framework set."""
    best = name
    current = name
    while "-" in current:
        current = current.rsplit("-", 1)[0]
        if current in frameworks:
            best = current
    return best


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


def build_framework_color_scale(frameworks: list[str]) -> tuple[list[str], list[str]]:
    """Build color scale mapping frameworks to colors, returning (domain, range)."""
    unique_frameworks = set(frameworks)

    base_to_variants: defaultdict[str, list[str]] = defaultdict(list)
    for framework in sorted(frameworks):
        base_to_variants[find_basename(framework, unique_frameworks)].append(framework)

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
            pl.lit(interpreter).alias("interpreter"),
        )
        dfs.append(df)

    if not dfs:
        msg = f"No results.csv files found in subdirectories of {results_dir}"
        raise ValueError(msg)

    return pl.concat(dfs, how="diagonal")


def sort_results(df: pl.DataFrame) -> pl.DataFrame:
    """Sort DataFrame by entities, group/test (TEST_ORDER), unit, framework."""
    group_rank = {g: i for i, g in enumerate(TEST_ORDER)}
    test_rank = {t: i for i, t in enumerate(t for tests in TEST_ORDER.values() for t in tests)}
    return df.sort(
        pl.col("entities"),
        pl.col("group").replace_strict(group_rank, default=len(group_rank)),
        pl.col("test").replace_strict(test_rank, default=len(test_rank)),
        pl.col("unit").replace_strict({TIME: 0, MEMORY: 1}),
        "framework",
    )


# =============================================================================
# System Info
# =============================================================================


def get_cpu_model() -> str:
    """Return CPU brand string, falling back to platform.processor()."""
    try:
        match platform.system():
            case "Darwin":
                result = subprocess.run(
                    ["sysctl", "-n", "machdep.cpu.brand_string"],
                    capture_output=True,
                    text=True,
                    check=True,
                )
                return result.stdout.strip()
            case "Linux":
                with Path("/proc/cpuinfo").open() as f:
                    for line in f:
                        if line.startswith("model name") and ":" in line:
                            return line.split(":", 1)[1].strip()
    except (subprocess.CalledProcessError, FileNotFoundError, OSError):
        pass
    return platform.processor() or platform.machine()


def get_os_version() -> str:
    """Get concise OS version string."""
    match platform.system():
        case "Darwin":
            return f"macOS {platform.mac_ver()[0]}" if platform.mac_ver()[0] else "macOS"
        case "Linux" if distro is not None:
            return distro.name(pretty=True)
        case system:
            return f"{system} {platform.release()}"


def get_specs() -> str:
    """Build formatted system specifications string."""
    specs = [
        f"OS: {get_os_version()}",
        f"CPU: {get_cpu_model()}",
        f"Cores: {psutil.cpu_count(logical=False) or '?'} cores"
        f" ({psutil.cpu_count(logical=True) or '?'} threads)",
    ]
    cpu_freq = psutil.cpu_freq()
    if cpu_freq and cpu_freq.max:
        specs.append(f"Max Frequency: {cpu_freq.max / 1000:.2f} GHz")
    specs.append(f"Memory: {psutil.virtual_memory().total / (1024**3):.0f} GB")
    return "\n".join(specs)


# =============================================================================
# Formatting
# =============================================================================


def format_value(value: float | None, unit: str, *, bold: bool = False) -> str:
    """Format a metric value with appropriate unit, optionally bold."""
    if value is None:
        return ""
    match unit:
        case "s":
            formatted = humanize.metric(value, unit="s")
        case "count":
            formatted = humanize.metric(value, precision=0).replace(" ", "").upper()
        case _:
            formatted = humanize.naturalsize(value * 1e3).replace("Bytes", "B")
    return f"**{formatted}**" if bold else formatted


def format_value_expr(expr: pl.Expr) -> pl.Expr:
    """Format a struct expression with 'value' and 'unit' fields using humanize."""
    return expr.map_elements(
        lambda row: format_value(row["value"], row["unit"]),
        return_dtype=pl.String,
    )


# =============================================================================
# Markdown Tables
# =============================================================================


def pivot_with_best_framework(
    df: pl.DataFrame,
) -> tuple[pl.DataFrame, list[str]]:
    """Pivot dataframe by framework and identify best performer per row."""
    index_cols = ["group", "unit", "entities", "test"]
    pivoted = df.pivot(on="framework", index=index_cols, values="median", maintain_order=True)
    framework_cols = sorted(pivoted.select(pl.exclude(*index_cols)).columns)

    pivoted = pivoted.with_columns(
        pl.concat_list([pl.col(fw) for fw in framework_cols])
        .list.arg_min()
        .replace_strict(dict(enumerate(framework_cols)))
        .alias("_best_framework"),
    )

    return pivoted, framework_cols


def format_table_row(row: dict[str, Any], unit: str, framework_cols: list[str]) -> dict[str, str]:
    """Format a single row for markdown table output."""
    best = row["_best_framework"]
    formatted = {"test": row["test"]}
    for fw in framework_cols:
        formatted[fw] = format_value(row[fw], unit, bold=(fw == best))
    return formatted


def _build_toc(pivoted: pl.DataFrame) -> str:
    """Build a table of contents from entity counts and groups."""
    lines = []
    for (entities,), entity_df in pivoted.group_by("entities", maintain_order=True):
        slug = f"{entities}-entities"
        lines.append(f"- **[{entities} entities](#{slug}):**")
        groups = entity_df["group"].unique(maintain_order=True).to_list()
        group_links = " · ".join(f"[{g.title()}](#{g.lower()})" for g in groups)
        lines.append(f"  {group_links}")
    return "\n".join(lines)


def to_markdown_tables(df: pl.DataFrame) -> str:
    """Convert benchmark results to markdown tables grouped by entity count, then group."""
    pivoted, framework_cols = pivot_with_best_framework(df)
    sections = [_build_toc(pivoted)]

    for (entities,), entity_df in pivoted.group_by("entities", maintain_order=True):
        sections.append(f"## {entities} entities")
        for (group,), group_df in entity_df.group_by("group", maintain_order=True):
            sections.append(f"### {group.title()}")
            for (unit,), unit_group in group_df.group_by("unit", maintain_order=True):
                sections.append(f"#### {UNIT_DISPLAY_NAMES[unit]}")
                rows = [
                    format_table_row(row, unit, framework_cols) for row in unit_group.to_dicts()
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
    # Compute dynamic tick values: snap to next "nice" base tick, then
    # drop ticks that would overlap at the chart's 150px height.
    max_val = cast("float", df["relative"].max())
    base_ticks = [t for t in [1, 2, 5, 10, 15, 20, 25, 30, 40, 50] if t <= MAX_RELATIVE_PERFORMANCE]
    max_tick = next((t for t in base_ticks if t >= max_val), base_ticks[-1])
    y_ticks = [base_ticks[0]]
    min_gap = max_tick * 0.1
    for t in base_ticks[1:]:
        if t > max_tick:
            break
        if t - y_ticks[-1] >= min_gap:
            y_ticks.append(t)

    base = alt.Chart(df)

    bars = base.mark_bar().encode(
        x=alt.X(
            "entities:N",
            title=None,
            axis=alt.Axis(grid=False, labelAngle=0, **AXIS_STYLE),
        ),
        y=alt.Y(
            "relative:Q",
            title=None,
            scale=alt.Scale(domain=[0, max_tick]),
            axis=alt.Axis(
                grid=True,
                gridDash=GRID_DASH,
                gridColor=GRID_COLOR,
                labelExpr="datum.value + '×'",
                labelFontSize=AXIS_LABEL_FONT_SIZE,
                values=y_ticks,
                tickCount=len(y_ticks),
            ),
        ),
        xOffset=alt.XOffset("framework:N", sort=framework_order),
        color=alt.Color(
            "framework:N",
            scale=alt.Scale(domain=color_domain, range=color_range),
            legend=alt.Legend(title=None, **AXIS_STYLE) if show_legend else None,
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
        font=FONT,
    ).encode(
        x=alt.X("entities:N"),
        xOffset=alt.XOffset("framework:N", sort=framework_order),
        y=alt.Y("relative:Q"),
        text="display_label:N",
    )

    return (
        (bars + labels)
        .properties(width=220, height=150)
        .facet(
            column=alt.Column(
                "display_interpreter:N",
                sort=present_interpreters,
                title=None,
                header=alt.Header(
                    labelAngle=0,
                    labelPadding=-15,
                    labelExpr="split(datum.value, '\\n')",
                    **HEADER_STYLE,
                )
                if show_header
                else alt.Header(labels=False),
            ),
            row=alt.Row(
                "unit_label:N",
                title=None,
                header=alt.Header(labelAngle=0, labelPadding=-10, **HEADER_STYLE),
            ),
        )
        .resolve_axis(x="independent")
        .resolve_axis(y="independent")
    )


def create_omission_footnote(
    all_combos: pl.DataFrame,
    visible_combos: pl.DataFrame,
    interpreters: list[str],
) -> alt.Chart | None:
    """Create a footnote chart listing frameworks omitted by the relative threshold."""
    omitted = (
        all_combos.join(
            visible_combos,
            on=["interpreter", "entities", "framework"],
            how="anti",
        )
        .select("interpreter", "framework")
        .unique()
    )

    if omitted.is_empty():
        return None

    active = {
        interp: fws
        for interp in interpreters
        if (fws := omitted.filter(pl.col("interpreter") == interp)["framework"].sort().to_list())
    }

    header = f"Omitted (>{MAX_RELATIVE_PERFORMANCE:.0f}\u00d7):"
    all_same = len(active) == len(interpreters) and len({tuple(v) for v in active.values()}) == 1
    if all_same:
        lines = [f"{header} {', '.join(next(iter(active.values())))}"]
    else:
        lines = [header]
        for interp, fws in active.items():
            label = " ".join(INTERPRETERS.get(interp, [interp]))
            lines.append(f"  \u2022 {label}: {', '.join(fws)}")

    footnote_df = pl.DataFrame({"text": lines, "order": list(range(len(lines)))})
    return (
        alt.Chart(footnote_df)
        .mark_text(align="left", baseline="top", fontSize=8, fontStyle="italic", color="#666")
        .encode(x=alt.value(0), y=alt.Y("order:O", axis=None), text="text:N")
        .properties(width=220, height=14 * len(lines))
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
    display_map = {k: "\n".join(v) for k, v in INTERPRETERS.items()}

    df = df.with_columns(
        pl.col("interpreter")
        .replace_strict(display_map, default=pl.col("interpreter"))
        .alias("display_interpreter"),
    )
    display_interpreters = [display_map.get(i, i) for i in present_interpreters]

    # Compute relative performance per (interpreter, entities, unit) group
    df = df.with_columns(
        (pl.col("median") / pl.col("median").min())
        .over(["interpreter", "entities", "unit"])
        .alias("relative"),
    )

    all_combos = df.select("interpreter", "entities", "framework").unique()

    df = df.filter(pl.col("relative") <= MAX_RELATIVE_PERFORMANCE)

    visible_frameworks = set(df["framework"].unique())
    chart_domain = [d for d in color_domain if d in visible_frameworks]
    chart_range = [
        r for d, r in zip(color_domain, color_range, strict=True) if d in visible_frameworks
    ]

    df = df.with_columns(
        pl.col("relative").rank("min").over(["interpreter", "entities", "unit"]).alias("rank"),
        pl.col("framework")
        .n_unique()
        .over(["interpreter", "entities", "unit"])
        .alias("n_frameworks"),
        format_value_expr(pl.struct([pl.col("median").alias("value"), "unit"])).alias(
            "value_label",
        ),
        pl.col("unit").replace_strict({TIME: "Time", MEMORY: "Memory"}).alias("unit_label"),
    ).with_columns(
        pl.when((pl.col("rank") == 1) | (pl.col("rank") == pl.col("n_frameworks")))
        .then(pl.col("value_label"))
        .otherwise(pl.lit(""))
        .alias("display_label"),
    )

    time_row = create_unit_row(
        df.filter(pl.col("unit") == TIME),
        framework_order,
        chart_domain,
        chart_range,
        display_interpreters,
        show_legend=True,
        show_header=True,
    )

    # Check if all memory values are close to 0
    memory_df = df.filter(pl.col("unit") == MEMORY)
    max_memory = cast("float", memory_df["median"].max())
    all_memory_zero = max_memory < 0.001  # < 1 byte in kb

    if all_memory_zero:
        rows = alt.vconcat(time_row)
    else:
        memory_row = create_unit_row(
            memory_df,
            framework_order,
            chart_domain,
            chart_range,
            display_interpreters,
            show_legend=False,
            show_header=False,
        )
        rows = alt.vconcat(time_row, memory_row)

    visible_units = [TIME] if all_memory_zero else [TIME, MEMORY]
    visible_combos = (
        df.filter(pl.col("unit").is_in(visible_units))
        .select("interpreter", "entities", "framework")
        .unique()
    )
    footnote = create_omission_footnote(all_combos, visible_combos, present_interpreters)
    if footnote is not None:
        rows = alt.vconcat(rows, footnote)

    return (
        rows.properties(
            title=alt.Title(
                test_name,
                subtitle="1× = best, by entity count",
                fontSize=TITLE_FONT_SIZE,
                subtitleFontSize=9,
            ),
        )
        .configure(font=FONT)
        .configure_view(strokeWidth=VIEW_STROKE_WIDTH)
        .configure_legend(padding=0, offset=5)
        .resolve_legend(color="shared")
    )


def export_plots(
    df: pl.DataFrame,
    out_dir: Path,
    present_interpreters: list[str],
) -> dict[str, list[Path]]:
    """Export benchmark charts as SVG files, returning dict of group -> paths."""
    framework_order = df["framework"].unique().sort().to_list()
    color_domain, color_range = build_framework_color_scale(framework_order)

    plot_paths: dict[str, list[Path]] = {}

    for (group, test), test_df in df.group_by(["group", "test"], maintain_order=True):
        group_dir = out_dir / group
        group_dir.mkdir(exist_ok=True)
        plot_path = group_dir / f"{test}.svg"

        chart = create_relative_chart(
            test_df,
            f"{group}/{test}",
            framework_order,
            color_domain,
            color_range,
            present_interpreters,
        )

        chart.save(plot_path)
        plot_paths.setdefault(group, []).append(plot_path)

    return plot_paths


# =============================================================================
# Summary Charts
# =============================================================================


def collapse_to_best_variant(df: pl.DataFrame) -> pl.DataFrame:
    """Keep only the best-performing variant per base framework."""
    frameworks = set(df["framework"].unique())
    base_map = {fw: find_basename(fw, frameworks) for fw in frameworks}
    return (
        (
            df.with_columns(
                pl.col("framework").replace_strict(base_map).alias("base_framework"),
            )
            .sort("median")
            .group_by(
                "interpreter",
                "entities",
                "group",
                "test",
                "base_framework",
                maintain_order=True,
            )
            .first()
        )
        .drop("framework")
        .rename({"base_framework": "framework"})
    )


def compute_borda_scores(df: pl.DataFrame) -> pl.DataFrame:
    """Compute Borda scores: score = K - rank, where K = number of frameworks per group."""
    ranked = df.with_columns(
        pl.col("median")
        .rank("min")
        .over(["interpreter", "entities", "group", "test"])
        .alias("rank"),
        pl.col("framework").count().over(["interpreter", "entities", "group", "test"]).alias("k"),
    )

    return (
        ranked.with_columns(
            (pl.col("k") - pl.col("rank")).alias("borda"),
            pl.col("rank")
            .replace_strict({1: "1st", 2: "2nd", 3: "3rd"}, default="4th+", return_dtype=pl.String)
            .alias("rank_label"),
        )
        .group_by("interpreter", "entities", "group", "framework", "rank_label")
        .agg(
            pl.col("borda").sum().alias("points"),
        )
    )


def build_rank_chart(
    subset: pl.DataFrame,
    fw_order: list[str],
    interp: str,
    max_points: int,
    *,
    y_title: str | list[str] | None = None,
) -> alt.LayerChart:
    """Build a single Borda score bar chart with total points labels."""
    y_axis = alt.Axis(
        title=y_title,
        titleAngle=0,
        titleAnchor="middle",
        titlePadding=20,
        ticks=False,
        domain=False,
        labelPadding=8,
        labelFontSize=10,
    )

    rank_domain = list(RANK_ORDER.keys())

    bars = (
        alt.Chart(subset)
        .mark_bar()
        .encode(
            x=alt.X(
                "points:Q",
                title=None,
                scale=alt.Scale(domain=[0, math.ceil(max_points * 1.2)]),
                axis=None,
            ),
            y=alt.Y("framework:N", title=None, sort=fw_order, axis=y_axis),
            fill=alt.Fill(
                "rank_label:N",
                title="Rank",
                scale=alt.Scale(domain=rank_domain, range=RANK_FILL),
            ),
            order=alt.Order("rank_order:Q"),
        )
    )

    total_text = (
        alt.Chart(subset.select("framework", "total_points").unique())
        .mark_text(
            align="left",
            baseline="middle",
            fontSize=9,
            dx=4,
            color="#444",
        )
        .encode(
            x=alt.X("total_points:Q"),
            y=alt.Y("framework:N", sort=fw_order),
            text=alt.Text("total_points:Q"),
        )
    )

    title_prop = alt.Title(
        interp,
        fontSize=HEADER_LABEL_FONT_SIZE,
        fontWeight="bold",
        offset=10,
        dx=-30,
    )
    return (bars + total_text).properties(width=220, height=150, title=title_prop)


def create_summary_chart(
    df: pl.DataFrame,
    interpreter_order: list[str],
) -> alt.VConcatChart:
    """Create a Borda score summary chart faceted by test group and interpreter.

    Filters to 1,000 entities and time metric. Rows = test groups, columns = interpreters.
    """
    df = df.filter(pl.col("entities") == 1000, pl.col("unit") == TIME)
    df = collapse_to_best_variant(df)

    k = df["framework"].n_unique()
    max_by_group = {group: (k - 1) * len(tests) for group, tests in TEST_ORDER.items()}

    df = compute_borda_scores(df)

    df = (
        df.with_columns(
            pl.col("points")
            .sum()
            .over("interpreter", "entities", "group", "framework")
            .alias("total_points"),
        )
        .with_columns(
            pl.col("rank_label").replace_strict(RANK_ORDER).alias("rank_order"),
        )
        .sort(
            ["interpreter", "entities", "group", "total_points", "rank_order"],
            descending=[False, False, False, True, False],
        )
    )

    separator = (
        alt.Chart(pl.DataFrame({"x": [0]}))
        .mark_rule(color="#ddd", strokeWidth=0.5)
        .encode(y=alt.value(2))
        .properties(width=SUMMARY_SEPARATOR_WIDTH, height=4)
    )

    rows: list[alt.HConcatChart | alt.Chart] = []
    for i, interp in enumerate(interpreter_order):
        display_name = INTERPRETERS.get(interp, [interp])
        cols: list[alt.LayerChart] = []
        for j, group in enumerate(TEST_ORDER):
            group_max_points = cast("int", max_by_group[group])
            subset = df.filter(
                pl.col("group") == group,
                pl.col("interpreter") == interp,
            )
            fw_order = (
                subset.select("framework", "total_points")
                .unique()
                .sort("total_points", descending=True)["framework"]
                .to_list()
            )
            chart = build_rank_chart(
                subset,
                fw_order,
                group.title(),
                group_max_points,
                y_title=display_name if j == 0 else None,
            )
            if i > 0:
                chart = chart.properties(title="")
            cols.append(chart)
        if i > 0:
            rows.append(separator)
        rows.append(alt.hconcat(*cols, spacing=40, bounds="flush"))

    subtitle = f"Per test: 1st={k - 1}, 2nd={k - 2}, \u2026, last=0; summed per group."

    n_interp = len(interpreter_order)
    n_separators = n_interp - 1
    legend_y = n_interp * 150 + n_separators * 25  # empirically tuned

    return (
        alt.vconcat(*rows, spacing=10)
        .properties(
            title=alt.Title(
                "Summary \u2014 Borda Score (1,000 Entities)",
                subtitle=subtitle,
                fontSize=TITLE_FONT_SIZE,
                subtitleFontSize=9,
                offset=20,
            ),
        )
        .configure(font=FONT)
        .configure_view(strokeWidth=VIEW_STROKE_WIDTH)
        .configure_legend(
            orient="none",
            legendX=-115,
            legendY=legend_y,
            direction="horizontal",
            **LEGEND_STYLE,
        )
        .resolve_legend(color="shared")
    )


def export_summary_chart(
    df: pl.DataFrame,
    out_dir: Path,
    present_interpreters: list[str],
) -> Path:
    """Export a single Borda score summary chart.

    Args:
        df: Full benchmark DataFrame
        out_dir: Base output directory (results/plots/)
        present_interpreters: Ordered list of interpreters

    Returns:
        Path to the generated chart
    """
    summary_dir = out_dir / "summary"
    summary_dir.mkdir(exist_ok=True)

    chart = create_summary_chart(df, present_interpreters)
    chart_path = summary_dir / "summary.svg"
    chart.save(chart_path)

    return chart_path


# =============================================================================
# Markdown Output
# =============================================================================


def update_section(content: str, marker: str, new_content: str) -> str:
    """Replace content between AUTO-GENERATED-CONTENT markers."""
    pattern = (
        rf"(<!-- AUTO-GENERATED-CONTENT:START \({marker}\) -->\n)"
        rf".*?(<!-- AUTO-GENERATED-CONTENT:END -->)"
    )
    replacement = rf"\g<1>\n{new_content}\n\n\g<2>"
    return re.sub(pattern, replacement, content, flags=re.DOTALL)


def _update_markdown_file(path: Path, sections: list[tuple[str, str]]) -> None:
    """Read a markdown file, update AUTO-GENERATED-CONTENT sections, and write it back."""
    text = path.read_text()
    for marker, content in sections:
        text = update_section(text, marker, content)
    path.write_text(text)
    print(f"Updated {path.relative_to(Path.cwd())}")


def plots_toc_to_markdown(plot_paths: dict[str, list[Path]]) -> str:
    """Generate a table of contents linking to group and test headings.

    Assumes plot_paths is already ordered by TEST_ORDER (as produced by export_plots).
    """
    lines = []
    for group, paths in plot_paths.items():
        test_links = " · ".join(f"[{p.stem}](#{group}-{p.stem})" for p in paths)
        lines.append(f"- **[{group.title()}](#{group.lower()}):** {test_links}")
    return "\n".join(lines)


def plots_to_markdown(plot_paths: dict[str, list[Path]], *, relative_to: Path = REPO_ROOT) -> str:
    """Convert plot paths to markdown image sections.

    Assumes plot_paths is already ordered by TEST_ORDER (as produced by export_plots).
    """
    sections = []

    for group, paths in plot_paths.items():
        sections.append(f"#### {group.title()}")
        sections.extend(
            f'<a id="{group}-{p.stem}"></a>\n\n##### {p.stem}\n\n'
            f"![{p.stem} Plot]({p.relative_to(relative_to)})"
            for p in paths
        )

    return "\n\n".join(sections)


def generate_plots_markdown(
    specs: str,
    plot_paths: dict[str, list[Path]],
    *,
    relative_to: Path,
) -> str:
    """Generate the full plots README content programmatically."""
    sections = [
        "# Benchmark Plots",
        f"```text\n{specs}\n```",
        "Memory rows are omitted from charts when all frameworks report zero allocation"
        " for a given test.",
        plots_toc_to_markdown(plot_paths),
        plots_to_markdown(plot_paths, relative_to=relative_to),
    ]
    return "\n\n".join(sections) + "\n"


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
# Export
# =============================================================================


def export_csv(df: pl.DataFrame, results_dir: Path) -> None:
    """Export sorted CSV per interpreter subdirectory."""
    for (interpreter,), interpreter_df in df.group_by("interpreter", maintain_order=True):
        out_dir = results_dir / interpreter
        out_dir.mkdir(parents=True, exist_ok=True)
        csv_path = out_dir / "results.csv"
        interpreter_df.drop("interpreter").write_csv(csv_path)
        print(f"Exported CSV to {csv_path.relative_to(Path.cwd())}")


def export_markdown_tables(df: pl.DataFrame, results_dir: Path, specs: str) -> None:
    """Export markdown tables per interpreter subdirectory."""
    for (interpreter,), interpreter_df in df.group_by("interpreter", maintain_order=True):
        interpreter_df = interpreter_df.drop("interpreter")
        results_md_path = results_dir / interpreter / "results.md"
        results_md_path.parent.mkdir(parents=True, exist_ok=True)
        content = (
            f"# Benchmark Environment\n\n```text\n{specs}\n```\n\n"
            f"{to_markdown_tables(interpreter_df)}\n"
        )
        results_md_path.write_text(content)
        print(f"Exported markdown tables to {results_md_path.relative_to(Path.cwd())}")


def main(results_dir: Path, skip_readme: bool) -> None:
    """Export benchmark results to plots, markdown tables, and README."""
    df = sort_results(load_results(results_dir))
    if df.is_empty():
        print("No benchmark data available. Nothing to export.")
        return

    specs = get_specs()
    interpreters = set(df["interpreter"].unique())
    ordered = [i for i in INTERPRETERS if i in interpreters]
    present_interpreters = ordered + sorted(interpreters - set(ordered))

    plot_dir = results_dir / "plots"
    plot_dir.mkdir(exist_ok=True)

    summary_path = export_summary_chart(df, plot_dir, present_interpreters)
    print(f"Exported summary chart to {summary_path.relative_to(Path.cwd())}")

    plot_paths = export_plots(df, plot_dir, present_interpreters)
    print(f"Exported plots to {plot_dir.relative_to(Path.cwd())}")
    export_csv(df, results_dir)
    export_markdown_tables(df, results_dir, specs)

    PLOTS_PATH.parent.mkdir(parents=True, exist_ok=True)
    PLOTS_PATH.write_text(
        generate_plots_markdown(specs, plot_paths, relative_to=PLOTS_PATH.parent),
    )
    print(f"Generated {PLOTS_PATH.relative_to(Path.cwd())}")

    if not skip_readme:
        _update_markdown_file(
            README_PATH,
            [
                ("BENCHMARK_ENVIRONMENT", f"```text\n{specs}\n```"),
                ("SUMMARY", f"![Summary]({summary_path.relative_to(REPO_ROOT)})"),
                ("OUTPUTS", outputs_to_markdown(results_dir, present_interpreters)),
            ],
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Export benchmark results to plots and markdown tables.",
    )
    parser.add_argument(
        "results_dir",
        type=Path,
        help="Results directory with interpreter subdirs (e.g., results/luajit-on/results.csv)",
    )
    parser.add_argument(
        "--skip-readme",
        action="store_true",
        help="Skip README.md generation",
    )
    args = parser.parse_args()
    main(args.results_dir.resolve(), args.skip_readme)
