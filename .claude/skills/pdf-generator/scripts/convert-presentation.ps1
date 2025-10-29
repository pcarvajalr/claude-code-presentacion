#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Convert HTML presentations to PDF format

.DESCRIPTION
    PowerShell script to batch convert HTML presentation files to PDF using wkhtmltopdf.
    Optimized for presentation formats like reveal.js with landscape orientation.

.PARAMETER InputPath
    Path to HTML file or directory containing HTML files

.PARAMETER OutputPath
    Path for output PDF file or directory

.PARAMETER Landscape
    Use landscape orientation (default: true)

.PARAMETER PageSize
    PDF page size (default: A4)
    Options: A4, Letter, Legal, A3

.PARAMETER Batch
    Process all HTML files in the input directory

.EXAMPLE
    .\convert-presentation.ps1 -InputPath presentation.html -OutputPath slides.pdf

.EXAMPLE
    .\convert-presentation.ps1 -InputPath .\presentations\ -OutputPath .\pdfs\ -Batch

.EXAMPLE
    .\convert-presentation.ps1 -InputPath slides.html -OutputPath slides.pdf -PageSize Letter
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$InputPath,

    [Parameter(Mandatory=$true)]
    [string]$OutputPath,

    [switch]$Landscape = $true,

    [ValidateSet('A4', 'Letter', 'Legal', 'A3')]
    [string]$PageSize = 'A4',

    [switch]$Batch
)

function Test-WkhtmltopdfInstalled {
    try {
        $null = Get-Command wkhtmltopdf -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Convert-HTMLToPDF {
    param(
        [string]$HtmlFile,
        [string]$PdfFile,
        [bool]$UseLandscape,
        [string]$Size
    )

    Write-Host "Converting: $HtmlFile -> $PdfFile" -ForegroundColor Cyan

    # Build wkhtmltopdf arguments
    $args = @(
        '--enable-local-file-access',
        '--page-size', $Size,
        '--print-media-type',
        '--no-stop-slow-scripts'
    )

    if ($UseLandscape) {
        $args += '--orientation', 'Landscape'
    } else {
        $args += '--orientation', 'Portrait'
    }

    # Add margin settings
    $args += '--margin-top', '10',
             '--margin-bottom', '10',
             '--margin-left', '10',
             '--margin-right', '10'

    # Add input and output files
    $args += $HtmlFile, $PdfFile

    # Execute conversion
    try {
        $process = Start-Process -FilePath 'wkhtmltopdf' -ArgumentList $args -Wait -NoNewWindow -PassThru

        if ($process.ExitCode -eq 0) {
            Write-Host "✓ Successfully created: $PdfFile" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Conversion failed with exit code: $($process.ExitCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "✗ Error during conversion: $_" -ForegroundColor Red
        return $false
    }
}

# Main script execution
Write-Host "`nHTML to PDF Converter" -ForegroundColor Yellow
Write-Host "=====================`n" -ForegroundColor Yellow

# Check if wkhtmltopdf is installed
if (-not (Test-WkhtmltopdfInstalled)) {
    Write-Host "✗ Error: wkhtmltopdf is not installed" -ForegroundColor Red
    Write-Host "`nInstall using one of these commands:" -ForegroundColor Yellow
    Write-Host "  winget install wkhtmltopdf" -ForegroundColor Cyan
    Write-Host "  choco install wkhtmltopdf" -ForegroundColor Cyan
    exit 1
}

# Batch processing
if ($Batch) {
    if (-not (Test-Path $InputPath -PathType Container)) {
        Write-Host "✗ Error: Input path must be a directory for batch processing" -ForegroundColor Red
        exit 1
    }

    # Create output directory if it doesn't exist
    if (-not (Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    }

    # Get all HTML files
    $htmlFiles = Get-ChildItem -Path $InputPath -Filter *.html

    if ($htmlFiles.Count -eq 0) {
        Write-Host "✗ No HTML files found in: $InputPath" -ForegroundColor Red
        exit 1
    }

    Write-Host "Found $($htmlFiles.Count) HTML file(s) to convert`n" -ForegroundColor Yellow

    $successCount = 0
    foreach ($htmlFile in $htmlFiles) {
        $pdfFile = Join-Path $OutputPath "$($htmlFile.BaseName).pdf"

        if (Convert-HTMLToPDF -HtmlFile $htmlFile.FullName -PdfFile $pdfFile -UseLandscape $Landscape -Size $PageSize) {
            $successCount++
        }
    }

    Write-Host "`nBatch conversion complete: $successCount/$($htmlFiles.Count) successful" -ForegroundColor Yellow

} else {
    # Single file processing
    if (-not (Test-Path $InputPath)) {
        Write-Host "✗ Error: Input file not found: $InputPath" -ForegroundColor Red
        exit 1
    }

    # Ensure output directory exists
    $outputDir = Split-Path $OutputPath -Parent
    if ($outputDir -and -not (Test-Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    }

    if (Convert-HTMLToPDF -HtmlFile $InputPath -PdfFile $OutputPath -UseLandscape $Landscape -Size $PageSize) {
        Write-Host "`n✓ Conversion successful!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "`n✗ Conversion failed" -ForegroundColor Red
        exit 1
    }
}
