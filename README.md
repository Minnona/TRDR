# TRDR

TRDR is a World of Warcraft 3.3.5a addon for a level-60 custom **Felsworn Tyrant** tank. It tracks fitted dodge and parry diminishing-return models and compares equipped gear against a persistent per-character baseline.

## Features

- Blizzard Interface Options integration: `Esc -> Interface -> AddOns -> TRDR`
- `/trdr` opens the TRDR options panel
- Actual post-DR dodge and parry from the game API
- Persistent gear baseline and automatic equipment-change comparison
- Dodge, parry, combined avoidance, stamina, health, rating, and defense deltas
- Marginal stat values ranked with a red-to-green efficiency gradient
- Marginal DR efficiency for dodge and parry
- Strength-to-parry breakpoint tracking
- Naked calibration controls
- Optional ElvUI skinning

## Installation

The addon folder is located under the Ascension live-client path shown below. Replace the leading install location with wherever Ascension is installed on your system.

### Windows

```text
AscensionWoW\resources\ascension-live\Interface\AddOns\TRDR
```

Example Git installation from PowerShell or Git Bash:

```powershell
cd "C:\path\to\AscensionWoW\resources\ascension-live\Interface\AddOns"
git clone https://github.com/Minnona/TRDR.git TRDR
```

### Linux

```text
AscensionWoW/resources/ascension-live/Interface/AddOns/TRDR
```

Example Git installation:

```bash
cd "/path/to/AscensionWoW/resources/ascension-live/Interface/AddOns"
git clone https://github.com/Minnona/TRDR.git TRDR
```

The repository root is the addon folder, so the installed addon and Git working tree can be the same directory. Pull future updates from inside the `TRDR` folder:

```bash
git pull
```

For a manual installation, download the release ZIP and extract the `TRDR` folder into the same `Interface/AddOns` directory.

## Supported client

- WoW 3.3.5a / Interface 30300
- Ascension live-client folder layout
- Fitted for a level-60 Felsworn Tyrant

## Avoidance model

- Dodge: Druid-style `k = 0.972`, `C = 116.890707`
- Parry: `k = 0.972`, `C = 47.003525`
- Level-60 dodge/parry rating conversion: `13.8 rating = 1% raw avoidance`
- Agility conversion: `20.246477 agility = 1% raw dodge`
- Strength parry: `0.75 hidden parry rating per completed 5 Strength`

The character-sheet values returned by `GetDodgeChance()` and `GetParryChance()` are already after diminishing returns.
