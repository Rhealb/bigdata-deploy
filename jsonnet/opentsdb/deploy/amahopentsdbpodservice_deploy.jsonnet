{
  // amahopentsdb deploy global variables
  _amahopentsdbinstancecount:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _opentsdburls:: $._suiteprefix + "-" + "opentsdb" + ":4242",
  _amahopentsdbdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _amahopentsdbrequestcpu:: "0",
  _amahopentsdbrequestmem:: "0",
  _amahopentsdblimitcpu:: "0",
  _amahopentsdblimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _amahopentsdbexternalports:: [],
  _amahopentsdbnodeports:: [],
  _amahopentsdbexservicetype:: "ClusterIP",
  _utilsstoretype:: "ConfigMap",
  _initcontainerimage:: "",
  _volumemountscommon:: if $._utilsstoretype == "ConfigMap" then
                          [
                            "utilsconf:/opt/mntcephutils/conf:true",
                            "utilsentry:/opt/mntcephutils/entry:true",
                            "utilsscripts:/opt/mntcephutils/scripts:true",
                          ]
                        else if $._utilsstoretype == "FS" then
                          [
                            cephstoragename[0] + ":/opt/mntcephutils:true",
                          ]
                        else if $._utilsstoretype == "S3" then
                          [
                            "s3utils:/opt/mntcephutils",
                          ]
                        else
                          [],
  _storagescommon:: if $._utilsstoretype == "ConfigMap" then
                      []
                    else if $._utilsstoretype == "FS" then
                      [
                        cephstoragename[0],
                      ]
                    else if $._utilsstoretype == "S3" then
                      []
                    else
                      [],
  _volumescommon:: if $._utilsstoretype == "ConfigMap" then
                     [
                       "utilsconf:configMap:" + storageprefix + "-" + cephbasename[0] + "-conf",
                       "utilsentry:configMap:" + storageprefix + "-" + cephbasename[0] + "-entry",
                       "utilsscripts:configMap:" + storageprefix + "-" + cephbasename[0] + "-scripts",
                     ]
                   else if $._utilsstoretype == "FS" then
                     []
                   else if $._utilsstoretype == "S3" then
                     ["s3utils:emptyDir"]
                   else
                     [],
  local utils = import "../../common/utils/utils.libsonnet",
  local externalamahports = $._amahopentsdbexternalports.amahports,

  local nodeamahports = $._amahopentsdbnodeports.amahports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["opentsdbutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._amahopentsdbexservicetype != "None" then
  [
    (import "../amahopentsdbservice.jsonnet") + {
      // override amahopentsdbservice global variables
      _amahopentsdbprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahopentsdbprefix + "-" + super._mname + "-ex",
      _sname: self._amahopentsdbprefix + "-" + super._mname,
      _servicetype: $._amahopentsdbexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "amahport" + utils.addcolonforport(externalamahports[0]) + ":8084",

      ],
      _nodeports: [
        "amahport" + utils.addcolonforport(nodeamahports[0]) + ":8084",

      ],
    }
  ]
  else
  []) + [
    (import "../amahopentsdbservice.jsonnet") + {
      // override amahopentsdbservice global variables
      _amahopentsdbprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahopentsdbprefix + "-" + super._mname,
    }
  ] + [
    (import "../amahopentsdb.jsonnet") + {
      // override amahopentsdb global variables
      _amahopentsdbprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahopentsdbprefix + "-" + super._mname,
      _dockerimage: $._amahopentsdbdockerimage,
      _s3utilspath: self._amahopentsdbprefix + "-" + cephbasename[0],
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _replicacount: $._amahopentsdbinstancecount,
      _containerrequestcpu:: $._amahopentsdbrequestcpu,
      _containerrequestmem:: $._amahopentsdbrequestmem,
      _containerlimitcpu:: $._amahopentsdblimitcpu,
      _containerlimitmem:: $._amahopentsdblimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._amahopentsdbprefix,
        "BD_OPENTSDB_SERVERS:" + $._opentsdburls,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/amahentrypoint.sh" ],
    }
  ],
}
