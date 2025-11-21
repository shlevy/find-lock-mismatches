{ writeShellApplication, coreutils }: writeShellApplication {
  name = "find-lock-mismatches";

  runtimeInputs = [ coreutils ];

  text = ''
    if [ "$#" -ne 1 ]; then
      echo "USAGE: $0 LOCKFILE" >&2
      exit 1
    fi
    readonly lockfile="$1"

    function cleanup() {
      if [ -n "$tmp" ]; then
        chmod --recursive +w "$tmp"
        rm --force --recursive "$tmp"
      fi
    }
    tmp="$(mktemp --directory --tmpdir find-lock-mismatches.XXX)"
    trap cleanup EXIT

    mkdir "$tmp"/store
    HOME="$tmp" nix eval --file ${./find-lock-mismatches.nix} --arg lock "$(realpath "$lockfile")" --json --store "$(realpath "$tmp")"/store res
  '';
}
