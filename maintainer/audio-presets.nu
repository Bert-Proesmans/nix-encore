#!/usr/bin/env nix
#! nix shell --impure --expr ``
#! nix with import <nixpkgs> {};
#! nix [nushell curl innoextract git (python3.withPackages (ps: with ps; [numpy scipy]))]
#! nix ``
#! nix --command nu


print "Starting the Audio driver to EasyEffects extraction pipeline..."

let tmp_dir = mktemp --directory --tmpdir "audio-extract-XXXX"
print $"\nTemporary workspace at: ($tmp_dir)"
cd $tmp_dir

# ERROR; There is nothing to extract from the Senary driver that is useful to us for tuning on Linux.
# Lenovo ThinkPad L14 Gen 5
# curl --location https://download.lenovo.com/pccbbs/mobiles/r2ha514w.exe --output r2ha514w.exe
# Lenovo ThinkPad L14 Gen 6
# curl --location https://download.lenovo.com/pccbbs/mobiles/r2ua307w.exe --output r2ua307w.exe

nu

# REF; https://github.com/shuhaowu/linux-thinkpad-speaker-improvements
#	-- requires windows install to compare and create a signal modulation kernel
# REF; https://github.com/mister2d/thinkpad-linux-audio
#	-- requires a driver that has embedded dolby software EQ tuning to create signal modulation kernel
