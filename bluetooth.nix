{pkgs, ...}:
{
  hardware.bluetooth.enable = true;
  boot.kernelModules = [ "btusb" ];
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
}
