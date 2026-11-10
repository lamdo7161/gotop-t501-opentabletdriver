# Gotop 1060 Plus (T501) on OpenTabletDriver — Windows 11

Use the **Gotop 1060 Plus** tablet (`VID 08F2` / `PID 6811`, "[T501] Driver Inside Tablet")
with [OpenTabletDriver](https://opentabletdriver.net/) 0.6.x **without** the manufacturer driver.

Without this setup the tablet only reports a small part of its active area, and OTD's
built-in XP-Pen parser breaks hover. This repo fixes both.

## What's inside

| Path | Purpose |
|------|---------|
| `tools/gotop_unlock.ps1`, `.bat` | Sends the unlock command (Feature report `08 06 01 00 00 00 00 00`) to unlock the full active area. Run after every plug-in. |
| `plugin/` | OTD report parser plugin (`GotopT501.dll`) that handles hover correctly. |
| `config/Gotop_1060_Plus_T501_D_plugin.json` | OTD tablet configuration. |
| `docs/HOW_TO_USE.txt` | Step-by-step install guide and troubleshooting. |
| `docs/TECHNICAL.txt` | Reverse-engineering notes (HID layout, commands, pen data format). |

## Quick start

1. Install OpenTabletDriver 0.6.x. Do **not** install the manufacturer driver.
2. Get `GotopT501.dll`: download it from the Releases page (no .NET SDK needed), or build it with
   `cd plugin && dotnet build -c Release` (output: `bin/Release/net8.0/GotopT501.dll`). Copy it to `%localappdata%\OpenTabletDriver\Plugins\GotopT501\`.
3. Copy the JSON from `config/` to `%localappdata%\OpenTabletDriver\Configurations\`
   (keep only one Gotop config there).
4. In Device Manager, disable the HID digitizer (`HID_DEVICE_UP:000D`, `MI_02`).
   Do **not** disable the `UP:FFA0` vendor device.
5. Each time you plug the tablet in, run `tools/gotop_unlock.bat`.

Full details: [docs/HOW_TO_USE.txt](docs/HOW_TO_USE.txt).

## Warnings

- Provided **as is**, no warranty. You change Windows device settings at your own risk.
- This repo does not include the manufacturer driver. To revert, re-enable the disabled
  devices and use the driver from the tablet virtual CD drive.
- Do **not** send command `08 03 00 ff f0 00 ff f0`: it freezes the pen.

## License

MIT (see [LICENSE](LICENSE)). Not affiliated with Gotop or the OpenTabletDriver project.
