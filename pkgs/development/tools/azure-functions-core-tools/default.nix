{ stdenv
, lib
, config
, fetchFromGitHub
, icu
, libunwind
, curl
, zlib
, libuuid
, dotnetCorePackages
, openssl
, buildDotnetModule
, bash
, buildGoModule
}@pkgs:

let gozip = (import ./gozip.nix { inherit (pkgs) buildGoModule fetchFromGitHub; });
in buildDotnetModule rec {
  pname = "azure-functions-core-tools";
  version = "4.0.4785";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-functions-core-tools";
    rev = "refs/tags/${version}";
    sha256 = "sha256-XkoJYP05JgOmKUdI1fthLVdJuOryvN61hjpGosre2Oo=";
  };

  projectFile = "src/Azure.Functions.Cli/Azure.Functions.Cli.csproj";
  nugetDeps = ./deps.nix;
  dotnet-sdk = dotnetCorePackages.sdk_6_0;
  dotnet-runtime =
    (with dotnetCorePackages; combinePackages [ runtime_6_0 aspnetcore_6_0 ]);
  # TODO this needs to be updated for Darwin
  dotnetFlags = [ "--runtime linux-x64" ];

  buildInputs = [ bash gozip ];

  libPath = lib.makeLibraryPath [
    libunwind
    libuuid
    stdenv.cc.cc
    curl
    zlib
    icu
    openssl
  ];

  executables = [ "func" ];

  prePatch = ''
    substituteInPlace src/Azure.Functions.Cli/Common/CommandChecker.cs \
      --replace '/bin/bash' ${bash}/bin/bash
    substituteInPlace src/Azure.Functions.Cli/Helpers/ZipHelper.cs \
      --replace 'Assembly.GetExecutingAssembly().Location' \"${gozip}/bin/gozip\"
  '';

  # TODO update the meta section
  meta = with lib; {
    homepage = "https://github.com/Azure/azure-functions-core-tools";
    description = "Command line tools for Azure Functions";
    sourceProvenance = with sourceTypes; [ fromSource ];
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
  };
}
