#!/usr/bin/env nix
#! nix shell nixpkgs#nushell nixpkgs#nixos-anywhere --command nu
# NOTE; Bash (runtimeShell) is implicit

# Fragments of ssh connection string that indicate the target host is local to the build host.
# Used to skip substituting packages from online cache.
let local_targets = ["localhost", "127.0.0.1", "192.168.", ".local"]

# Deploy a nixos host configuration to a (virtual) machine.
#
# <TODO>
def main [] {
	print "main"
}

def "main update" [
	name: string # The moniker of the host configuration
	ssh_target?: string # Optional SSH connection string
	--debug # Enable nixos-rebuild debug output
] {
	print "update"

	let ssh_target = if $ssh_target == null {
		input "What is the ssh connection string? "
	} else {
		$ssh_target
	}
	let extra_args = [
		(if $debug { "--debug" } else { null }),
		"--no-reexec", "--no-flake", "--elevate=sudo", "--ask-elevate-password",
	] | compact --empty

	with-env {} {
		nixos-rebuild --file systems.nix --attr $name --target-host $ssh_target ...$extra_args switch
	}
}

def "main vm" [
	name: string # The moniker of the host configuration
] {
	print "vm"

	let extra_args = [
		["--debug"]
	] | flatten

	with-env {} {
		nixos-rebuild --file systems.nix --attr $name ...$extra_args build-vm
		# NOTE; You'll have to manually launch the vm scriptwrapper for now
	}
}

def "main install" [
	name: string # The moniker of the host configuration
] {
  print "install"

	# WARN; Footgun!!
	# If you pipe external command output directly into other commandlets the error code of the external
	# program is swallowed!
	let build_result = (
		let format_installable = $"($name).config.system.build.diskoScript";
		let toplevel_installable = $"($name).config.system.build.toplevel";
		nix build --no-link --print-out-paths --file systems.nix $format_installable $toplevel_installable | complete
	)

	if $build_result.exit_code != 0 {
		print -e $build_result.stderr # Must print stderr since I/O has been swallowed
		error make { msg: $"Nix build failed with exit code ($build_result.exit_code)" }
	}

	# SAFETY; Nix paths are not supposed to have spaces in them!
	let paths = ($build_result.stdout | lines | str join ' ')
	print $paths

	let ssh_target = (input "What is the ssh connection string? ")
	let disk_one_secret = (prompt-confirmed-secret)
	let extra_args = [
		["--debug"]

		(if ($local_targets | any {|it| $ssh_target | str contains $it }) {
      ["--no-substitute-on-destination"]
    } else {
      []
    })

	] | flatten

	with-env {
		DISK1_PASSWORD: $disk_one_secret
    STORE_PATHS: $paths
    SSH_TARGET: $ssh_target
		} {
			# PRECONDITION; Nix paths are not supposed to have spaces in them!
			# NOTE; Do not 'set -x' before the command because the contents of the subshell are printed
			bash --noprofile -c 'nixos-anywhere "$@" --disk-encryption-keys /tmp/disk1.key <(printf "%s" "$DISK1_PASSWORD") --store-paths $STORE_PATHS "$SSH_TARGET"' ...$extra_args
  }
}

def prompt-confirmed-secret [] {
  let a = (input --suppress-output "disk password: ")
  let b = (input --suppress-output "confirm disk password: ")

  if $a != $b {
    error make { msg: "passwords do not match" }
  }

  $a
}
