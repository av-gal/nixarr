{
  lib,
  python3,
  buildNpmPackage,
  buildPythonPackage,
  fetchFromGitHub,
  makeWrapper,
  writeShellScript,
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

with python3.pkgs; buildPythonApplication rec {
  inherit pname version src;
  sourceRoot = "${src.name}/backend";

  pyproject = false;

  # postPatch = ''
  #   # mkdir $out/static
  #   # cp -a ${frontend} $out/static
  #   ls -lar
  #   cp -a app __init__.py $out
  # '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  nativeBuildInputs = [
    makeWrapper
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

  postInstall = 
    let start_script = writeShellScript "start-profilarr" ''
        echo $PYTHONPATH
        ls -la
        ${lib.getExe gunicorn} "$@" --name=profilarr app.main:create_app
      '';
      in 
      ''
      mkdir -p $out/bin
      cp -a app __init__.py $out

      makeWrapper ${start_script} $out/bin/profilarr \
        --set PYTHONPATH "$out/${python3.sitePackages}:${python3.pkgs.makePythonPath dependencies}" \
        --set STATIC_FILES "${frontend}"

    '';

  # nativeCheckInputs = [
  #   hypothesis
  # ];

  meta = {
    changelog = "https://github.com/Dictionarry-Hub/profilarr/releases/tag/${version}";
    description = "Configuration development platform for Radarr/Sonarr ";
    homepage = "https://github.com/Dictionarry-Hub/profilarr";
    license = lib.licenses.gpl3Only;
    mainProgram = "profilarr";
    maintainers = with lib.maintainers; [
      av-gal
    ];
  };
}
