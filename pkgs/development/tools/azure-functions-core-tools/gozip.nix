{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "gozip";
  version = "4.0.4895";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-functions-core-tools";
    rev = "refs/tags/${version}";
    sha256 = "sha256-XkoJYP05JgOmKUdI1fthLVdJuOryvN61hjpGosre2Oo=";
  };

  modRoot = "tools/go/gozip";
  vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
}
