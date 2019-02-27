{
  // amahclickhouse deploy global variables
  _amahclickhouseinstancecount:: 1,
  _amahclickhousereplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _clickhouseinstancecount:: 1,
  _clickhouseurls:: std.join(",", [ "jdbc:clickhouse://" + $._suiteprefix + "-" + "clickhouse" + zknum + ":8123/system" for zknum in std.range(1,$._clickhouseinstancecount)]),
  _clickhouseusers:: std.join(",",["" for zknum in std.range(1,$._clickhouseinstancecount)]),
  _clickhousepasswords:: std.join(",",["" for zknum in std.range(1,$._clickhouseinstancecount)]),
  _amahclickhousedockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _amahclickhouserequestcpu:: "0",
  _amahclickhouserequestmem:: "0",
  _amahclickhouselimitcpu:: "0",
  _amahclickhouselimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _amahclickhouseexternalports:: [],
  _amahclickhousenodeports:: [],
  _amahclickhouseexservicetype:: "ClusterIP",
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
  local externalhttpports = $._amahclickhouseexternalports.httpports,

  local nodehttpports = $._amahclickhousenodeports.httpports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["clickhouseutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._amahclickhouseexservicetype != "None" then
  [
    (import "../amahclickhouseservice.jsonnet") + {
      // override amahclickhouseservice global variables
      _amahclickhouseprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahclickhouseprefix + "-" + super._mname + num + "-ex",
      _sname: self._amahclickhouseprefix + "-" + super._mname + num,
      _servicetype: $._amahclickhouseexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "httpport" + utils.addcolonforport(externalhttpports[num - 1]) + ":8084",

      ],
      _nodeports: [
        "httpport" + utils.addcolonforport(nodehttpports[num - 1]) + ":8084",

      ],
    } for num in std.range(1, $._amahclickhouseinstancecount)
  ]
  else
  []) + [
    (import "../amahclickhouseservice.jsonnet") + {
      // override amahclickhouseservice global variables
      _amahclickhouseprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahclickhouseprefix + "-" + super._mname + num,
    } for num in std.range(1, $._amahclickhouseinstancecount)
  ] + [
    (import "../amahclickhouse.jsonnet") + {
      // override amahclickhouse global variables
      _amahclickhouseprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahclickhouseprefix + "-" + super._mname + num,
      _dockerimage: $._amahclickhousedockerimage,
      _s3utilspath: self._amahclickhouseprefix + "-" + cephbasename[0],
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _replicacount: $._amahclickhousereplicas,
      _containerrequestcpu:: $._amahclickhouserequestcpu,
      _containerrequestmem:: $._amahclickhouserequestmem,
      _containerlimitcpu:: $._amahclickhouselimitcpu,
      _containerlimitmem:: $._amahclickhouselimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._amahclickhouseprefix,
        "BD_CLICKHOUSE_SERVERS:" + $._clickhouseurls,
        "BD_CLICKHOUSE_USERS:" + $._clickhouseusers,
        "BD_CLICKHOUSE_PASSWORDS:" + $._clickhousepasswords,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/amahentrypoint.sh" ],
    } for num in std.range(1, $._amahclickhouseinstancecount)
  ],
}
