{ ... }:
{
  programs.nixfmt.enable = true;
  programs.deadnix.enable = true;
  programs.shellcheck.enable = true;
  programs.shfmt = {
    enable = true;
    # Setting option to 'null' configures formatter to follow .editorconfig
    indent_size = null;
  };
  # No builtin formatting for nushell scripts yet due to ALPHA stage
  # REF; https://github.com/numtide/treefmt-nix/pull/386
}
