#!/usr/bin/env python3
"""Generate the documentation figures for formal-martingales.

Outputs (PNG, 200 dpi) into this directory:
  proof-chain.png  -- dependency flow from mathlib through the library to applications
  roadmap.png      -- planned theorem sequence, colored by status

Run:  python3 docs/figures/generate_figures.py
Deps: matplotlib only.
"""

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

# Status palette (fill, edge).
GREEN = ("#d7f0d8", "#2e7d32")   # proved
AMBER = ("#fdeecb", "#e08e0b")   # skeleton / next
BLUE = ("#d8e8fb", "#1565c0")    # mathlib dependency
GRAY = ("#e9ecef", "#6c757d")    # planned / downstream
TEXT = "#1b1b1b"


def box(ax, x, y, w, h, lines, palette, bold_first=True, fs=11):
    fill, edge = palette
    ax.add_patch(
        FancyBboxPatch(
            (x - w / 2, y - h / 2), w, h,
            boxstyle="round,pad=0.4,rounding_size=2.2",
            linewidth=1.8, edgecolor=edge, facecolor=fill, zorder=2,
        )
    )
    n = len(lines)
    for i, ln in enumerate(lines):
        yy = y + (n - 1) * 2.0 - i * 4.0
        weight = "bold" if (bold_first and i == 0) else "normal"
        size = fs if i == 0 else fs - 1.5
        ax.text(x, yy, ln, ha="center", va="center", color=TEXT,
                fontsize=size, fontweight=weight, zorder=3)


def arrow(ax, p0, p1, color, style="-", lw=1.8, label=None, lpos=0.5,
          loff=(0, 2.4), rad=0.0):
    cs = "arc3,rad=%s" % rad
    ax.add_patch(
        FancyArrowPatch(
            p0, p1, arrowstyle="-|>", mutation_scale=15,
            linewidth=lw, color=color, linestyle=style, connectionstyle=cs,
            shrinkA=2, shrinkB=2, zorder=1,
        )
    )
    if label:
        mx = p0[0] + (p1[0] - p0[0]) * lpos + loff[0]
        my = p0[1] + (p1[1] - p0[1]) * lpos + loff[1]
        ax.text(mx, my, label, ha="center", va="center", color=color,
                fontsize=8.5, style="italic", zorder=3)


def legend(ax, x, y, items):
    for i, (palette, lab) in enumerate(items):
        fill, edge = palette
        xx = x + i * 24
        ax.add_patch(
            FancyBboxPatch((xx, y), 2.6, 2.6,
                           boxstyle="round,pad=0.1,rounding_size=0.6",
                           linewidth=1.5, edgecolor=edge, facecolor=fill, zorder=2)
        )
        ax.text(xx + 4, y + 1.3, lab, ha="left", va="center",
                color=TEXT, fontsize=9, zorder=3)


def setup(w_in, h_in):
    fig, ax = plt.subplots(figsize=(w_in, h_in))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis("off")
    return fig, ax


def proof_chain():
    fig, ax = setup(12.5, 6.8)
    ax.text(50, 97, "formal-martingales: proof-chain dependency",
            ha="center", va="center", fontsize=15, fontweight="bold", color=TEXT)

    cols = [("mathlib (dependency floor)", 16),
            ("formal-martingales (this repo)", 50),
            ("downstream applications", 84)]
    for name, cx in cols:
        ax.text(cx, 88, name, ha="center", va="center",
                fontsize=10.5, fontweight="bold", color="#444")

    # mathlib
    box(ax, 16, 70, 30, 12, ["MeasureTheory.maximal_ineq", "Doob maximal inequality"], BLUE)
    box(ax, 16, 44, 30, 12, ["OptionalStopping", "stopped-value bounds · hitting times"], BLUE)

    # library
    box(ax, 50, 70, 30, 14,
        ["Ville's inequality", "finite-horizon + anytime", "PROVED · axioms clean"], GREEN)
    box(ax, 50, 42, 30, 12, ["Doob maximal (owned API)", "SKELETON"], AMBER)

    # downstream
    box(ax, 84, 78, 28, 9, ["e-values / e-processes"], GRAY)
    box(ax, 84, 60, 28, 9, ["confidence sequences"], GRAY)
    box(ax, 84, 42, 28, 9, ["anytime-valid inference"], GRAY)

    # arrows: mathlib -> library
    arrow(ax, (31, 46), (35, 66), GREEN[1], label="proves", lpos=0.5, loff=(-7, 1))
    arrow(ax, (31, 70), (35, 46), GRAY[1], style="--", label="wraps (planned)",
          lpos=0.55, loff=(7, 2))
    # library Ville -> downstream
    for ty in (78, 60, 42):
        arrow(ax, (65, 70), (70, ty), GREEN[1], style="--")
    ax.text(69, 53, "enables", ha="center", va="center", color=GREEN[1],
            fontsize=8.5, style="italic", rotation=-12)

    legend(ax, 14, 6,
           [(GREEN, "proved"), (AMBER, "skeleton"),
            (BLUE, "mathlib dependency"), (GRAY, "planned / downstream")])

    fig.tight_layout()
    fig.savefig("docs/figures/proof-chain.png", dpi=200, bbox_inches="tight",
                facecolor="white")
    plt.close(fig)


