{
// clickhouse deploy global variables
  _namespace:: "bigdata-jsonnet",
  _suiteprefix:: "pre1",
  _mountdevtype:: "CephFS",
  _utilsstoretype:: "ConfigMap",
  _clickhouseinstancecount:: 3,
  local storageprefix = $._suiteprefix,
  local cephfsbasename = ["clickhouseutils"],
  local cephfsstoragesize = ["1Mi"],
  local cephfsstoragename=[storageprefix + "-" + name for name in cephfsbasename],

  kind: "List",
  apiVersion: "v1",
  items: (if $._utilsstoretype == "FS" then
  [
   (import "../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: cephfsstoragename[storagenum],
     _storagesize: cephfsstoragesize[storagenum],
     _storagetype: $._mountdevtype,
   } for storagenum in std.range(0, std.length(cephfsstoragename) - 1)
  ]
  else
  []) + [
   (import "../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: storageprefix + "-ch" + chnum + "data",
     _storagesize: "10Gi",
     _storagetype: "HostPath",
   } for chnum in std.range(1,$._clickhouseinstancecount)
  ],
}
