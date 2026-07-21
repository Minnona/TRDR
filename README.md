# TRDR

TRDR is a World of Warcraft 3.3.5a addon for a level-60 custom **Felsworn Tyrant** tank. It tracks the class's fitted dodge and parry diminishing-return models and compares equipped gear against a persistent per-character baseline.

## Features

- Blizzard Interface Options integration: `Esc -> Interface -> AddOns -> TRDR`
- No slash commands
- Actual post-DR dodge and parry from the game API
- Persistent gear baseline and automatic equipment-change comparison
- Dodge, parry, combined avoidance, stamina, health, rating, and defense deltas
- Marginal DR efficiency for dodge and parry
- Strength-to-parry breakpoint tracking
- Naked calibration controls
- One-time import from the former `TyrantAvoidance` database when both addons are loaded
- Optional ElvUI skinning

## Installation

Copy the `TRDR` directory into:

```text
World of Warcraft/Interface/AddOns/
```

Install TRDR normally. To import an existing baseline, leave `TyrantAvoidance` installed for one login so TRDR can read it, then remove the old addon. Otherwise, simply save a new baseline in TRDR.

## Supported client

- WoW 3.3.5a / Interface 30300
- Fitted for a level-60 Felsworn Tyrant

## Avoidance model

The addon uses the empirical constants measured in-game for the custom class:

- Dodge: Druid-style `k = 0.972`, `C = 116.890707`
- Parry: `k = 0.972`, `C = 47.003525`
- Level-60 dodge/parry rating conversion: `13.8 rating = 1% raw avoidance`
- Agility conversion: `20.246477 agility = 1% raw dodge`
- Strength parry: `0.75 hidden parry rating per completed 5 Strength`

The character sheet values returned by `GetDodgeChance()` and `GetParryChance()` are already after diminishing returns.
