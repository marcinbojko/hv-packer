<#
.SYNOPSIS
This script validates and builds Packer templates based on the specified parameters.

.DESCRIPTION
The script accepts three parameters: Action, Log, and Version. Based on these parameters, it performs actions like validating and building Packer templates. It also sets the PACKER_LOG environment variable to control Packer's logging behavior.

.PARAMETER Action
Specifies the action to be performed. It can be:
- "verify": Only validates the Packer template.
- "build": Validates and then builds the Packer template (default action).

.PARAMETER Log
Controls the logging behavior of Packer. It can be:
- 0: Disables logging (default).
- 1: Enables logging.

.PARAMETER Version
Specifies the version of the template to be used. If not specified, it defaults to "rockylinux-8.8".

.PARAMETER Template
Specifies the path to the Packer template to be used. If not specified, it defaults to "templates/hv_rhel.pkr.hcl".
#>

param(
    [ValidateSet("verify", "build", "")]
    [string]$Action = "",

    [ValidateSet(0, 1)]
    [int]$Log = 0,

    [string]$Version = "",

    [string]$Template = ""
)

# Set default values if parameters are not specified
if ($Action -eq "") {
    $Action = "build"
}

if ($Log -eq 1) {
    $PACKER_LOG = 1
} else {
    $PACKER_LOG = 0
}

if ($Version -eq "") {
    $Version = "rockylinux-8.8"
}

if ($Template -eq "") {
    $Template = "rhel"
}

# Define colors for console output
$RED = [ConsoleColor]::Red
$GREEN = [ConsoleColor]::Green
$YELLOW = [ConsoleColor]::Yellow
$BLUE = [ConsoleColor]::Blue
$NC = [ConsoleColor]::White


# Define other variables
$var_file = "variables/variables_$Version.pkvars.hcl"
$template = "templates/hv_$Template.pkr.hcl"


if (!(Test-Path  $var_file)) {
    Write-Host "Variable file '$var_file' does not exist. Exiting now." -ForegroundColor $RED
    exit 1
} else {
    Write-Host "Variable file '$var_file' exists." -ForegroundColor $GREEN
}

if (!(Test-Path  $template)) {
    Write-Host "Template file '$template' does not exist. Exiting now." -ForegroundColor $RED
    exit 1
} else {
    Write-Host "Template file '$template' exists." -ForegroundColor $GREEN
}


# Set PACKER_LOG environment variable
[Environment]::SetEnvironmentVariable('PACKER_LOG', $PACKER_LOG, [System.EnvironmentVariableTarget]::Process)

# Display variable values
Write-Host "--- Variable Values ---" -ForegroundColor $BLUE
Write-Host "PACKER_LOG:         $PACKER_LOG" -ForegroundColor $YELLOW
Write-Host "Version:            $Version" -ForegroundColor $YELLOW
Write-Host "Var File:           $var_file" -ForegroundColor $YELLOW
Write-Host "Template:           $template" -ForegroundColor $YELLOW
Write-Host "-----------------------" -ForegroundColor $BLUE
Write-Host "Action:             $Action" -ForegroundColor $YELLOW

# Start message
Write-Host "Starting the Packer script..." -ForegroundColor $YELLOW

# Validate the existence of the var file and template before proceeding
if (-not (Test-Path $var_file)) {
    Write-Host "Var file '$var_file' does not exist. Exiting now." -ForegroundColor $RED
    exit 1
}

if (-not (Test-Path $template)) {
    Write-Host "Template file '$template' does not exist. Exiting now." -ForegroundColor $RED
    exit 1
}

# Validate packer template
Write-Host "Validating Packer template..." -ForegroundColor $YELLOW
try {
    packer validate --var-file="$var_file" "$template"
} catch {
    Write-Host "Packer validate failed - exiting now!" -ForegroundColor $RED
    exit 1
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "Packer validate failed with exit code $LASTEXITCODE - exiting now" -ForegroundColor $RED
    exit 1
} else {
    Write-Host "Packer template validation successful!" -ForegroundColor $GREEN
}

# Build packer template if Action is not 'verify'
if ($Action -ne "verify") {
    Write-Host "Building Packer template..." -ForegroundColor $YELLOW
    try {
        packer build --force --var-file="$var_file" "$template"
    }
    catch {
        Write-Host "Packer build failed - exiting now!" -ForegroundColor $RED
        exit 1
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Packer build failed with exit code $LASTEXITCODE - exiting now" -ForegroundColor $RED
        exit 1
    } else {
        Write-Host "Packer build completed successfully!" -ForegroundColor $GREEN
    }
}
