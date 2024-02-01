import typer
from typing_extensions import Annotated
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


def main(
    path: Annotated[Path, typer.Argument(help="CSV containing benchmark results")],
    output_dir: Annotated[
        Path, typer.Argument(help="Directory to store the charts")
    ] = Path.cwd(),
):
    data = pd.read_csv(path)
    data = data[data["framework"] != "nata"]

    data.loc[data["unit"] == "s", "median"] *= 1e6
    data.loc[data["unit"] == "kb", "median"] *= 0.001
    data.loc[data["unit"] == "s", "unit"] = "µs"
    data.loc[data["unit"] == "kb", "unit"] = "mb"

    for test in data["test"].unique():
        fig, axes = plt.subplots(1, 2, figsize=(15, 5))
        test_data = data[data["test"] == test]
        time_data = test_data[test_data["unit"] == "µs"]
        memory_data = test_data[test_data["unit"] == "mb"]

        sns.lineplot(
            ax=axes[0],
            x="n_entities",
            y="median",
            hue="framework",
            data=time_data,
            marker="o",
        )
        axes[0].set_title(f"{test} - Time (µs) vs. Number of Entities")
        axes[0].set_xlabel("Number of Entities")
        axes[0].set_ylabel("Median Time (µs)")

        sns.lineplot(
            ax=axes[1],
            x="n_entities",
            y="median",
            hue="framework",
            data=memory_data,
            marker="o",
        )
        axes[1].set_title(f"{test} - Memory (mb) vs. Number of Entities")
        axes[1].set_xlabel("Number of Entities")
        axes[1].set_ylabel("Median Memory (mb)")

        plt.tight_layout()
        fig.savefig(output_dir / f"{test}.png")
        plt.close(fig)


if __name__ == "__main__":
    typer.run(main)
