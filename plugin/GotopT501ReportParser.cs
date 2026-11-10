using OpenTabletDriver.Plugin.Tablet;

namespace GotopT501
{
    // Parser for the Gotop T501 tablet (08F2:6811), vendor interface input report ID 1.
    // Layout (8 bytes), same as the standard digitizer report ID 5:
    //   [0] report ID
    //   [1] flags: bit0 = tip, bit1 = barrel button, bit2 = second button, bit6 = in range
    //   [2..3] X (little-endian)
    //   [4..5] Y (little-endian)
    //   [6..7] pressure (little-endian, 0..2047)
    // Observed states: 0xC0 = hovering, 0xC1 = touching, 0x80 = out of range.
    public class GotopT501ReportParser : IReportParser<IDeviceReport>
    {
        public IDeviceReport Parse(byte[] report)
        {
            if (report.Length < 8)
                return new OutOfRangeReport(report);

            bool inRange = (report[1] & 0x40) != 0;
            if (!inRange)
                return new OutOfRangeReport(report);

            return new TabletReport(report);
        }
    }
}
