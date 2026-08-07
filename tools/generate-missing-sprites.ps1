$ErrorActionPreference = "Stop"

function New-Canvas {
  param([int]$Width, [int]$Height)
  return [byte[]]::new($Width * $Height * 4)
}

function Blend-Pixel {
  param(
    [byte[]]$Pixels, [int]$Width, [int]$Height,
    [int]$X, [int]$Y, [int]$R, [int]$G, [int]$B, [int]$A
  )
  if ($X -lt 0 -or $Y -lt 0 -or $X -ge $Width -or $Y -ge $Height -or $A -le 0) { return }
  $i = (($Y * $Width) + $X) * 4
  $dstA = $Pixels[$i + 3] / 255.0
  $srcA = [Math]::Min(255, $A) / 255.0
  $outA = $srcA + ($dstA * (1.0 - $srcA))
  if ($outA -le 0) { return }
  $Pixels[$i] = [byte]([Math]::Round((($R * $srcA) + ($Pixels[$i] * $dstA * (1.0 - $srcA))) / $outA))
  $Pixels[$i + 1] = [byte]([Math]::Round((($G * $srcA) + ($Pixels[$i + 1] * $dstA * (1.0 - $srcA))) / $outA))
  $Pixels[$i + 2] = [byte]([Math]::Round((($B * $srcA) + ($Pixels[$i + 2] * $dstA * (1.0 - $srcA))) / $outA))
  $Pixels[$i + 3] = [byte]([Math]::Round($outA * 255))
}

function Draw-Rect {
  param([byte[]]$Pixels, [int]$W, [int]$H, [int]$X, [int]$Y, [int]$RW, [int]$RH, [int[]]$Color)
  for ($yy = $Y; $yy -lt $Y + $RH; $yy++) {
    for ($xx = $X; $xx -lt $X + $RW; $xx++) {
      Blend-Pixel $Pixels $W $H $xx $yy $Color[0] $Color[1] $Color[2] $Color[3]
    }
  }
}

function Draw-Line {
  param([byte[]]$Pixels, [int]$W, [int]$H, [int]$X0, [int]$Y0, [int]$X1, [int]$Y1, [int]$Thickness, [int[]]$Color)
  $dx = $X1 - $X0
  $dy = $Y1 - $Y0
  $steps = [Math]::Max([Math]::Abs($dx), [Math]::Abs($dy))
  if ($steps -eq 0) { $steps = 1 }
  for ($s = 0; $s -le $steps; $s++) {
    $x = [Math]::Round($X0 + ($dx * $s / $steps))
    $y = [Math]::Round($Y0 + ($dy * $s / $steps))
    Draw-Circle $Pixels $W $H $x $y $Thickness $Color
  }
}

function Draw-Circle {
  param([byte[]]$Pixels, [int]$W, [int]$H, [int]$CX, [int]$CY, [int]$Radius, [int[]]$Color)
  $r2 = $Radius * $Radius
  for ($y = $CY - $Radius; $y -le $CY + $Radius; $y++) {
    for ($x = $CX - $Radius; $x -le $CX + $Radius; $x++) {
      $dx = $x - $CX
      $dy = $y - $CY
      if (($dx * $dx + $dy * $dy) -le $r2) {
        Blend-Pixel $Pixels $W $H $x $y $Color[0] $Color[1] $Color[2] $Color[3]
      }
    }
  }
}

function Draw-Ring {
  param([byte[]]$Pixels, [int]$W, [int]$H, [int]$CX, [int]$CY, [int]$Outer, [int]$Inner, [int[]]$Color)
  $outer2 = $Outer * $Outer
  $inner2 = $Inner * $Inner
  for ($y = $CY - $Outer; $y -le $CY + $Outer; $y++) {
    for ($x = $CX - $Outer; $x -le $CX + $Outer; $x++) {
      $dx = $x - $CX
      $dy = $y - $CY
      $d2 = ($dx * $dx) + ($dy * $dy)
      if ($d2 -le $outer2 -and $d2 -ge $inner2) {
        Blend-Pixel $Pixels $W $H $x $y $Color[0] $Color[1] $Color[2] $Color[3]
      }
    }
  }
}

function Draw-Diamond {
  param([byte[]]$Pixels, [int]$W, [int]$H, [int]$CX, [int]$CY, [int]$RX, [int]$RY, [int[]]$Color)
  for ($y = $CY - $RY; $y -le $CY + $RY; $y++) {
    for ($x = $CX - $RX; $x -le $CX + $RX; $x++) {
      $v = ([Math]::Abs($x - $CX) / [double]$RX) + ([Math]::Abs($y - $CY) / [double]$RY)
      if ($v -le 1.0) {
        Blend-Pixel $Pixels $W $H $x $y $Color[0] $Color[1] $Color[2] $Color[3]
      }
    }
  }
}

