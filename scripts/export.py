import warnings
from pathlib import Path
from typing import Annotated

import humanize
import matplotlib.pyplot as plt

with warnings.catch_warnings():
    warnings.filterwarnings("ignore", category=DeprecationWarning)
    import pandas as pd
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


def _naturalduration(ns: float) -> str:
    for unit, factor in TIME_UNITS.items():
        if ns >= factor:
            return f"{ ns / factor:.3g} {unit}"
    return f"{ns} ns"


def _export_markdown(df: pd.DataFrame, out_path: Path) -> None:
    # fix "Setting an item of incompatible dtype is deprecated and will raise an error
    # in a future version of pandas."
    df[METRIC] = df[METRIC].astype("object")

    # convert to human-readable measures
    time_mask = df["unit"] == DEFAULT_TIME_UNIT
    df.loc[time_mask, METRIC] = (
        (df.loc[time_mask, METRIC] * 1e9).apply(_naturalduration).astype("string")
    )
    memory_mask = df["unit"] == DEFAULT_MEMORY_UNIT
    df.loc[memory_mask, METRIC] = (
        (df.loc[memory_mask, METRIC] * 1e3)
        .apply(humanize.naturalsize)
        .str.replace("Bytes", "B")
    )

    df = df.pivot(  # noqa: PD010
        index=["unit", "entities", "test"], columns="framework", values=METRIC
    ).reset_index()

    # sort by time then memory
    df["unit"] = pd.Categorical(
        df["unit"], categories=[DEFAULT_TIME_UNIT, DEFAULT_MEMORY_UNIT], ordered=True
    )
    df = df.sort_values(["entities", "unit", "test"])

    df["unit"] = (
        df["unit"]
        .astype(str)
        .replace(
            {
                DEFAULT_TIME_UNIT: "Execution Time",
                DEFAULT_MEMORY_UNIT: "Memory consumption",
            }
        )
    )

    mds = []
    for entities in df["entities"].unique():
        mds.append(f"## {entities} entities")
        for unit in df["unit"].unique():
            mds.append(f"### {unit}")
            table = df[(df["entities"] == entities) & (df["unit"] == unit)].drop(
                columns=["unit", "entities"]
            )
            mds.append(table.to_markdown(index=False))
    md = "\n\n".join(mds)

    with open(out_path, "w") as file:
        file.write(md)


def _export_plots(df: pd.DataFrame, out_dir: Path) -> None:
    df = df[df["framework"] != "nata"]
    sns.color_palette("colorblind")

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
            )
            axes[i].set_title(f"{test} - {name} ({unit}) vs. Number of Entities")
            axes[i].set_xlabel("Number of Entities")
            axes[i].set_ylabel(f"{METRIC.title()} {name} ({unit})")

        plt.tight_layout()
        fig.savefig(out_dir / f"{test}.png")
        plt.close(fig)


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

    plot_path = out_dir / "plots"
    plot_path.mkdir(exist_ok=True)
    _export_plots(df, plot_path)

    md_path = out_dir / "results.md"
    _export_markdown(df, md_path)

    console.print(f"Exported plots to {out_dir} directory.")
    console.print(f"Exported markdown tables to {md_path}.")


if __name__ == "__main__":
    typer.run(_main)
