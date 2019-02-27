{
// redis deploy global variables
  _namespace:: "bigdata-jsonnet",
  _redisinstancecount:: 1,
  _suiteprefix:: "pre1",
  _mountdevtype:: "CephFS",
  _utilsstoretype:: "ConfigMap",
  _redisdatastoragesize:: "1Gi",
  local storageprefix = $._suiteprefix,
  local cephfsbasename = ["redisutils"],
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
     _mname: storageprefix + "-redisdata-master-" + redisnum,
     _storagesize: $._redisdatastoragesize,
     _storagetype: "HostPath",
   } for redisnum in std.range(1, $._redisinstancecount)
  ] + [
   (import "../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: storageprefix + "-redisdata-slave-" + redisnum,
     _storagesize: $._redisdatastoragesize,
     _storagetype: "HostPath",
   } for redisnum in std.range(1, $._redisinstancecount)
  ],
}
