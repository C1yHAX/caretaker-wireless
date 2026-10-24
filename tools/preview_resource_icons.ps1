param([Parameter(Mandatory=$true)][string]$Reports)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$repo=Split-Path -Parent $PSScriptRoot
$rows=(Get-Content -LiteralPath (Join-Path $repo 'resources.json') -Raw -Encoding utf8 | ConvertFrom-Json).resources
$sheet=[Drawing.Bitmap]::new(1200,960)
$graphics=[Drawing.Graphics]::FromImage($sheet)
$font=[Drawing.Font]::new('Segoe UI',18,[Drawing.FontStyle]::Bold)
$small=[Drawing.Font]::new('Segoe UI',10)
$graphics.Clear([Drawing.Color]::FromArgb(23,28,34))
$graphics.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.DrawString('WIRELESS 1.0.0 - Ressourcen-Icons / Offline-Vorschau',$font,[Drawing.Brushes]::White,20,12)
for($i=0;$i -lt $rows.Count;$i++){
 $row=$rows[$i];$x=($i%3)*400;$y=60+[Math]::Floor($i/3)*300
 $graphics.DrawString($row.name,$font,[Drawing.Brushes]::White,($x+20),$y)
 $roles=@('Transmitter','Receiver');$labels=@('Sender','Empf.')
 for($j=0;$j -lt 2;$j++){
  $img=[Drawing.Image]::FromFile((Join-Path $Reports ('Icon_Wireless_'+$row.resource+'_'+$roles[$j]+'.png')))
  $graphics.DrawImage($img,[Drawing.Rectangle]::new(($x+15+$j*190),($y+35),160,160))
  $graphics.DrawImage($img,[Drawing.Rectangle]::new(($x+25+$j*190),($y+205),64,64))
  $graphics.DrawString(($labels[$j]+' / 64 px'),$small,[Drawing.Brushes]::LightGray,($x+92+$j*190),($y+229))
  $img.Dispose()
 }
}
$sheet.Save((Join-Path $repo 'assets/icons/resource-preview.png'),[Drawing.Imaging.ImageFormat]::Png)
$font.Dispose();$small.Dispose();$graphics.Dispose();$sheet.Dispose()
