{
  // amahdruid deploy global variables
  _amahdruidinstancecount:: 1,
  _brokerinstancecount:: 1,
  _coordinatorinstancecount:: 1,
  _historicalinstancecount:: 1,
  _middlemanagerinstancecount:: 1,
  _overlordinstancecount:: 1,
  _amahdruidreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _amahdruiddockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _amahdruidrequestcpu:: "0",
  _amahdruidrequestmem:: "0",
  _amahdruidlimitcpu:: "0",
  _amahdruidlimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _amahdruidexternalports:: [],
  _amahdruidnodeports:: [],
  _amahdruidexservicetype:: "ClusterIP",
  _utilsstoretype:: "ConfigMap",
  _brokerservers::  $._suiteprefix + "-" + "broker" + ":8082",
  _coordinatorservers::  std.join(",", [$._suiteprefix + "-" + "coordinator" + zknum + ":8081" for zknum in std.range(1,$._coordinatorinstancecount)]),
  _overlordservers::  std.join(",", [$._suiteprefix + "-" + "overlord" + zknum + ":8090" for zknum in std.range(1,$._overlordinstancecount)]),
  _mysqlservers:: $._suiteprefix + "-" + "mysql1:3306",
  _mysqlpasswd:: "123456",
  _mysqlusername:: "root",
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
  local utils = import "../../../common/utils/utils.libsonnet",
  local externalamahports = $._amahdruidexternalports.amahports,

  local nodeamahports = $._amahdruidnodeports.amahports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["druidutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._amahdruidexservicetype != "None" then
  [
    (import "../amahdruidservice.jsonnet") + {
      // override amahdruidservice global variables
      _amahdruidprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahdruidprefix + "-" + super._mname + "-ex",
      _sname: self._amahdruidprefix + "-" + super._mname,
      _servicetype: $._amahdruidexservicetype,
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
    (import "../amahdruidservice.jsonnet") + {
      // override amahdruidservice global variables
      _amahdruidprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahdruidprefix + "-" + super._mname,
    }
  ] + [
    (import "../amahdruid.jsonnet") + {
      // override amahdruid global variables
      _amahdruidprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahdruidprefix + "-" + super._mname,
      _dockerimage: $._amahdruiddockerimage,
      _s3utilspath: self._amahdruidprefix + "-" + cephbasename[0],
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _replicacount: $._amahdruidreplicas,
      _containerrequestcpu:: $._amahdruidrequestcpu,
      _containerrequestmem:: $._amahdruidrequestmem,
      _containerlimitcpu:: $._amahdruidlimitcpu,
      _containerlimitmem:: $._amahdruidlimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._amahdruidprefix,
        "BD_BROKER_SERVERS:" + $._brokerservers,
        "BD_COORDINATOR_SERVERS:" + $._coordinatorservers,
        "BD_OVERLORD_SERVERS:" + $._overlordservers,
        "BD_MYSQL_SERVERS:" + $._mysqlservers,
        "BD_MYSQL_USERNAME:" + $._mysqlusername,
        "BD_MYSQL_PASSWD:" + $._mysqlpasswd,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/amahentrypoint.sh" ],
    }
  ],
}
