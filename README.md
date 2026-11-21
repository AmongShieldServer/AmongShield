# AmongShield — an anti-cheat server for Among Us

A free community server for **Among Us** where cheat menus can't see who the impostor is, and cheaters get kicked and called out in chat.

**No mods. No downloads besides one small settings change.** You play the normal game; you just pick the **AmongShield** region instead of North America / Europe / Asia.

> Not affiliated with Innersloth. Among Us is a trademark of Innersloth LLC.

---

## What it does

- **ESP protection.** Cheat menus that "show roles" are fed fake impostors — every cheater sees several "impostors" and can't tell which are real. Honest players see nothing different.
- **Cheaters get caught.** The server blocks and kicks players who:
  - kill from too far away or when they're not allowed to,
  - sabotage as a crewmate,
  - finish all their tasks instantly,
  - watch cameras without standing at the camera console,
  - send known cheat-menu commands.

  Everyone in the lobby gets a chat message saying who was kicked and why.
- **Game result note.** After each game, the lobby chat shows who the impostors really were.
- **Custom vision for hosts.** In the lobby, the host can type:
  - `/vision crew 0.85` or `/vision imp 1.6` — any value from 0.05 to 5
  - `/vision crew up` / `/vision crew down` — 0.05 steps
  - `/vision` — show the current values
  - `/vision reset` — go back to the normal menu values

## How to join

Everyone in a lobby needs the AmongShield region — the host and all players.

### PC (Steam / Epic / Microsoft Store) — easy way

1. **Close Among Us.**
2. Download [`Add-AmongShield.ps1`](Add-AmongShield.ps1) (click it, then the download button ⤓).
3. Right-click the file → **Run with PowerShell**. If Windows asks whether to run it, choose **Run once** / **Open**.
4. Start Among Us. The **AmongShield** region is already selected. Create or join a game as usual.

The script only edits Among Us's server list, and saves a backup of it first (`regionInfo.json.backup`). You can read it before running it — it's about 20 lines.

### PC — do it yourself (no script)

1. **Close Among Us.**
2. Press `Win + R`, paste this and press Enter:
   ```
   notepad "%USERPROFILE%\AppData\LocalLow\Innersloth\Among Us\regionInfo.json"
   ```
3. The file is one long line. Find `"Regions":[` and paste the text from [`region-entry.json`](region-entry.json) right after the `[`, followed by a comma `,`. It should look like:
   ```
   "Regions":[{ ...AmongShield entry... },{ ...the regions that were already there... }]
   ```
4. Save and close Notepad, then start Among Us and pick **AmongShield** in the region menu (the globe button on the main menu).

If the game won't load the regions afterwards, you missed a comma or bracket — delete `regionInfo.json` and Among Us will rebuild the default one.

### Phone (Android / iPhone)

Coming soon — a tap-to-add link is being tested.

### Going back to normal servers

Pick **North America**, **Europe** or **Asia** in the region menu. AmongShield stays in the list for next time.

## Good to know

- Only players on the AmongShield region are protected; official servers work like before.
- The shield hides **roles**, not positions — a cheater can still see where people are, but not who the impostor is.
- This is a small free server. If it's full or down, try again later.
- Found a bug or got wrongly kicked? Open an [issue](../../issues) and say what happened and roughly when.
