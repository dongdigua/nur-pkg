{ lib, stdenv, fetchFromSourcehut, qbe }:
# https://github.com/oasislinux/oasis/issues/13
# https://github.com/nix-community/nur-combined/blob/master/repos/sikmir/pkgs/suckless/cproc/default.nix

stdenv.mkDerivation (finalAttrs: {
  pname = "cproc";
  version = "2022-11-29";

  src = fetchFromSourcehut {
    owner = "~mcf";
    repo = "cproc";
    rev = "9ae9aa6dce652ab62c1c9ca34e8419e5dc510de1";
    hash = "sha256-Wdw63j+Ti/BOtfZryAsaXiAOjP4Bdt2OB7sVlV8eAxA=";
  };

  buildInputs = [ qbe ];

  doCheck = true;

  postInstall = ''
    mkdir -p "$out/man/man1"
    cp cproc.1 "$out/man/man1"
  '';

  meta = with lib; {
    description = "C11 compiler using QBE as a backend";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.isc;
    #maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