function Draw-Base {
  param([byte[]]$Pixels, [int]$W, [int]$H, [int[]]$Accent)
  $pad = [Math]::Max(3, [int]($W * 0.08))
  Draw-Rect $Pixels $W $H $pad $pad ($W - ($pad * 2)) ($H - ($pad * 2)) @(36, 41, 48, 255)
  Draw-Rect $Pixels $W $H ($pad + 3) ($pad + 3) ($W - (($pad + 3) * 2)) ($H - (($pad + 3) * 2)) @(50, 58, 68, 255)
  Draw-Rect $Pixels $W $H ($pad + 7) ($pad + 7) ($W - (($pad + 7) * 2)) ($H - (($pad + 7) * 2)) @(30, 35, 42, 255)
  Draw-Line $Pixels $W $H $pad $pad ($W - $pad - 1) $pad 1 @(96, 112, 128, 210)
  Draw-Line $Pixels $W $H $pad $pad $pad ($H - $pad - 1) 1 @(96, 112, 128, 170)
  Draw-Line $Pixels $W $H ($W - $pad - 1) $pad ($W - $pad - 1) ($H - $pad - 1) 1 @(10, 14, 20, 190)
  Draw-Line $Pixels $W $H $pad ($H - $pad - 1) ($W - $pad - 1) ($H - $pad - 1) 1 @(10, 14, 20, 190)
  Draw-Circle $Pixels $W $H ([int]($W / 2)) ([int]($H / 2)) ([int]($W * 0.17)) @($Accent[0], $Accent[1], $Accent[2], 165)
}

function Get-BigEndianBytes {
  param([uint32]$Value)
  $b = [System.BitConverter]::GetBytes($Value)
  [Array]::Reverse($b)
  return ,$b
}

function Get-Crc32 {
  param([byte[]]$Bytes)
  $crc = [uint64]4294967295
  $poly = [uint64]3988292384
  foreach ($b in $Bytes) {
    $crc = $crc -bxor [uint64]$b
    for ($i = 0; $i -lt 8; $i++) {
      if (($crc -band 1) -ne 0) {
        $crc = ($crc -shr 1) -bxor $poly
      } else {
        $crc = $crc -shr 1
      }
    }
  }
  return [uint32](($crc -bxor [uint64]4294967295) -band [uint64]4294967295)
}

function Get-Adler32 {
  param([byte[]]$Bytes)
  $a = [uint64]1
  $b = [uint64]0
  foreach ($x in $Bytes) {
    $a = ($a + $x) % 65521
    $b = ($b + $a) % 65521
  }
  return [uint32]((($b -shl 16) -bor $a) -band [uint64]4294967295)
}

function New-ZlibStored {
  param([byte[]]$Bytes)
  $out = New-Object System.Collections.Generic.List[byte]
  $out.Add(0x78)
  $out.Add(0x01)
  $offset = 0
  while ($offset -lt $Bytes.Length) {
    $len = [Math]::Min(65535, $Bytes.Length - $offset)
    $final = if (($offset + $len) -ge $Bytes.Length) { 1 } else { 0 }
    $out.Add([byte]$final)
    $out.Add([byte]($len -band 0xff))
    $out.Add([byte](($len -shr 8) -band 0xff))
    $nlen = (-bnot [uint16]$len) -band 0xffff
    $out.Add([byte]($nlen -band 0xff))
    $out.Add([byte](($nlen -shr 8) -band 0xff))
    for ($i = 0; $i -lt $len; $i++) { $out.Add($Bytes[$offset + $i]) }
    $offset += $len
  }
  $adler = Get-Adler32 $Bytes
  $out.AddRange((Get-BigEndianBytes $adler))
  return ,$out.ToArray()
}

function Add-Chunk {
  param([System.Collections.Generic.List[byte]]$Png, [string]$Type, [byte[]]$Data)
  $typeBytes = [System.Text.Encoding]::ASCII.GetBytes($Type)
  $Png.AddRange((Get-BigEndianBytes ([uint32]$Data.Length)))
  $Png.AddRange($typeBytes)
  $Png.AddRange($Data)
  $crcInput = [byte[]]::new($typeBytes.Length + $Data.Length)
  [Array]::Copy($typeBytes, 0, $crcInput, 0, $typeBytes.Length)
  [Array]::Copy($Data, 0, $crcInput, $typeBytes.Length, $Data.Length)
  $Png.AddRange((Get-BigEndianBytes (Get-Crc32 $crcInput)))
}

