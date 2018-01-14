{
  # on resume the i2c bus complains, reloading the module helps
  powerManagement = {
    enable = true;
    powerDownCommands = ''
      modprobe -r goodix
    '';
    resumeCommands = ''
      modprobe goodix
    '';
  };
}
