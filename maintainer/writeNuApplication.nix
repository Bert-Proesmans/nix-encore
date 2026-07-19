{
  lib,
  writeTextFile,
  nushell,
  nu-lint,
  ...
}:
let
  toNuVar =
    name:
    if (!lib.strings.isValidPosixName name) then
      throw "toNuVar: ${name} is not a valid shell variable name"
    else
      value:
      if builtins.isAttrs value && !lib.strings.isStringLike value then
        throw "toNuVar: ${name} does not contain string-like values"
      else if builtins.isList value then
        "$env.${name} = (${lib.strings.escapeShellArgs value})"
      else
        "$env.${name} = '${lib.strings.escapeShellArg value}'";
in
{
  name,
  text,
  runtimeInputs ? [ ],
  runtimeEnv ? null,
  meta ? { },
  passthru ? { },
  checkPhase ? null,
  # excludeShellChecks ? [ ],
  # extraShellCheckFlags ? [ ],
  # bashOptions ? [
  #   "errexit"
  #   "nounset"
  #   "pipefail"
  # ],
  derivationArgs ? { },
  inheritPath ? true,
}@args:
writeTextFile {
  pos = builtins.unsafeGetAttrPos "name" args;
  inherit
    name
    meta
    passthru
    derivationArgs
    ;
  executable = true;
  destination = "/bin/${name}";
  allowSubstitutes = true;
  preferLocalBuild = false;
  # ${lib.concatMapStringsSep "\n" (option: "set -o ${option}") bashOptions}
  text = ''
    #!${lib.getExe nushell}
  ''
  + lib.optionalString (runtimeEnv != null) (lib.concatMapAttrsStringSep "\n" toNuVar runtimeEnv)
  + (lib.optionalString (runtimeInputs != [ ]) ''

    $env.PATH = "${lib.makeBinPath runtimeInputs}" | split row (char esep) ${lib.optionalString inheritPath "| append $env.PATH"}
  '')

  + ''

    ${text}
  '';

  checkPhase =
    if checkPhase == null then
      ''
        runHook preCheck
        # Does nushell perform 'dry-run' ??
        # NOTE; No shellcheck linting available for nushell
        ${lib.getExe nu-lint} "$target"
        runHook postCheck
      ''
    else
      checkPhase;
}
