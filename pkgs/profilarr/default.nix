{
  lib,
  git,
  python3,
  buildNpmPackage,
  buildPythonPackage,
  fetchFromGitHub,
  makeWrapper,
}:
let
  pname = "profilarr";
  version = "1.0.1";
  src = fetchFromGitHub {
    owner = "Dictionarry-Hub";
    repo = pname;
    rev = "9e2d1979ef9752a848c011983d7ed2f877b8fe1b";
    hash = "sha256-0h9uy/kl19NA5EnRDvzdaaisqGa1CmcdYKnz9YOZXDQ=";
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
      ''
      mkdir -p $out/bin
      cp -a app __init__.py $out
      cp -a ${frontend} $out/app/static

      makeWrapper ${lib.getExe gunicorn} $out/bin/profilarr \
        --prefix PATH : ${git}/bin \
        --set PYTHONPATH "$out/${python3.sitePackages}:${python3.pkgs.makePythonPath dependencies}" \
        --append-flags "--name=profilarr --chdir $out 'app.main:create_app()'"

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
