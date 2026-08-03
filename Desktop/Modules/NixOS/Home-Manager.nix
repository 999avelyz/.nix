{ inputs, config, ... }:

{
  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.denis = ../../Home-Manager.nix;
  };
}
