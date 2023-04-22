{ python3Packages
, fetchFromGitHub
, lib
, yubikey-personalization
, libu2f-host
, libusb1
, procps
, stdenv }:

python3Packages.buildPythonPackage rec {
  pname = "canokey-manager";
  version = "canokey";
  format = "pyproject";

  src = fetchFromGitHub {
    repo = "yubikey-manager";
    rev = "7e9fff8232ed914c417e0dcf7e81766869a91451";
    owner = "canokeys";
    sha256 = "sha256-sOSLV9P3iV5dG4bzNBXq1A0dI05P/IoD/eRMUyJxE4s=";
  };

  postPatch = ''
    cp -r ykman ckman
    cp -r yubikit canokit
    substituteInPlace pyproject.toml \
      --replace 'fido2 = ">=0.9, <1.0"' 'fido2 = ">0"'
    substituteInPlace pyproject.toml \
      --replace 'cryptography = "^2.1 || ^3.0"' 'cryptography = ">=2.1"'
    substituteInPlace "ckman/pcsc/__init__.py" \
      --replace 'pkill' '${if stdenv.isLinux then "${procps}" else "/usr"}/bin/pkill'
  '';

  nativeBuildInputs = with python3Packages; [ poetry-core ];

  propagatedBuildInputs =
    with python3Packages; [
      click
      cryptography
      pyscard
      pyusb
      six
      fido2
      keyring
      pyopenssl
    ] ++ [
      libu2f-host
      libusb1
      yubikey-personalization
    ];

  makeWrapperArgs = [
    "--prefix" "LD_LIBRARY_PATH" ":"
    (lib.makeLibraryPath [ libu2f-host libusb1 yubikey-personalization ])
  ];

  postInstall = ''
    mkdir -p "$out/man/man1"
    cp man/ykman.1 "$out/man/man1"
  '';

  checkInputs = with python3Packages; [ pytestCheckHook makefun ];

  meta = with lib; {
    homepage = "https://www.canokeys.org";
    description = "Command line tool for configuring Canokey over all USB transports";

    license = licenses.bsd2;
    platforms = platforms.unix;
    # maintainers = with maintainers; [  ];
    mainProgram = "ckman";
  };
}
