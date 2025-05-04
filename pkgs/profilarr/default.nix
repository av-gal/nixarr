{
  lib,
  buildNpmPackage,
  buildPythonPackage,
  fetchFromGitHub,
  fetchPypi,
}:
let
  pname = "profilarr";
  version = "1.0.1";
  src = fetchFromGitHub {
    owner = "Dictionarry-Hub";
    repo = pname;
    tag = "v${version}";
    hash = "";
  };

frontend = buildNpmPackage rec {
  inherit version src;
  pname = "${pname}-frontend";

  npmDepsHash = "";

  sourceRoot = "frontend";

  # meta = with lib; {
  #   description = "cross-seed is an app designed to help you download torrents that you can cross seed based on your existing torrents";
  #   homepage = "https://www.cross-seed.org";
  #   license = licenses.asl20;
  # };
};

in

buildPythonPackage rec {
  inherit pname version src;

  # postPatch = ''
  #   # don't test bash builtins
  #   rm testing/test_argcomplete.py
  # '';

  # build-system = [
  #   setuptools
  #   setuptools-scm
  # ];

  # dependencies = [
  #   attrs
  #   py
  #   setuptools
  #   six
  #   pluggy
  # ];

  # nativeCheckInputs = [
  #   hypothesis
  # ];

  meta = {
    changelog = "https://github.com/pytest-dev/pytest/releases/tag/${version}";
    description = "Framework for writing tests";
    homepage = "https://github.com/pytest-dev/pytest";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      domenkozar
      lovek323
      madjar
      lsix
    ];
  };
}
