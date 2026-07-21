# TRDR

TRDR is a World of Warcraft 3.3.5a addon for a level-60 custom **Felsworn Tyrant** tank. It tracks fitted dodge and parry diminishing-return models and compares equipped gear against a persistent per-character baseline.

## Features

- Blizzard Interface Options integration: `Esc -> Interface -> AddOns -> TRDR`
- `/trdr` opens the TRDR options panel
- Actual post-DR dodge and parry from the game API
- Persistent gear baseline and automatic equipment-change comparison
- Dodge, parry, combined avoidance, stamina, health, rating, and defense deltas
- Marginal DR efficiency for dodge and parry
- Strength-to-parry breakpoint tracking
- Naked calibration controls
- Optional ElvUI skinning

## Live-folder installation

The repository root is the addon folder. Clone it directly into the live WoW AddOns directory:

```bash
cd /mnt/data/Games/AscensionWoW/resources/ascension-live/Interface/AddOns
rm -rf TRDR
git clone https://github.com/Minnona/TRDR.git TRDR
```

After that, the installed addon and Git working tree are the same directory. Pull updates with:

```bash
cd /mnt/data/Games/AscensionWoW/resources/ascension-live/Interface/AddOns/TRDR
git pull
```

## Supported client

- WoW 3.3.5a / Interface 30300
- Fitted for a level-60 Felsworn Tyrant

## Avoidance model

- Dodge: Druid-style `k = 0.972`, `C = 116.890707`
- Parry: `k = 0.972`, `C = 47.003525`
- Level-60 dodge/parry rating conversion: `13.8 rating = 1% raw avoidance`
- Agility conversion: `20.246477 agility = 1% raw dodge`
- Strength parry: `0.75 hidden parry rating per completed 5 Strength`

The character-sheet values returned by `GetDodgeChance()` and `GetParryChance()` are already after diminishing returns.
