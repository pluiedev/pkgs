{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  electron,
  vips,
}:
buildNpmPackage rec {
  pname = "OpenComic";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "ollm";
    repo = pname;
    # contains fix for ollm/OpenComic#191
    # that's preventing the build from working correctly.
    rev = "7aee55ca5dac6b937824728b7ded116dc00c28df";
    hash = "sha256-7nHSeeiR54VFsDgPkr6clhuQbHdSPCPiJ5HQHNmCQxA=";
  };

  npmDepsHash = "sha256-WAwuYEClibX3A/ahUS+zbGYzftq3k1WSCrHSYO8hnNA=";

  nativeBuildInputs = [pkg-config makeWrapper];
  buildInputs = [vips];

  makeCacheWritable = true;
  ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)

    npm run prebuild
    ./node_modules/.bin/electron-builder \
      --linux appimage \
      -c.electronDist=${electron}/libexec/electron \
      -c.electronVersion=${electron.version}

    ls

    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out

    runHook postInstall
  '';

  # installPhase = ''
  #   runHook preInstall
  #
  #   mkdir -p $out/resources
  #   cp -r dist/linux-unpacked/resources/* $out/resources
  #
  #   makeWrapper ${electron}/bin/electron $out/bin/opencomic \
  #     --add-flags $out/resources/app.asar \
  #     --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
  #
  #   runHook postInstall
  # '';

  meta = with lib; {
    description = "Comic and Manga reader, written with Node.js and using Electron";
    homepage = "https://github.com/ollm/OpenComic";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [];
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "opencomic";
  };
}