function Save-Png {
  param([string]$Path, [int]$W, [int]$H, [byte[]]$Pixels)
  $dir = Split-Path $Path -Parent
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

  $raw = [byte[]]::new(($W * 4 + 1) * $H)
  $ri = 0
  for ($y = 0; $y -lt $H; $y++) {
    $raw[$ri++] = 0
    for ($x = 0; $x -lt $W; $x++) {
      $pi = (($y * $W) + $x) * 4
      $raw[$ri++] = $Pixels[$pi]
      $raw[$ri++] = $Pixels[$pi + 1]
      $raw[$ri++] = $Pixels[$pi + 2]
      $raw[$ri++] = $Pixels[$pi + 3]
    }
  }

  $png = New-Object System.Collections.Generic.List[byte]
  $png.AddRange([byte[]](0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a))
  $ihdr = New-Object System.Collections.Generic.List[byte]
  $ihdr.AddRange((Get-BigEndianBytes ([uint32]$W)))
  $ihdr.AddRange((Get-BigEndianBytes ([uint32]$H)))
  $ihdr.AddRange([byte[]](8, 6, 0, 0, 0))
  Add-Chunk $png "IHDR" $ihdr.ToArray()
  Add-Chunk $png "IDAT" (New-ZlibStored $raw)
  Add-Chunk $png "IEND" ([byte[]]::new(0))
  [System.IO.File]::WriteAllBytes((Join-Path (Get-Location) $Path), $png.ToArray())
}

function New-ZenithPillar {
  $p = New-Canvas 160 160
  Draw-Base $p 160 160 @(184, 146, 255)
  Draw-Rect $p 160 160 68 18 24 112 @(54, 44, 74, 255)
  Draw-Rect $p 160 160 74 12 12 124 @(184, 146, 255, 120)
  Draw-Ring $p 160 160 80 80 34 27 @(255, 107, 56, 190)
  Draw-Circle $p 160 160 80 80 16 @(255, 255, 255, 210)
  Save-Png "sprites\blocks\turrets\zenith-pillar.png" 160 160 $p

  $o = New-Canvas 160 160
  Draw-Circle $o 160 160 80 62 19 @(184, 146, 255, 120)
  Draw-Circle $o 160 160 80 62 12 @(255, 255, 255, 210)
  Draw-Circle $o 160 160 75 57 4 @(255, 107, 56, 170)
  Save-Png "sprites\blocks\turrets\zenith-pillar-orb.png" 160 160 $o
}

function New-PhaseProjector {
  $p = New-Canvas 64 64
  Draw-Diamond $p 64 64 32 28 14 21 @(184, 146, 255, 210)
  Draw-Diamond $p 64 64 32 28 8 13 @(255, 255, 255, 190)
  Draw-Line $p 64 64 20 44 44 44 2 @(152, 255, 217, 120)
  Save-Png "sprites\blocks\defense\phase-resonance-projector-crystal.png" 64 64 $p
}

function New-AbyssalCenter {
  $p = New-Canvas 64 64
  Draw-Circle $p 64 64 32 32 18 @(0, 0, 0, 240)
  Draw-Ring $p 64 64 32 32 22 17 @(184, 146, 255, 150)
  Draw-Circle $p 64 64 32 32 7 @(12, 4, 24, 255)
  Save-Png "sprites\blocks\effect\abyssal-void-vent-center.png" 64 64 $p
}

function New-MassPulverizer {
  $p = New-Canvas 64 64
  Draw-Base $p 64 64 @(255, 121, 94)
  Draw-Circle $p 64 64 24 32 10 @(88, 96, 105, 255)
  Draw-Circle $p 64 64 40 32 10 @(88, 96, 105, 255)
  Save-Png "sprites\blocks\crafting\mass-pulverizer.png" 64 64 $p

  $g = New-Canvas 64 64
  Draw-Ring $g 64 64 24 32 12 7 @(170, 178, 188, 230)
  Draw-Ring $g 64 64 40 32 12 7 @(170, 178, 188, 230)
  for ($i = 0; $i -lt 8; $i++) {
    $a = $i * [Math]::PI / 4
    Draw-Line $g 64 64 24 32 ([int](24 + [Math]::Cos($a) * 13)) ([int](32 + [Math]::Sin($a) * 13)) 1 @(255, 166, 77, 160)
    Draw-Line $g 64 64 40 32 ([int](40 - [Math]::Cos($a) * 13)) ([int](32 - [Math]::Sin($a) * 13)) 1 @(255, 166, 77, 160)
  }
  Save-Png "sprites\blocks\crafting\mass-pulverizer-grinder.png" 64 64 $g
}

