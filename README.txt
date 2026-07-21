TRDR 1.0.2
==========

WoW 3.3.5a addon for a level-60 Felsworn Tyrant tank.

Installation
------------
1. Remove the old TyrantAvoidance addon folder if it is installed.
2. Copy the TRDR folder into Interface/AddOns/.
3. Reload or restart the game.

Open the addon
--------------
Esc -> Interface -> AddOns -> TRDR
or type /trdr to open the panel directly.

Features
--------
- Saves a persistent per-character gear baseline.
- Automatically compares the current setup after equipment changes.
- Uses the client's actual post-DR dodge and parry values.
- Shows dodge, parry, combined avoidance, stamina, health, ratings, and defense deltas.
- Shows current dodge/parry marginal efficiency and which rating is more efficient.
- Shows the next Strength parry breakpoint.
- Supports naked calibration from the options panel.
- Can import the old TyrantAvoidance database when both addons are loaded once.
- Uses ElvUI button and checkbox skins when ElvUI is installed.

Important
---------
TRDR reports avoidance and effective-health trade-offs. It does not pretend that
an item with more avoidance but substantially less stamina is automatically better.
The fitted formulas are calibrated for level 60.

Version 1.0.2
-------------
- Added /trdr to open the Interface Options panel directly.

Version 1.0.1
-------------
- Reworked the options-panel summary into fixed rows and columns to prevent text overlap.
- Repository root now doubles as the live AddOns/TRDR folder for direct Git synchronization.
