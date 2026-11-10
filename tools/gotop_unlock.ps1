# Gotop T501 (08F2:6811) - unlock the full active area by sending command 3 only.
# Run after plugging in the tablet. Waits up to 60 seconds for the device to appear.

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
public static class HidNative3 {
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    static extern SafeFileHandle CreateFile(string name, uint access, uint share, IntPtr sec, uint disp, uint flags, IntPtr tmpl);
    [DllImport("hid.dll", SetLastError = true)]
    static extern bool HidD_SetFeature(SafeFileHandle h, byte[] buf, int len);

    public static SafeFileHandle Open(string path, out int err) {
        SafeFileHandle h = CreateFile(path, 0xC0000000u, 3u, IntPtr.Zero, 3u, 0u, IntPtr.Zero);
        err = h.IsInvalid ? Marshal.GetLastWin32Error() : 0;
        return h;
    }
    public static int SetFeature(SafeFileHandle h, byte[] buf) {
        return HidD_SetFeature(h, buf, buf.Length) ? 0 : Marshal.GetLastWin32Error();
    }
}
"@

$cmd = [byte[]](0x08, 0x06, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00)
$deadline = (Get-Date).AddSeconds(60)
$done = $false

while (-not $done -and (Get-Date) -lt $deadline) {
    $devs = Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue |
        Where-Object { $_.InstanceId -like 'HID\VID_08F2&PID_6811&MI_02&COL01*' }
    foreach ($d in $devs) {
        $path = '\\?\' + $d.InstanceId.Replace('\', '#') + '#{4d1e55b2-f16f-11cf-88cb-001111000030}'
        $err = 0
        $h = [HidNative3]::Open($path, [ref]$err)
        if ($err -ne 0) { continue }
        $e = [HidNative3]::SetFeature($h, $cmd)
        $h.Close()
        if ($e -eq 0) { Write-Host "Unlock command sent: OK"; $done = $true; break }
        else { Write-Host "SetFeature failed, Win32 error $e (will retry)" }
    }
    if (-not $done) { Start-Sleep -Seconds 1 }
}

if (-not $done) { Write-Host "Tablet not found or command failed after 60 seconds."; exit 1 }
