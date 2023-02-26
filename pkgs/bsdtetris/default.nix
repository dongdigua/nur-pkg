{ lib
, stdenv
, fetchFromGitHub
, libbsd
, ncurses
, pkg-config
, ...
} @ args:

stdenv.mkDerivation rec {
  name = "bsdtetris-${version}";
  version = "0.2.0";
  
  src = fetchFromGitHub {
    owner = "dongdigua";
    repo = "tetris-custom";
    rev = "0.2.0";
    sha256 = "Xns4M9Glvcg5VjBupsVeLHwFRoFIJgXPYhmYVPaTi8k=";
  };

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    libbsd
    ncurses
  ];

  buildPhase = "make";
  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 tetris $out/bin
  '';
}
