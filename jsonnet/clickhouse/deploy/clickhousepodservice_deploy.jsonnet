{
  // clickhouse deploy global variables
  _clickhouseinstancecount:: 1,
  _clickhousereplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _zkprefix:: "pre1",
  _zkinstancecount:: 3,
  _clickhousedockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _clickhouserequestcpu:: "0",
  _clickhouserequestmem:: "0",
  _clickhouselimitcpu:: "0",
  _clickhouselimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _clickhouseexternalports:: [],
  _clickhousenodeports:: [],
  _clickhouseexservicetype:: "ClusterIP",
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
  local externalport1s = $._clickhouseexternalports.port1s,
  local externalport2s = $._clickhouseexternalports.port2s,
  local externalport3s = $._clickhouseexternalports.port3s,

  local nodeport1s = $._clickhousenodeports.port1s,
  local nodeport2s = $._clickhousenodeports.port2s,
  local nodeport3s = $._clickhousenodeports.port3s,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["clickhouseutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._clickhouseexservicetype != "None" then
  [
    (import "../clickhouseservice.jsonnet") + {
      // override clickhouseservice global variables
      _clickhouseprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._clickhouseprefix + "-" + super._mname + num + "-ex",
      _sname: self._clickhouseprefix + "-" + super._mname + num,
      _servicetype: $._clickhouseexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "port1" + utils.addcolonforport(externalport1s[num - 1]) + ":8123",
        "port2" + utils.addcolonforport(externalport2s[num - 1]) + ":9000",
        "port3" + utils.addcolonforport(externalport3s[num - 1]) + ":9009",

      ],
      _nodeports: [
        "port1" + utils.addcolonforport(nodeport1s[num - 1]) + ":8123",
        "port2" + utils.addcolonforport(nodeport2s[num - 1]) + ":9000",
        "port3" + utils.addcolonforport(nodeport3s[num - 1]) + ":9009",

      ],
    } for num in std.range(1, $._clickhouseinstancecount)
  ]
  else
  []) + [
    (import "../clickhouseservice.jsonnet") + {
      // override clickhouseservice global variables
      _clickhouseprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._clickhouseprefix + "-" + super._mname + num,
    } for num in std.range(1, $._clickhouseinstancecount)
  ] + [
    (import "../clickhouse.jsonnet") + {
      // override clickhouse global variables
      _clickhouseprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._clickhouseprefix + "-" + super._mname + num,
      _dockerimage: $._clickhousedockerimage,
      _s3utilspath: self._clickhouseprefix + "-" + cephbasename[0],
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _replicacount: $._clickhousereplicas,
      _containerrequestcpu:: $._clickhouserequestcpu,
      _containerrequestmem:: $._clickhouserequestmem,
      _containerlimitcpu:: $._clickhouselimitcpu,
      _containerlimitmem:: $._clickhouselimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._clickhouseprefix,
        "SERVER_ID:" + self._mname,
        "BD_ZK_INSTANCE_COUNT:" + $._zkinstancecount,
        "BD_ZK_PREFIX:" + $._zkprefix,
      ],
      _volumemounts:: $._volumemountscommon + [
         storageprefix + "-" + "ch" + num + "data:/var/lib/clickhouse",
      ],
      _storages:: $._storagescommon + [
        storageprefix + "-" + "ch" + num + "data",
      ],
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for num in std.range(1, $._clickhouseinstancecount)
  ],
}
