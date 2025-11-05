{ config, pkgs, stylix, ... }:
{
    programs.adb.enable = true;
    services.udev.packages = [
        pkgs.android-udev-rules
    ];
}
