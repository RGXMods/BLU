@echo off
echo Creating new folder structure for BLU addon...

:: Create new directories
mkdir Core 2>nul
mkdir Modules\LevelUp 2>nul
mkdir Modules\Achievement 2>nul
mkdir Modules\Quest 2>nul
mkdir Modules\Reputation 2>nul
mkdir Modules\BattlePet 2>nul
mkdir Modules\Honor 2>nul
mkdir Modules\Renown 2>nul
mkdir Modules\TradingPost 2>nul
mkdir Modules\Delve 2>nul
mkdir Interface\Panels 2>nul
mkdir Interface\Templates 2>nul
mkdir Media\Sounds 2>nul
mkdir Media\Textures 2>nul
mkdir Media\Images 2>nul
mkdir Localization 2>nul
mkdir Libs 2>nul

echo Moving Core files...
:: Move core files
move /Y core\framework.lua Core\Core.lua 2>nul
move /Y core\database.lua Core\Database.lua 2>nul
move /Y core\init.lua Core\Init.lua 2>nul
move /Y core\commands.lua Core\Commands.lua 2>nul
move /Y core\options_launcher.lua Core\OptionsLauncher.lua 2>nul
move /Y modules\config.lua Core\Config.lua 2>nul
move /Y modules\utils.lua Core\Utils.lua 2>nul

echo Moving Module files...
:: Move feature modules
move /Y modules\features\levelup.lua Modules\LevelUp\LevelUp.lua 2>nul
move /Y modules\features\achievement.lua Modules\Achievement\Achievement.lua 2>nul
move /Y modules\features\quest.lua Modules\Quest\Quest.lua 2>nul
move /Y modules\features\reputation.lua Modules\Reputation\Reputation.lua 2>nul
move /Y modules\features\battlepet.lua Modules\BattlePet\BattlePet.lua 2>nul
move /Y modules\features\honorrank.lua Modules\Honor\Honor.lua 2>nul
move /Y modules\features\renownrank.lua Modules\Renown\Renown.lua 2>nul
move /Y modules\features\tradingpost.lua Modules\TradingPost\TradingPost.lua 2>nul
move /Y modules\features\delvecompanion.lua Modules\Delve\Delve.lua 2>nul

echo Moving Interface files...
:: Move interface files
move /Y modules\interface\options_new.lua Interface\Settings.lua 2>nul
move /Y modules\interface\design_narcissus.lua Interface\Design.lua 2>nul
move /Y modules\interface\widgets.lua Interface\Widgets.lua 2>nul
move /Y modules\interface\tabs.lua Interface\Tabs.lua 2>nul

:: Move panels
move /Y modules\interface\panels\general_new.lua Interface\Panels\General.lua 2>nul
move /Y modules\interface\panels\sounds_new.lua Interface\Panels\Sounds.lua 2>nul
move /Y modules\interface\panels\about_new.lua Interface\Panels\About.lua 2>nul
move /Y modules\interface\panels\event_simple.lua Interface\Panels\EventSimple.lua 2>nul
move /Y modules\interface\panels\quest_simple.lua Interface\Panels\QuestPanel.lua 2>nul

echo Moving Media files...
:: Move media files
xcopy /E /Y /I media\sounds Media\Sounds 2>nul
xcopy /E /Y /I media\images Media\Textures 2>nul

echo Moving Localization files...
:: Move localization
move /Y modules\localization.lua Localization\enUS.lua 2>nul

echo Moving other modules...
:: Move other important modules
move /Y modules\registry.lua Core\Registry.lua 2>nul
move /Y modules\loader.lua Core\Loader.lua 2>nul
move /Y modules\sharedmedia.lua Core\SharedMedia.lua 2>nul

echo Reorganization complete!
echo.
echo Don't forget to:
echo 1. Update BLU.toc file with new paths
echo 2. Update all XML files with new includes
echo 3. Test the addon in-game
pause