def roadmap():
    fig, ax = setup(13.5, 6.8)
    ax.text(50, 97, "formal-martingales: planned theorem sequence",
            ha="center", va="center", fontsize=15, fontweight="bold", color=TEXT)

    # spine nodes: (x, y, lines, palette, difficulty)
    spine = [
        (12, 60, ["1. Ville", "finite-horizon + anytime"], GREEN, "M · done"),
        (32, 60, ["2. Doob maximal", "owned API skeleton"], AMBER, "S · next"),
        (52, 60, ["3. Doob maximal", "proved"], GRAY, "S"),
        (72, 72, ["4. Azuma-Hoeffding", "time-uniform"], GRAY, "M"),
        (72, 48, ["5. Freedman /", "Bernstein anytime"], GRAY, "L"),
    ]
    for x, y, lines, pal, diff in spine:
        box(ax, x, y, 17, 11, lines, pal)
        ax.text(x, y - 7.6, diff, ha="center", va="center",
                fontsize=8, color=pal[1], fontweight="bold")

    # application cluster
    apps = [
        (92, 74, ["6. e-values /", "e-processes"]),
        (92, 58, ["7. confidence", "sequences"]),
        (92, 42, ["8. SLT bounds", "FormalSLT bridge"]),
    ]
    for x, y, lines in apps:
        box(ax, x, y, 15, 9, lines, GRAY, fs=10)

    c = GRAY[1]
    g = GREEN[1]
    # concentration spine
    arrow(ax, (20.5, 60), (23.5, 60), AMBER[1])
    arrow(ax, (40.5, 60), (43.5, 60), c)
    arrow(ax, (60.5, 62), (63.5, 70), c)   # 3 -> 4
    arrow(ax, (60.5, 58), (63.5, 50), c)   # 3 -> 5
    # Ville already enables e-processes today (arc up and over the spine)
    arrow(ax, (12, 66), (89, 78.5), g, style="--", rad=-0.28)
    ax.text(40, 90, "Ville enables e-processes today", ha="center", va="center",
            color=g, fontsize=8.5, style="italic", zorder=3)
    # concentration core -> statistics-facing
    arrow(ax, (80.5, 72), (84.5, 60), c, style="--")
    arrow(ax, (80.5, 48), (84.5, 56), c, style="--")
    # 6 -> 7 -> 8
    arrow(ax, (92, 69.5), (92, 62.5), c)
    arrow(ax, (92, 53.5), (92, 46.5), c)

    ax.text(50, 22, "One spine: the exponential supermartingale built from a "
                    "conditional sub-Gaussian / sub-gamma bound (items 4-5),\n"
                    "fed into Ville, powers the statistics-facing API (items 6-8).",
            ha="center", va="center", fontsize=9, color="#555")

    legend(ax, 20, 8,
           [(GREEN, "proved"), (AMBER, "in progress / next"), (GRAY, "planned")])

    fig.tight_layout()
    fig.savefig("docs/figures/roadmap.png", dpi=200, bbox_inches="tight",
                facecolor="white")
    plt.close(fig)


if __name__ == "__main__":
    proof_chain()
    roadmap()
    print("wrote docs/figures/proof-chain.png and docs/figures/roadmap.png")
