{
  // amahhbase deploy global variables
  _amahhbaseinstancecount:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _zknum:: 3,
  _hbasemasterinstancecount:: 1,
  _hbasemasterurls:: std.join(",", [$._suiteprefix + "-" + "hmaster" + hmnum + ":16010" for hmnum in std.range(1,$._hbasemasterinstancecount)]),
  _amahhbasedockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _amahhbaserequestcpu:: "0",
  _amahhbaserequestmem:: "0",
  _amahhbaselimitcpu:: "0",
  _amahhbaselimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _amahhbaseexternalports:: [],
  _amahhbasenodeports:: [],
  _amahhbaseexservicetype:: "ClusterIP",
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
  local externalamahports = $._amahhbaseexternalports.amahports,

  local nodeamahports = $._amahhbasenodeports.amahports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["hbaseutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._amahhbaseexservicetype != "None" then
  [
    (import "../amahhbaseservice.jsonnet") + {
      // override amahhbaseservice global variables
      _amahhbaseprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahhbaseprefix + "-" + super._mname + "-ex",
      _sname: self._amahhbaseprefix + "-" + super._mname,
      _servicetype: $._amahhbaseexservicetype,
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
    (import "../amahhbaseservice.jsonnet") + {
      // override amahhbaseservice global variables
      _amahhbaseprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahhbaseprefix + "-" + super._mname,
    }
  ] + [
    (import "../amahhbase.jsonnet") + {
      // override amahhbase global variables
      _amahhbaseprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahhbaseprefix + "-" + super._mname,
      _dockerimage: $._amahhbasedockerimage,
      _s3utilspath: self._amahhbaseprefix + "-" + cephbasename[0],
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _replicacount: $._amahhbaseinstancecount,
      _containerrequestcpu:: $._amahhbaserequestcpu,
      _containerrequestmem:: $._amahhbaserequestmem,
      _containerlimitcpu:: $._amahhbaselimitcpu,
      _containerlimitmem:: $._amahhbaselimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._amahhbaseprefix,
        "BD_HBASE_MASTER_SERVERS:" + $._hbasemasterurls,
      ] + [
        "ZKNAME:" + std.join(",", [
          self._amahhbaseprefix + "-" + "zookeeper" + zknum + ":2181"
            for zknum in std.range(1,$._zknum)
        ])
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/amahentrypoint.sh" ],
    }
  ],
}
