{ pkgs, ... }:
let
  # 4.15-rc3 with patches from Hans de Goede
  rev = {
    "4.15-rc3.hdg" = "cf59a9b05feb95999a1a2c095e52398267e55db6";
  };
  sha256 = {
    "4.15-rc3.hdg" = "0ljqqxmr3jg658j7av5dh00s36in7dlsbwsz5ivlp2n6qkqw4486";
  };
  version =  "4.15-rc3.hdg";

  cleanSource = src: pkgs.runCommand "clean-src-${version}" {} ''
    set -ex
    cp -r ${src} $out
    chmod u+rw -R $out
    rm $out/.config
    ${pkgs.gnumake}/bin/make -C $out mrproper
    echo 'EXPORT_SYMBOL_GPL(xhci_ext_cap_init);' >> $out/drivers/usb/host/xhci-ext-caps.c
    cat $out/drivers/usb/host/xhci-ext-caps.c
  '';

  pkg = { stdenv, gnumake, hostPlatform, fetchurl, fetchFromGitHub, perl, buildLinux, libelf, utillinux, ... } @ args:
    import <nixpkgs/pkgs/os-specific/linux/kernel/generic.nix> (args // rec {
      inherit version;
      kernelPatches = [
        pkgs.kernelPatches.bridge_stp_helper
        pkgs.kernelPatches.modinst_arg_list_too_long
      ];
      modDirVersion = "4.15.0-rc3";
      extrameta.branch = "4.15";
      src = cleanSource (fetchFromGitHub {
        owner = "jwrdegoede";
        repo = "linux-sunxi";
        rev = rev.${version};
        sha256 = sha256.${version};
      });
            extraConfig = ''
             CONFIG_PWM=y
             CONFIG_PWM_SYSFS y
             CONFIG_PWM_CRC y
             CONFIG_PWM_LPSS m
             CONFIG_PWM_LPSS_PCI m
             CONFIG_PWM_LPSS_PLATFORM m
             GPD_POCKET_FAN y
             INTEL_CHT_INT33FE m
             MUX_PI3USB30532 m
             MUX_INTEL_CHT_USB_MUX y
            '';
  });

in {
  nixpkgs.overlays = [ (self: super: {
    linux_gpd_pocket = super.callPackage pkg {};
  })];
}
