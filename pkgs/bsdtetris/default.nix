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
  version = "0.1.0";
  
  src = fetchFromGitHub {
    owner = "dongdigua";
    repo = "tetris-custom";
    rev = "0.1.0";
    sha256 = "euQqh0gSnZU88oiPCcohsHnYvGSfG3lA0Tmm5p/XNC4=";
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
