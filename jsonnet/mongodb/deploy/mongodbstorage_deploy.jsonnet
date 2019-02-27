{
// mongodb deploy global variables
  _namespace:: "bigdata-jsonnet",
  _suiteprefix:: "pre1",
  _mountdevtype:: "CephFS",
  _utilsstoretype:: "ConfigMap",
  _mongodbinstancecount:: 3,
  _mongodbdatastoragesize:: "100Mi",
  _mongodblogstoragesize:: "100Mi",
  local storageprefix = $._suiteprefix,
  local cephfsbasename = ["mongodbutils"],
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
     _mname: storageprefix + "-mongodb" + mongodbnum + "data",
     _storagesize: $._mongodbdatastoragesize,
     _storagetype: "HostPath",
   } for mongodbnum in std.range(1,$._mongodbinstancecount)
  ] + [
   (import "../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: storageprefix + "-mongodb" + mongodbnum + "log",
     _storagesize: $._mongodblogstoragesize,
     _storagetype: "HostPath",
   } for mongodbnum in std.range(1,$._mongodbinstancecount)
  ],
}
