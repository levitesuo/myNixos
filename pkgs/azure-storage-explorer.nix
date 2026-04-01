{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper, makeDesktopItem, copyDesktopItems
, alsa-lib, at-spi2-atk, at-spi2-core, atk, cairo, cups, dbus, expat, fontconfig
, freetype, gdk-pixbuf, glib, gtk3, libdrm, libnotify, libuuid, libX11, libxcb
, libXcomposite, libXdamage, libXext, libXfixes, libXrandr, libxshmfence
, mesa, nspr, nss, pango, systemd, xdg-utils, libsecret, libxkbcommon
}:

let
  desktopItem = makeDesktopItem {
    name = "azure-storage-explorer";
    desktopName = "Azure Storage Explorer";
    exec = "azure-storage-explorer %U";
    icon = "azure-storage-explorer";
    comment = "Manage Azure Storage resources";
    categories = [ "Development" "Utility" ];
    startupWMClass = "StorageExplorer";
  };
in
stdenv.mkDerivation rec {
  pname = "azure-storage-explorer";
  version = "1.42.0";

  src = fetchurl {
    url = "https://github.com/microsoft/AzureStorageExplorer/releases/download/v${version}/StorageExplorer-linux-x64.tar.gz";
    sha256 = "sha256-iJ/PvFnKEbN5fxwFWjxs8ybjsQCvSyfsSx57j6lFuKo=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper copyDesktopItems ];

  buildInputs = [
    alsa-lib at-spi2-atk at-spi2-core atk cairo cups dbus expat fontconfig
    freetype gdk-pixbuf glib gtk3 libdrm libnotify libuuid libX11 libxcb
    libXcomposite libXdamage libXext libXfixes libXrandr libxshmfence
    mesa nspr nss pango systemd libsecret libxkbcommon
  ];

  desktopItems = [ desktopItem ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/azure-storage-explorer
    cp -r . $out/opt/azure-storage-explorer/

    chmod +x $out/opt/azure-storage-explorer/StorageExplorer

    mkdir -p $out/bin
    makeWrapper $out/opt/azure-storage-explorer/StorageExplorer $out/bin/azure-storage-explorer \
      --add-flags "--no-sandbox --password-store=basic" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libsecret libxkbcommon ]}"

    mkdir -p $out/share/pixmaps
    if [ -f $out/opt/azure-storage-explorer/resources/app/out/app/icon.png ]; then
      cp $out/opt/azure-storage-explorer/resources/app/out/app/icon.png $out/share/pixmaps/azure-storage-explorer.png
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Azure Storage Explorer - Manage Azure storage resources from your desktop";
    homepage = "https://github.com/microsoft/AzureStorageExplorer";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "azure-storage-explorer";
  };
}
