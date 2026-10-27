param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath
)

Add-Type -AssemblyName System.Drawing

function Resize-Image {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [int]$Width,
        [int]$Height
    )
    $srcImage = [System.Drawing.Image]::FromFile($InputPath)
    $destBitmap = New-Object System.Drawing.Bitmap($Width, $Height)
    $graphic = [System.Drawing.Graphics]::FromImage($destBitmap)
    
    $graphic.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphic.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphic.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphic.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    
    $graphic.DrawImage($srcImage, 0, 0, $Width, $Height)
    
    $parentDir = Split-Path -Parent $OutputPath
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
    }

    $destBitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $graphic.Dispose()
    $destBitmap.Dispose()
    $srcImage.Dispose()
    Write-Output "Saved $Width x $Height to $OutputPath"
}

$baseRes = "android/app/src/main/res"

# Generate standard Android mipmaps
Resize-Image -InputPath $SourcePath -OutputPath "$baseRes/mipmap-mdpi/ic_launcher.png" -Width 48 -Height 48
Resize-Image -InputPath $SourcePath -OutputPath "$baseRes/mipmap-hdpi/ic_launcher.png" -Width 72 -Height 72
Resize-Image -InputPath $SourcePath -OutputPath "$baseRes/mipmap-xhdpi/ic_launcher.png" -Width 96 -Height 96
Resize-Image -InputPath $SourcePath -OutputPath "$baseRes/mipmap-xxhdpi/ic_launcher.png" -Width 144 -Height 144
Resize-Image -InputPath $SourcePath -OutputPath "$baseRes/mipmap-xxxhdpi/ic_launcher.png" -Width 192 -Height 192

# Generate Google Play Store 512x512 High-Res icon
Resize-Image -InputPath $SourcePath -OutputPath "assets/icon/app_icon_512.png" -Width 512 -Height 512
Resize-Image -InputPath $SourcePath -OutputPath "assets/icon/app_icon_1024.png" -Width 1024 -Height 1024
