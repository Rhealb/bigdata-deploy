{
// redisstandalone deploy global variables
  _namespace:: "bigdata-jsonnet",
  _suiteprefix:: "pre1",
  _redisdatastoragesize:: "5Gi",
  _mountdevtype:: "CephFS",
  _utilsstoretype:: "ConfigMap",
  local storageprefix = $._suiteprefix,
  local cephfsbasename = ["redisstandaloneutils"],
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
     _mname: storageprefix + "-redisdata",
     _storagesize: $._redisdatastoragesize,
     _storagetype: "HostPath",
   }
  ],
}
