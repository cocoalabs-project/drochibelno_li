{
  description = "Flake for 'Drochibelno li?'";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          pythonEnv = pkgs.python3.withPackages (ps: [
            ps.aiogram
            ps.aiohttp-socks
            ps.python-dotenv
          ]);
        in
        {
          drochibelnoLi = pkgs.stdenv.mkDerivation {
            pname = "drochibelno_li";
            version = "0.3.0";
            src = pkgs.lib.cleanSource ./.;

            nativeBuildInputs = [ pkgs.makeWrapper ];

            installPhase = ''
              mkdir -p $out/libexec/drochibelno_li $out/bin
              cp -r . $out/libexec/drochibelno_li/

              makeWrapper ${pythonEnv}/bin/python $out/bin/drochibelno_li \
                --add-flags "$out/libexec/drochibelno_li/main.py"
            '';
          };
          default = self.packages.${system}.drochibelnoLi;
        }
      );

      nixosModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.services.drochibelno_li;
          botPkg = self.packages.${pkgs.system}.drochibelnoLi;
        in
        {
          options.services.drochibelno_li = {
            enable = lib.mkEnableOption "Drochibelno Li? service";

            tokenFile = lib.mkOption {
              type = lib.types.path;
              description = "Path to the file containing the Telegram Bot API token.";
            };

            settings = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = { };
              description = "Environment variables passed to the bot service.";
            };
          };

          config = lib.mkIf cfg.enable {
            users.users.drochibelnoli = {
              isSystemUser = true;
              group = "drochibelnoli";
              description = "Drochibelno li? user";
            };

            users.groups.drochibelnoli = { };

            systemd.services.drochibelno_li = {
              description = "Drochibelno Li?";
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];

              environment = cfg.settings;

              serviceConfig = {
                User = "drochibelnoli";
                Group = "drochibelnoli";
                Restart = "always";
                RestartSec = "5s";

                LoadCredential = [ "bot_token:${cfg.tokenFile}" ];

                ProtectSystem = "strict";
                ProtectHome = true;
                PrivateTmp = true;
                NoNewPrivileges = true;
              };

              script = ''
                if [ -f "$CREDENTIALS_DIRECTORY/bot_token" ]; then
                  export TOKEN="$(cat "$CREDENTIALS_DIRECTORY/bot_token")"
                fi
                exec ${botPkg}/bin/drochibelno_li
              '';
            };
          };
        };
    };
}
