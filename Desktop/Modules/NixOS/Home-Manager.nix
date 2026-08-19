{ inputs, config, ... }:

{
  home-manager = {
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.denis = ../../Home-Manager.nix;
  };
}
