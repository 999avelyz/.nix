{ inputs, config, ... }:

{
  home-manager = {
    useUserPackages = true;
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs; };
    users.denis = ../../Home-Manager.nix;
  };
}
