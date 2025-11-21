{ lock }:
let
  loaded = builtins.fromJSON (builtins.readFile lock);

  optional = pred: elem: if pred then [ elem ] else [];

  refetch = locked: let
    badAttrs = [ "lastModified" "narHash" "revCount" ] ++ optional (locked.type == "git") "dir";
    locked' = builtins.removeAttrs locked badAttrs;
  in builtins.fetchTree locked';
in {
  res = builtins.listToAttrs (builtins.filter (x: x != null) (map (name: let
    locked = loaded.nodes.${name}.locked;

    refetched = refetch locked;
  in if name == "root" || refetched.narHash == locked.narHash
     then null
     else {
       inherit name;
       value = { inherit locked refetched; };
     }) (builtins.attrNames loaded.nodes)));
}
