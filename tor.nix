{ lib, pkgs, ... }:
let
  irc-announce = pkgs.callPackage ./irc-announce {};
  untilport = pkgs.callPackage ./untilport {};
in {

  networking.firewall.enable = false;

  services.tor = {
    enable = true;
    hiddenServices."ssh".map = [ { port = 22; } ];
    extraConfig = ''
      SocksPort 0
      HiddenServiceNonAnonymousMode 1
      HiddenServiceSingleHopMode 1
      ExitNodes {de}
      NewCircuitPeriod 120
    '';
  };

  systemd.services.hidden-ssh-announce = {
    description = "irc announce hidden ssh";
    after = [ "tor.service" "network-online.target" ];
    wants = [ "tor.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      set -efu
      until test -e /var/lib/tor/onion/ssh/hostname; do
      echo "still waiting for /var/lib/tor/onion/ssh/hostname"
      sleep 1
      done
      ${untilport}/bin/untilport irc.hackint.org 6667 && \
      ${irc-announce}/bin/irc-announce \
        irc.hackint.org 6667 install-image "#nixinstaller" \
        "SSH Hidden Service at $(cat /var/lib/tor/onion/ssh/hostname)"
    '';
    serviceConfig = {
      PrivateTmp = "true";
      User = "tor";
      Type = "oneshot";
    };
  };


}
