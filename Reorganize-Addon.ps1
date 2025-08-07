# BLU Addon Reorganization Script
# This script reorganizes the addon to follow best practices

Write-Host "Starting BLU Addon Reorganization..." -ForegroundColor Cyan

# Create new directory structure
Write-Host "Creating new folder structure..." -ForegroundColor Yellow

$directories = @(
    "Core",
    "Modules\Quest",
    "Modules\LevelUp", 
    "Modules\Achievement",
    "Modules\Reputation",
    "Modules\BattlePet",
    "Modules\Honor",
    "Modules\Renown",
    "Modules\TradingPost",
    "Modules\Delve",
    "Interface\Panels",
    "Interface\Templates",
    "Media\Sounds",
    "Media\Textures",
    "Localization",
    "Libs"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-Host "  Created: $dir" -ForegroundColor Green
}

# Move Core files
Write-Host "`nMoving Core files..." -ForegroundColor Yellow

$coreMoves = @{
    "core\framework.lua" = "Core\Core.lua"
    "core\database.lua" = "Core\Database.lua"
    "core\init.lua" = "Core\Init.lua"
    "core\commands.lua" = "Core\Commands.lua"
    "core\options_launcher.lua" = "Core\OptionsLauncher.lua"
    "modules\config.lua" = "Core\Config.lua"
    "modules\utils.lua" = "Core\Utils.lua"
    "modules\registry.lua" = "Core\Registry.lua"
    "modules\loader.lua" = "Core\Loader.lua"
    "modules\sharedmedia.lua" = "Core\SharedMedia.lua"
}

foreach ($move in $coreMoves.GetEnumerator()) {
    if (Test-Path $move.Key) {
        Move-Item -Path $move.Key -Destination $move.Value -Force
        Write-Host "  Moved: $($move.Key) -> $($move.Value)" -ForegroundColor Green
    }
}

# Move Module files
Write-Host "`nMoving Module files..." -ForegroundColor Yellow

$moduleMoves = @{
    "modules\features\quest.lua" = "Modules\Quest\Quest.lua"
    "modules\features\levelup.lua" = "Modules\LevelUp\LevelUp.lua"
    "modules\features\achievement.lua" = "Modules\Achievement\Achievement.lua"
    "modules\features\reputation.lua" = "Modules\Reputation\Reputation.lua"
    "modules\features\battlepet.lua" = "Modules\BattlePet\BattlePet.lua"
    "modules\features\honorrank.lua" = "Modules\Honor\Honor.lua"
    "modules\features\renownrank.lua" = "Modules\Renown\Renown.lua"
    "modules\features\tradingpost.lua" = "Modules\TradingPost\TradingPost.lua"
    "modules\features\delvecompanion.lua" = "Modules\Delve\Delve.lua"
}

foreach ($move in $moduleMoves.GetEnumerator()) {
    if (Test-Path $move.Key) {
        Move-Item -Path $move.Key -Destination $move.Value -Force
        Write-Host "  Moved: $($move.Key) -> $($move.Value)" -ForegroundColor Green
    }
}

# Move Interface files
Write-Host "`nMoving Interface files..." -ForegroundColor Yellow

$interfaceMoves = @{
    "modules\interface\options_new.lua" = "Interface\Settings.lua"
    "modules\interface\design_narcissus.lua" = "Interface\Design.lua"
    "modules\interface\widgets.lua" = "Interface\Widgets.lua"
    "modules\interface\tabs.lua" = "Interface\Tabs.lua"
    "modules\interface\panels\general_new.lua" = "Interface\Panels\General.lua"
    "modules\interface\panels\sounds_new.lua" = "Interface\Panels\Sounds.lua"
    "modules\interface\panels\about_new.lua" = "Interface\Panels\About.lua"
    "modules\interface\panels\event_simple.lua" = "Interface\Panels\EventSimple.lua"
    "modules\interface\panels\quest_simple.lua" = "Modules\Quest\QuestPanel.lua"
}

foreach ($move in $interfaceMoves.GetEnumerator()) {
    if (Test-Path $move.Key) {
        Move-Item -Path $move.Key -Destination $move.Value -Force
        Write-Host "  Moved: $($move.Key) -> $($move.Value)" -ForegroundColor Green
    }
}

# Move Media files
Write-Host "`nMoving Media files..." -ForegroundColor Yellow

if (Test-Path "media\sounds") {
    Get-ChildItem "media\sounds" -Recurse | ForEach-Object {
        $dest = $_.FullName -replace "media\\sounds", "Media\Sounds"
        $destDir = Split-Path $dest -Parent
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        Move-Item -Path $_.FullName -Destination $dest -Force -ErrorAction SilentlyContinue
    }
    Write-Host "  Moved: media\sounds -> Media\Sounds" -ForegroundColor Green
}

if (Test-Path "media\images") {
    Get-ChildItem "media\images" -Recurse | ForEach-Object {
        $dest = $_.FullName -replace "media\\images", "Media\Textures"
        $destDir = Split-Path $dest -Parent
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        Move-Item -Path $_.FullName -Destination $dest -Force -ErrorAction SilentlyContinue
    }
    Write-Host "  Moved: media\images -> Media\Textures" -ForegroundColor Green
}

# Move Localization
Write-Host "`nMoving Localization files..." -ForegroundColor Yellow

if (Test-Path "modules\localization.lua") {
    Move-Item -Path "modules\localization.lua" -Destination "Localization\enUS.lua" -Force
    Write-Host "  Moved: modules\localization.lua -> Localization\enUS.lua" -ForegroundColor Green
}

# Clean up old empty directories
Write-Host "`nCleaning up old directories..." -ForegroundColor Yellow

$oldDirs = @("core", "modules\features", "modules\interface\panels", "modules\interface", "modules", "media\sounds", "media\images", "media", "sound\packs", "sound")

foreach ($dir in $oldDirs) {
    if (Test-Path $dir) {
        if ((Get-ChildItem $dir -Force).Count -eq 0) {
            Remove-Item $dir -Force -Recurse -ErrorAction SilentlyContinue
            Write-Host "  Removed empty: $dir" -ForegroundColor Gray
        }
    }
}

Write-Host "`nReorganization complete!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Update BLU.toc file with new paths" -ForegroundColor White
Write-Host "2. Create new BLU.xml with proper includes" -ForegroundColor White  
Write-Host "3. Update any hardcoded paths in Lua files" -ForegroundColor White
Write-Host "4. Test the addon in-game" -ForegroundColor White