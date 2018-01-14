{ pkgs, ... }:
let
  # 4.15-rc3 with patches from Hans de Goede
  rev = {
    "4.15-rc3.hdg" = "cf59a9b05feb95999a1a2c095e52398267e55db6";
    "4.15-rc4.hdg.1" = "104ec842fffc";
    "4.15-rc5.hdg.1" = "ca0044fbcd48";
    "4.15-rc6.hdg.1" = "a89c5913cc24ef352e8031810e9778d6182f8e0b";
    "4.15-rc7.hdg.1" = "54bf2399b1f22a5a52db68fbe4bbdc3d0c6c7644";
  };
  sha256 = {
    "4.15-rc3.hdg" = "0ljqqxmr3jg658j7av5dh00s36in7dlsbwsz5ivlp2n6qkqw4486";
    "4.15-rc4.hdg.1" = "02hzhr36jnrg1i5hhqr589c4xbayzs10nibl47s8qac11nfgwv52";
    "4.15-rc5.hdg.1" = "0bmhhdj43a5z8162n796l4wb8k08nfbca7ci64j9zxv5ixa8lz5k";
    "4.15-rc6.hdg.1" = "1x4bp6ikfmi6xrcdl0r8n3mf6hyhy1vk3x4wnbgval0g98s2dz8l";
    "4.15-rc7.hdg.1" = "0sqqid6w818cvr59y4zwv6kc2bw29fkz08yscv68vniv8wj65182";
  };
  version =  "4.15-rc7.hdg.1";

  cleanSource = src: pkgs.runCommand "clean-src-${version}" {} ''
    set -ex
    cp -r ${src} $out
    chmod u+rw -R $out
    rm $out/.config
    ${pkgs.gnumake}/bin/make -C $out mrproper
    #echo 'EXPORT_SYMBOL_GPL(xhci_ext_cap_init);' >> $out/drivers/usb/host/xhci-ext-caps.c
    cat $out/drivers/usb/host/xhci-ext-caps.c
  '';

  pkg = { stdenv, gnumake, hostPlatform, fetchurl, fetchFromGitHub, perl, buildLinux, libelf, utillinux, ... } @ args:
    import <nixpkgs/pkgs/os-specific/linux/kernel/generic.nix> (args // rec {
      inherit version;
      kernelPatches = [
        pkgs.kernelPatches.bridge_stp_helper
        pkgs.kernelPatches.modinst_arg_list_too_long
      ];
      modDirVersion = "4.15.0-rc7";
      extrameta.branch = "4.15";
      src = cleanSource (fetchFromGitHub {
        owner = "jwrdegoede";
        repo = "linux-sunxi";
        rev = rev.${version};
        sha256 = sha256.${version};
      });
      extraConfig = ''
       ACPI_CUSTOM_METHOD m
       B43_SDIO y
       BATTERY_MAX17042 m

       COMMON_CLK y

       INTEL_SOC_PMIC? y
       INTEL_SOC_PMIC_CHTWC? y
       INTEL_PMC_IPC m
       INTEL_BXTWC_PMIC_TMU m

       ACPI y
       PMIC_OPREGION y
       CHT_WC_PMIC_OPREGION? y
       XPOWER_PMIC_OPREGION y
       BXT_WC_PMIC_OPREGION y
       CRC_PMIC_OPREGION? y # wtf. nix kernel config script is madness
       XPOWER_PMIC_OPREGION y
       CHT_DC_TI_PMIC_OPREGION y

       #EXTCON_INTEL_CHT_WC? y # wtf

       DW_DMAC y
       DW_DMAC_CORE y
       DW_DMAC_PCI y
       GPD_POCKET_FAN y
       HSU_DMA y
       I2C_CHT_WC? y
       I2C_DESIGNWARE_BAYTRAIL? y
       INTEL_CHT_INT33FE m
       MFD_AXP20X m
       #MUX_INTEL_CHT_USB_MUX m
       TYPEC_MUX_PI3USB30532 m
       #MUX_PI3USB30532 m
       NVRAM y
       POWER_RESET y
       PWM y
       PWM_LPSS m
       PWM_LPSS_PCI m
       PWM_LPSS_PLATFORM m
       PWM_SYSFS y
       RAW_DRIVER y
       RTC_DS1685_SYSFS_REGS y
       SERIAL_8250_DW y
       SERIAL_8250_MID y
       SERIAL_8250_NR_UARTS 32
       SERIAL_8250_PCI m
       SERIAL_DEV_BUS y
       SERIAL_DEV_CTRL_TTYPORT y
       TOUCHSCREEN_ELAN m
       TULIP_MMIO y
       W1_SLAVE_DS2433_CRC y
       XXHASH m
     '';
  });

in {
  nixpkgs.overlays = [ (self: super: {
    linux_gpd_pocket = super.callPackage pkg {};
  })];
}
