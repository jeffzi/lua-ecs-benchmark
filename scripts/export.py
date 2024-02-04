import platform
import warnings
from pathlib import Path
from string import Template
from typing import Annotated

import humanize
import matplotlib.pyplot as plt
import psutil

with warnings.catch_warnings():
    warnings.filterwarnings("ignore", category=DeprecationWarning)
    import pandas as pd
import subprocess

import seaborn as sns
import typer
from rich.console import Console

console = Console()

METRIC = "mean"
DEFAULT_TIME_UNIT = "s"
DEFAULT_MEMORY_UNIT = "kb"

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
TEMPLATE_PATH = _SCRIPT_DIR / "README_template.md"
README_PATH = REPO_ROOT / "README.md"


def _get_lua_version() -> str:
    try:
        result = subprocess.run(
            ["lua", "-v"],  # noqa: S603, S607
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "Lua is not installed or not found in PATH"


def _get_specs() -> str:
    specs = []
    specs.append(f"Lua Version: {_get_lua_version()}")

    specs.append(f"OS: {platform.system()}")
    specs.append(f"OS Version: {platform.version()}")

    specs.append(f"Processor: {platform.machine()}")
    specs.append(f"Physical cores: {psutil.cpu_count(logical=False)}")
    specs.append(f"Total cores: {psutil.cpu_count(logical=True)}")
    specs.append(f"Min Frequency: {psutil.cpu_freq().min:.2f}Mhz")
    specs.append(f"Max Frequency: {psutil.cpu_freq().max:.2f}Mhz")

    mem = psutil.virtual_memory()
    specs.append(f"Memory: {mem.total / (1024 ** 3):.2f}GB")

    return "\n".join(specs)


def _natural_duration(ns: float) -> str:
    for unit, factor in TIME_UNITS.items():
        if ns >= factor:
            return f"{ ns / factor:.3g} {unit}"
    return f"{ns} ns"


def _to_markdown_tables(df: pd.DataFrame) -> str:
    # Convert METRIC to object type for compatibility with future pandas versions
    # Setting an item of incompatible dtype will be deprecated
    df[METRIC] = df[METRIC].astype("object")

    df = df.pivot(  # noqa: PD010
        index=["unit", "entities", "test"], columns="framework", values=METRIC
    ).reset_index()
    metrics = df.columns[3:]  # Assuming first three columns are non-METRIC
    best_col_indices = df[metrics].idxmin(axis="columns")

    # Convert to human-readable measures
    time_mask = df["unit"] == DEFAULT_TIME_UNIT
    df.loc[time_mask, metrics] = (df.loc[time_mask, metrics] * 1e9).map(
        lambda x: _natural_duration(x) if not pd.isna(x) else ""
    )
    memory_mask = df["unit"] == DEFAULT_MEMORY_UNIT
    df.loc[memory_mask, metrics] = (
        (df.loc[memory_mask, metrics] * 1e3)
        .map(lambda x: humanize.naturalsize(x) if not pd.isna(x) else "")
        .replace("Bytes", "B", regex=True)
    )

    # Sort by time then memory
    df["unit"] = pd.Categorical(
        df["unit"], categories=[DEFAULT_TIME_UNIT, DEFAULT_MEMORY_UNIT], ordered=True
    )
    df = df.sort_values(["entities", "unit", "test"])

    # Human-friendly section names
    df["unit"] = (
        df["unit"]
        .astype(str)
        .replace(
            {
                DEFAULT_TIME_UNIT: "Execution Time",
                DEFAULT_MEMORY_UNIT: "Memory Usage",
            }
        )
    )

    # Apply bold formatting based on best indices
    for row_idx, col_idx in enumerate(best_col_indices):
        df.loc[row_idx, col_idx] = f"**{df.loc[row_idx, col_idx]}**"

    mds = []
    for entities in df["entities"].unique():
        mds.append(f"#### {entities} entities")
        for unit in df["unit"].unique():
            mds.append(f"##### {unit}")
            table = df[(df["entities"] == entities) & (df["unit"] == unit)].drop(
                columns=["unit", "entities"]
            )
            mds.append(table.to_markdown(index=False))
    return "\n\n".join(mds)


def _export_plots(df: pd.DataFrame, out_dir: Path) -> list[Path]:
    df = df[df["framework"] != "nata"]
    sns.color_palette("colorblind")

    # Define a consistent color palette
    df = df.sort_values(by="framework")
    frameworks = df["framework"].unique()
    palette = sns.color_palette("colorblind", n_colors=len(frameworks))
    color_map = dict(zip(frameworks, palette, strict=True))

    plot_paths = []
    for test in df["test"].unique():
        fig, axes = plt.subplots(1, 2, figsize=(15, 5))

        test_df = df[df["test"] == test]

        for i, (name, unit) in enumerate(
            [("Time", DEFAULT_TIME_UNIT), ("Memory", DEFAULT_MEMORY_UNIT)]
        ):
            sns.barplot(
                ax=axes[i],
                x="entities",
                y=METRIC,
                hue="framework",
                data=test_df[test_df["unit"] == unit],
                palette=color_map,
            )
            axes[i].set_title(f"{test} - {name} ({unit}) vs. Number of Entities")
            axes[i].set_xlabel("Number of Entities")
            axes[i].set_ylabel(f"{METRIC.title()} {name} ({unit})")
            axes[i].set(yscale="log")

        plt.tight_layout()
        plot_path = out_dir / f"{test}.svg"
        fig.savefig(plot_path, format="svg")
        plt.close(fig)
        plot_paths.append(plot_path)

    return plot_paths


def _plots_to_markdown(plot_paths: list[Path]) -> str:
    sections = []
    for plot_path in sorted(plot_paths):
        test = plot_path.stem
        md = f"#### {test}\n"
        md += f"![{test} Plot]({plot_path.relative_to(REPO_ROOT)})"
        sections.append(md)
    return "\n\n".join(sections)


def _main(
    path: Annotated[
        Path,
        typer.Argument(
            exists=True,
            file_okay=True,
            dir_okay=False,
            readable=True,
            resolve_path=True,
            help="CSV containing benchmark results",
        ),
    ],
    out_dir: Annotated[
        Path,
        typer.Argument(
            file_okay=False,
            dir_okay=True,
            writable=True,
            resolve_path=True,
            help="Directory to store the charts and markdown tables.",
        ),
    ] = CWD,
) -> None:
    df = pd.read_csv(path)

    plot_dir = out_dir / "img"
    plot_dir.mkdir(exist_ok=True)
    plot_paths = _export_plots(df, plot_dir)
    console.print(f"Exported plots to {plot_dir} directory.")

    md_path = out_dir / "results.md"
    table_md = _to_markdown_tables(df)
    with open(md_path, "w") as file:
        file.write(table_md)
    console.print(f"Exported markdown tables to {md_path}.")

    plot_md = _plots_to_markdown(plot_paths)
    with open(TEMPLATE_PATH) as file:
        readme_template = Template(file.read())
    readme = readme_template.substitute(
        benchmark_environment=_get_specs(), plots=plot_md, tables=table_md
    )
    with open(README_PATH, "w") as file:
        file.write(str(readme))
    console.print(f"Updated {README_PATH}.")


if __name__ == "__main__":
    typer.run(_main)
