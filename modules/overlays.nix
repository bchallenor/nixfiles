{ ... }:

let
  importDir = rootPath:
    let
      names = builtins.attrNames (builtins.readDir rootPath);
      paths = map (name: rootPath + ("/" + name)) names;
      exprs = map (path: import path) paths;
    in

    if builtins.pathExists rootPath
      then exprs
      else []
  ;
in

{
  nixpkgs.overlays = importDir ../overlays;
}
