{pkgs}: 
let  
  src = ./brcmfmac4356-pcie.txt;
in
(pkgs.runCommand "gpd-pocket-wifi" {} ''
  mkdir -p $out/lib/firmware/brcm
  cp ${src} $out/lib/firmware/brcm/brcmfmac4356-pcie.txt 
'')
