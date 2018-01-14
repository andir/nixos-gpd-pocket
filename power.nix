{
  # make sure proper charging already works before unlocking the rootfs
   boot.initrd.kernelModules = [
    "bq24190_charger"
    "fusb302"
  ]; 

}
