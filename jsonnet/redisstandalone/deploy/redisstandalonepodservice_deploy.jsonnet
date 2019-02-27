{
  // redisstandalone deploy global variables
  _redisstandaloneinstancecount:: 1,
  _redisstandalonereplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _redisstandalonedockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _redisstandalonerequestcpu:: "0",
  _redisstandalonerequestmem:: "0",
  _redisstandalonelimitcpu:: "0",
  _redisstandalonelimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _redisstandaloneexternalports:: [],
  _redisstandalonenodeports:: [],
  _redisstandaloneexservicetype:: "ClusterIP",
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
  local externalhttpports = $._redisstandaloneexternalports.httpports,

  local nodehttpports = $._redisstandalonenodeports.httpports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["redisstandaloneutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._redisstandaloneexservicetype != "None" then
  [
    (import "../redisstandaloneservice.jsonnet") + {
      // override redisstandaloneservice global variables
      _redisstandaloneprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._redisstandaloneprefix + "-" + super._mname + num + "-ex",
      _sname: self._redisstandaloneprefix + "-" + super._mname + num,
      _servicetype: $._redisstandaloneexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "httpport" + utils.addcolonforport(externalhttpports[num - 1]) + ":6379",

      ],
      _nodeports: [
        "httpport" + utils.addcolonforport(nodehttpports[num - 1]) + ":6379",

      ],
    } for num in std.range(1, $._redisstandaloneinstancecount)
  ]
  else
  []) + [
    (import "../redisstandaloneservice.jsonnet") + {
      // override redisstandaloneservice global variables
      _redisstandaloneprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._redisstandaloneprefix + "-" + super._mname + num,
    } for num in std.range(1, $._redisstandaloneinstancecount)
  ] + [
    (import "../redisstandalone.jsonnet") + {
      // override redisstandalone global variables
      _redisstandaloneprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._redisstandaloneprefix + "-" + super._mname + num,
      _dockerimage: $._redisstandalonedockerimage,
      _s3utilspath: self._redisstandaloneprefix + "-" + cephbasename[0],
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _replicacount: $._redisstandalonereplicas,
      _containerrequestcpu:: $._redisstandalonerequestcpu,
      _containerrequestmem:: $._redisstandalonerequestmem,
      _containerlimitcpu:: $._redisstandalonelimitcpu,
      _containerlimitmem:: $._redisstandalonelimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._redisstandaloneprefix,
      ],
      _volumemounts:: $._volumemountscommon + [
                        storageprefix + "-" + "redisdata:/data",
                      ],
      _storages:: $._storagescommon + [
                    storageprefix + "-" + "redisdata",
                  ],
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for num in std.range(1, $._redisstandaloneinstancecount)
  ],
}
