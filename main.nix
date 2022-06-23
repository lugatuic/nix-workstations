{config, lib, pkgs, ...}:

{

  imports = [./system/configuration.nix];

  users.motd = ''
    Hello random user, Welcome to LUG+ACM at UIC!\n
    Enjoy using this super cool Workstation powered by NixOS!\n\n
  '';
  users.users.lugnix = {
    isNormalUser = true;
    extraGroups = ["users" "wheel"];
    createHome = true;

  }


}
