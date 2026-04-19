{
  pkgs,
  lib,
  nixpak-wrapper,
  photo-gimp-files,
  desktopItem,
  system,
}:
let
  script =
    pkgs.writeScript "photogimp-gimp-nixpak-wrapper-script"
      # bash
      ''
        mkdir -p "$HOME/.config/PhotoGIMP"
        exec "$@"
      '';
in
pkgs.stdenv.mkDerivation {
  name = "photogimp-gimp-nixpak-wrapper";
  buildInputs = [ pkgs.makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/{bin,share}
    makeWrapper ${script} $out/bin/gimp \
      --add-flags ${lib.getExe nixpak-wrapper} \
      --set PATH ${
        lib.makeBinPath (
          with pkgs;
          [
            coreutils
            bash
          ]
        )
      }

    cp -r ${photo-gimp-files}/.local/share/icons $out/share
    install -D ${desktopItem}/share/applications/PhotoGIMP.desktop $out/share/applications/PhotoGIMP.desktop
  '';

  meta = {
    mainProgram = "gimp";
    platforms = [ system ];
  };
}
