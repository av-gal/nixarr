{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
gunicorn = pkgs.python3Packages.gunicorn;
  cfg = config.util-nixarr.services.profilarr;
in {

  options = {
    util-nixarr.services.profilarr = {
      enable = mkEnableOption "Profilarr";

      package = mkPackageOption pkgs "profilarr" {};

      user = mkOption {
        type = types.str;
        default = "profilarr";
        description = "User account under which Profilarr runs.";
      };

      group = mkOption {
        type = types.str;
        default = "profilarr";
        description = "Group under which Profilarr runs.";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/profilarr";
        description = "The directory where Profilarr stores its data files.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for the Profilarr web interface.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.profilarr = {
      description = "Profilarr";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} --bind 0.0.0.0:6868 app.main:create_app()";
        Restart = "on-failure";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [6868];
    };
  };
}
