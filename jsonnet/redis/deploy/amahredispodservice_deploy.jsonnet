{
  // amahredis deploy global variables
  _amahredisinstancecount:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _redisurls:: $._suiteprefix + "-" + "redis" + ":6379",
  _amahredisdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _amahredisrequestcpu:: "0",
  _amahredisrequestmem:: "0",
  _amahredislimitcpu:: "0",
  _amahredislimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _amahredisexternalports:: [],
  _amahredisnodeports:: [],
  _amahredisexservicetype:: "ClusterIP",
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
  local externalamahports = $._amahredisexternalports.amahports,

  local nodeamahports = $._amahredisnodeports.amahports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["redisutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._amahredisexservicetype != "None" then
  [
    (import "../amahredisservice.jsonnet") + {
      // override amahredisservice global variables
      _amahredisprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahredisprefix + "-" + super._mname + "-ex",
      _sname: self._amahredisprefix + "-" + super._mname,
      _servicetype: $._amahredisexservicetype,
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
    (import "../amahredisservice.jsonnet") + {
      // override amahredisservice global variables
      _amahredisprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahredisprefix + "-" + super._mname,
    }
  ] + [
    (import "../amahredis.jsonnet") + {
      // override amahredis global variables
      _amahredisprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahredisprefix + "-" + super._mname,
      _dockerimage: $._amahredisdockerimage,
      _s3utilspath: self._amahredisprefix + "-" + cephbasename[0],
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _replicacount: $._amahredisinstancecount,
      _containerrequestcpu:: $._amahredisrequestcpu,
      _containerrequestmem:: $._amahredisrequestmem,
      _containerlimitcpu:: $._amahredislimitcpu,
      _containerlimitmem:: $._amahredislimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._amahredisprefix,
        "BD_REDIS_SERVERS:" + $._redisurls,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/amahentrypoint.sh" ],
    }
  ],
}
