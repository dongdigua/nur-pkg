{ lib, stdenv, fetchFromGitHub, fetchpatch
, ncurses, boehmgc, gettext, zlib
, sslSupport ? true, libressl
, graphicsSupport ? !stdenv.isDarwin, imlib2
, x11Support ? graphicsSupport, libX11
, mouseSupport ? !stdenv.isDarwin, gpm-ncurses
, perl, man, pkg-config, buildPackages, w3m
}:

let
  mktable = buildPackages.stdenv.mkDerivation {
    name = "w3m-mktable";
    inherit (w3m) src;
    nativeBuildInputs = [ pkg-config boehmgc ];
    makeFlags = [ "mktable" ];
    installPhase = ''
      install -D mktable $out/bin/mktable
    '';
  };
in stdenv.mkDerivation rec {
  pname = "w3m";
  version = "0.5.3+git20230121"; # fedora uses this version

  src = fetchFromGitHub {
    owner = "tats";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-upb5lWqhC1jRegzTncIz5e21v4Pw912FyVn217HucFs=";
  };

  NIX_LDFLAGS = lib.optionalString stdenv.isSunOS "-lsocket -lnsl";

  # we must set these so that the generated files (e.g. w3mhelp.cgi) contain
  # the correct paths.
  PERL = "${perl}/bin/perl";
  MAN = "${man}/bin/man";

  makeFlags = [ "AR=${stdenv.cc.bintools.targetPrefix}ar" ];

  patches = [
#    ./RAND_egd.libressl.patch
    (fetchpatch {
      name = "https.patch";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/https.patch?h=w3m-mouse&id=5b5f0fbb59f674575e87dd368fed834641c35f03";
      sha256 = "08skvaha1hjyapsh8zw5dgfy433mw2hk7qy9yy9avn8rjqj7kjxk";
    })
    (fetchpatch {
      name = "gemini.patch";
      url = "https://rkta.de/assets/gemini.patch";
      sha256 = "sha256-BvIxpuLqIJYXPJt9boXBqlUQ8xmmzNPgXV5zokXce00=";
    })
  ];

  postPatch = lib.optionalString (stdenv.hostPlatform != stdenv.buildPlatform) ''
    ln -s ${mktable}/bin/mktable mktable
    # stop make from recompiling mktable
    sed -ie 's!mktable.*:.*!mktable:!' Makefile.in
  '';

  nativeBuildInputs = [ pkg-config gettext ];
  buildInputs = [ ncurses boehmgc zlib ]
    ++ lib.optional sslSupport libressl
    ++ lib.optional mouseSupport gpm-ncurses
    ++ lib.optional graphicsSupport imlib2
    ++ lib.optional x11Support libX11;

  postInstall = lib.optionalString graphicsSupport ''
    ln -s $out/libexec/w3m/w3mimgdisplay $out/bin
  '';

  hardeningDisable = [ "format" ];

  configureFlags =
    [ "--with-ssl=${libressl.dev}" "--with-gc=${boehmgc.dev}" ]
    ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
      "ac_cv_func_setpgrp_void=yes"
    ]
    ++ lib.optional graphicsSupport "--enable-image=${lib.optionalString x11Support "x11,"}fb"
    ++ lib.optional (graphicsSupport && !x11Support) "--without-x";

  preConfigure = ''
    substituteInPlace ./configure --replace "/lib /usr/lib /usr/local/lib /usr/ucblib /usr/ccslib /usr/ccs/lib /lib64 /usr/lib64" /no-such-path
    substituteInPlace ./configure --replace /usr /no-such-path
  '';

  enableParallelBuilding = false;

  # for w3mimgdisplay
  # see: https://bbs.archlinux.org/viewtopic.php?id=196093
  LIBS = lib.optionalString x11Support "-lX11";

  meta = with lib; {
    homepage = "http://w3m.sourceforge.net/";
    description = "A text-mode web browser (with gemini support)";
    maintainers = with maintainers; [ cstrahan anthonyroussel ];
    platforms = platforms.unix;
    license = licenses.mit;
  };
}