function New-SiliconUltraForge {
  $p = New-Canvas 64 64
  Draw-Base $p 64 64 @(132, 244, 255)
  Draw-Rect $p 64 64 22 18 20 28 @(20, 42, 48, 255)
  Draw-Circle $p 64 64 32 32 9 @(132, 244, 255, 190)
  Save-Png "sprites\blocks\crafting\silicon-ultraforge.png" 64 64 $p

  $r = New-Canvas 64 64
  Draw-Ring $r 64 64 32 32 22 19 @(255, 255, 255, 170)
  Draw-Ring $r 64 64 32 32 15 13 @(132, 244, 255, 150)
  Draw-Line $r 64 64 12 32 52 32 1 @(132, 244, 255, 90)
  Draw-Line $r 64 64 32 12 32 52 1 @(132, 244, 255, 90)
  Save-Png "sprites\blocks\crafting\silicon-ultraforge-ring.png" 64 64 $r
}

function New-HeatSleeve {
  $p = New-Canvas 32 32
  Draw-Rect $p 32 32 3 10 26 12 @(45, 50, 58, 255)
  Draw-Rect $p 32 32 6 13 20 6 @(255, 166, 101, 210)
  Draw-Line $p 32 32 3 10 28 10 1 @(96, 112, 128, 180)
  Draw-Line $p 32 32 3 21 28 21 1 @(12, 14, 18, 180)
  Save-Png "sprites\blocks\production\quantum-heat-sieve.png" 32 32 $p

  $g = New-Canvas 32 32
  Draw-Rect $g 32 32 5 12 22 8 @(255, 166, 101, 120)
  Draw-Line $g 32 32 6 16 25 16 2 @(255, 230, 190, 150)
  Save-Png "sprites\blocks\production\quantum-heat-sieve-glow.png" 32 32 $g
}

function New-HyperProcessor {
  $p = New-Canvas 96 96
  Draw-Base $p 96 96 @(184, 146, 255)
  Draw-Rect $p 96 96 28 28 40 40 @(25, 19, 39, 255)
  Draw-Circle $p 96 96 48 48 15 @(184, 146, 255, 190)
  Save-Png "sprites\blocks\processors\auraline-hyper-processor.png" 96 96 $p

  $r = New-Canvas 96 96
  Draw-Ring $r 96 96 48 48 32 29 @(184, 146, 255, 145)
  Draw-Ring $r 96 96 48 48 22 20 @(152, 255, 217, 130)
  Draw-Line $r 96 96 16 48 80 48 1 @(255, 255, 255, 95)
  Draw-Line $r 96 96 48 16 48 80 1 @(255, 255, 255, 95)
  Save-Png "sprites\blocks\processors\auraline-hyper-processor-rings.png" 96 96 $r
}

function New-BottomPlates {
  $s = New-Canvas 64 64
  Draw-Rect $s 64 64 7 7 50 50 @(24, 29, 36, 255)
  Draw-Rect $s 64 64 12 12 40 40 @(43, 50, 60, 255)
  Draw-Ring $s 64 64 32 32 18 13 @(96, 112, 128, 160)
  Draw-Line $s 64 64 12 52 52 52 1 @(8, 10, 14, 170)
  Save-Png "sprites\blocks\power\steam-fusion-generator-bottom.png" 64 64 $s

  $t = New-Canvas 96 96
  Draw-Rect $t 96 96 9 9 78 78 @(27, 31, 36, 255)
  Draw-Rect $t 96 96 16 16 64 64 @(45, 53, 61, 255)
  Draw-Ring $t 96 96 48 48 26 19 @(208, 255, 244, 125)
  Save-Png "sprites\blocks\production\tectonic-drill-bottom.png" 96 96 $t

  $o = New-Canvas 96 96
  Draw-Rect $o 96 96 10 10 76 76 @(31, 29, 26, 255)
  Draw-Rect $o 96 96 16 16 64 64 @(52, 47, 38, 255)
  Draw-Ring $o 96 96 48 48 27 20 @(83, 69, 46, 180)
  Draw-Line $o 96 96 18 74 78 74 2 @(15, 12, 10, 170)
  Save-Png "sprites\blocks\production\oil-seismic-production-pump-bottom.png" 96 96 $o
}

New-ZenithPillar
New-PhaseProjector
New-AbyssalCenter
New-MassPulverizer
New-SiliconUltraForge
New-HeatSleeve
New-HyperProcessor
New-BottomPlates

Write-Host "Generated missing Auraline-Magna sprite bases and overlays."
