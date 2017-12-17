{ pkgs, lib, ... }:
{
  imports = [
    ./hardware.nix
    #./wifi.nix
    ./kernel.nix
    ./firmware
  ];
  
  environment.systemPackages = with pkgs; [
    vim
  ];
  nixpkgs.config.allowUnfree = true; # for firmware

  # neet 4.14+ for proper hardware support (and modesetting)
  # especially for screen rotation on boot
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_gpd_pocket;
  boot.initrd.kernelModules = [
    "pwm-lpss" "pwm-lpss-platform" # for brightness control
    "g_serial" # be a serial device via OTG
  ];
  networking.networkmanager.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];


  users.users = {
    andi = {
      isNormalUser = true;
      name = "andi";
      group = "users";
      extraGroups = ["wheel" "networkmanager" "docker" "cdrom" "dialout" "nitrokey"];
      uid = 1000;
      createHome = true;
      home = "/home/andi/";
      shell = pkgs.zsh;
    };
    root.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHI4+Y1uPC+2KV0kVinvPVGA4YUl1bl3n0Gc4/GC9IflFYiSdq56fY5QaHuOciDleTR28wKydKBakGNO8GdrjCHkdEQbSNbeDWv8Xewq4XYiH9KsurbLnERIOZpGqjgMbmv+xXcqnHdK4QpieiKPtJ+WdLLjC8zpL1JMAIyfJ+FxQ3BJywdfZfcDMbrzVGWZBJ3jHC7F9VxG5+4m3e24pOBt08cm1E0nQy4OU736lXo6iz/5vwrgoTjSgPHB8nk5kK0/kn3oyAT441q8HQWJj1obER8qswuJc3nnT/pOP1GTG7xu17NuF8pJefRnve1ZepBZYhyqfOAjwxDVwHnYlvF53kX1XCp9p5J/Fk40oFxT4DwrUPE+6hxo2C3KK2rXZiwXJWjCFweMANaBKjWyqAGuTAhgADPhfEkapuPVe0tO0AWxF62Oj+jl2BT/huFfeO9dY413yh9kH9sbnxcQSpvxfXngCb6BTxTujY83SAPSPnlPPmJP00DMO8PzY7TmtrUa7iio2piteKyiEkhxKc75t7//fJKPQBRa/fKeNWIRvJB+ws5GcKqL3JJH5T/r9FfFXzIu/KpSdchoPX9qj+RXYIIGq78Ufwn8HFtxH0MI3EEoNx70bfxMHT15mxuzNNnN6/wBiJ78JVdV3IV15SwMDnN0Hp6g946mPdxFfa3w=="
    ];
  };

}
