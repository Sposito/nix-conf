{ pkgs, ... }:
{
  virtualisation.oci-containers = {
    backend = "docker"; # can switch to "podman" later

    containers = {
      forgejo = {
        image = "codeberg.org/forgejo/forgejo:latest";
        ports = [ "3000:3000" "2222:22" ];

        environment = {
          USER_UID = "1000";
          USER_GID = "1000";

          # SQLite setup
          FORGEJO__database__DB_TYPE = "sqlite3";
          FORGEJO__database__PATH = "/data/forgejo.db";

          # Basic server settings
          FORGEJO__server__DOMAIN = "git.example.com"; # change to your domain or IP
          FORGEJO__server__ROOT_URL = "http://git.example.com:3000/";
          FORGEJO__server__HTTP_PORT = "3000";

          # SSH server
          FORGEJO__ssh__START_SSH_SERVER = "true";
          FORGEJO__ssh__SSH_PORT = "22";
        };

        volumes = [
          "/var/lib/forgejo:/data" # Everything (repos, users, configs, db) in one place
        ];
      };
    };
  };

  # enable docker runtime
  virtualisation.docker.enable = true;

  # open needed ports
  networking.firewall.allowedTCPPorts = [ 3000 2222 ];
}
