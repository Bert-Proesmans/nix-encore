#!/usr/bin/env nix
#! nix shell nixpkgs#nushell --command nu

def first-existing []: list<string> -> string {
    where { $it | path exists } | first?
}

let ovmf_code = (
    $env.OVMF_CODE?
    | default (
        [
            "/usr/share/OVMF/OVMF_CODE.fd"
            "/usr/share/edk2/ovmf/OVMF_CODE.fd"
        ] | first-existing
    )
)

let ovmf_vars = (
    $env.OVMF_VARS?
		| default (
        [
            "/usr/share/OVMF/OVMF_VARS.fd"
            "/usr/share/edk2/ovmf/OVMF_VARS.fd"
        ] | first-existing
    )
)

# Construct a virtual machine and install a NixOS host
#
# This script sets up resources to do a virtual install of a nixos host configuration.
def main [
  machine: string # The moniker of the host configuration
  mode: string # What to do with a pre-existing disk image <clean|keep>.
] {
	let disk_image = $"($machine)-disk.raw"
	let efivars = $"($machine)-efivars.fd"

	match $mode {
		"clean" => {
			try {
				rm --force $disk_image $efivars
			} catch { error make "Failed removing the existing disk image" }
		}
		"keep" => {}
		_ => {
			error make $"invalid mode: ($mode) \(must be '(ansi green_bold)clean(ansi reset)' or '(ansi green_bold)keep(ansi reset)')"
		}
	}

	if not ($efivars | path exists) {
		print $"copying UEFI variables store template for ($machine)..."
		try {
			cp $ovmf_vars $efivars
			chmod +w $efivars
		} catch { error make "Failed copying/preparing EFI variables storage file" }
	}

	if not ($disk_image | path exists) {
		print $"building disko image generation script for ($machine)..."
		nom build --file systems.nix $"($machine).config.system.build.diskoImagesScript" -o tmp-disko-script

		print $"generating disk image for ($machine)..."
		let temp_pass = (mktemp)
		try {
			"x" | save --force $temp_pass
			./tmp-disko-script --pre-format-files $temp_pass /tmp/luks.secret
		} catch { error make "Failed saving password for disk encryption" }
		finally {
			rm --force $temp_pass tmp-disko-script
		}

		try {
			if ("main.raw" | path exists) {
				mv main.raw $disk_image
			} else if ("my-disk.raw" | path exists) {
				mv my-disk.raw $disk_image
			} else {
				let found = (
					ls *.raw
					| where name != $disk_image
					| get name
					| first?
				)

				if $found == null {
					error make "Generated disk image not found"
				}
				mv $found $disk_image
			}
		} catch { error make "Failed generating/formatting disk image" }
	}

	print $"booting ($machine) VM from ($disk_image)..."
	print "NOTE: To unlock the encrypted home partition, enter 'x' at the boot prompt in the QEMU window."

	let kvm = if ("/dev/kvm" | path exists) and ((test -w /dev/kvm | complete).exit_code == "0") {
			[
				"-enable-kvm"
				"-cpu"
				"host"
			]
		} else {
			print "warning: /dev/kvm is not writable. running without KVM acceleration."
			[
					"-cpu"
					"max"
			]
		}

	# ^qemu-system-x86_64 ...$kvm \
	# 	-m 2G \
	# 	-smp 2 \
	# 	-drive $"if=pflash,format=raw,unit=0,readonly=on,file=($ovmf_code)" \
	# 	-drive $"if=pflash,format=raw,unit=1,file=($efivars)" \
	# 	-drive $"file=($disk_image),if=virtio,format=raw" \
	# 	-net nic,model=virtio \
	# 	-net user,hostfwd=tcp::2222-:22 \
	# 	-vga virtio \
	# 	-display default,show-cursor=on &

	# loop {
	# 	let result = (do {
	# 		^ssh
	# 				-A
	# 				-F /dev/null
	# 				-o ConnectTimeout=7
	# 				-o StrictHostKeyChecking=no
	# 				-o UserKnownHostsFile=/dev/null
	# 				-p 2222
	# 				vorburger@127.0.0.1
	# 	} | complete)

	# 	if $result.exit_code == 0 {
	# 			break
	# 	}

	# 	sleep 1sec
	# }

}
