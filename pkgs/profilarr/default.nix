{
  lib,
  python3,
  python3Packages,
  buildNpmPackage,
  buildPythonPackage,
  fetchFromGitHub,
}:
let
  pname = "profilarr";
  version = "1.0.1";
  src = fetchFromGitHub {
    owner = "Dictionarry-Hub";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-xrzR9bcI/snu8j1uIfeYLEc9tSt4n+8fKMSWsX4R27Q=";
  };

frontend = buildNpmPackage {
  pname = "${pname}-frontend";
  inherit src version;

  npmDepsHash = "sha256-G92jRcW/+eR7JnDJ3dCEe1hktRv3fmuNuZxh7L3yIc8=";

  sourceRoot = "${src.name}/frontend";

  installPhase = ''
    cp -a dist $out
  '';
};

in

with python3Packages; buildPythonApplication rec {
  inherit pname version src;
  sourceRoot = "${src.name}/backend";

  pyproject = false;

  postPatch = ''
    cp -a ${frontend} static
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    flask
    flask-cors
    pyyaml
    requests
    werkzeug
    gitpython
    regex
    apscheduler
    gunicorn
  ];

  # nativeCheckInputs = [
  #   hypothesis
  # ];

  meta = {
    changelog = "https://github.com/Dictionarry-Hub/profilarr/releases/tag/${version}";
    description = "Configuration development platform for Radarr/Sonarr ";
    homepage = "https://github.com/Dictionarry-Hub/profilarr";
    license = lib.licenses.gpl3Only;
    # mainProgram = gu
    maintainers = with lib.maintainers; [
      av-gal
    ];
  };
}
