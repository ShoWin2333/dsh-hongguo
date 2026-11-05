param(
  [Parameter(Mandatory = $true)][string]$Source,
  [Parameter(Mandatory = $true)][string]$Target,
  [int]$Width = 240
)

# Windows fallback for the plugin's macOS `sips` cover conversion: the CDN
# publishes HEIC posters, which WIC decodes once the HEIF Image Extension is
# installed. Re-encode as a small JPEG so Chromium can show it.
Add-Type -AssemblyName PresentationCore

$stream = [System.IO.File]::OpenRead($Source)
try {
  $decoder = [System.Windows.Media.Imaging.BitmapDecoder]::Create(
    $stream,
    [System.Windows.Media.Imaging.BitmapCreateOptions]::None,
    [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
  )
  $frame = $decoder.Frames[0]
  $scale = [Math]::Min(1.0, $Width / $frame.PixelWidth)
  if ($scale -lt 1.0) {
    $frame = New-Object System.Windows.Media.Imaging.TransformedBitmap(
      $frame,
      (New-Object System.Windows.Media.ScaleTransform($scale, $scale))
    )
  }
  $encoder = New-Object System.Windows.Media.Imaging.JpegBitmapEncoder
  $encoder.QualityLevel = 70
  $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($frame))
  $output = [System.IO.File]::Create($Target)
  try { $encoder.Save($output) } finally { $output.Close() }
} finally {
  $stream.Close()
}
