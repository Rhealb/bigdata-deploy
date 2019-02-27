{
  // plyql deploy global variables
  _plyqlinstancecount:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _plyqldockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _plyqlrequestcpu:: "0",
  _plyqlrequestmem:: "0",
  _plyqllimitcpu:: "0",
  _plyqllimitmem:: "0",
  _druidprefix:: "pre1",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _externalports::{
    mysqlgatewayports:: [],
  },
  _plyqlnodeports::{
    mysqlgatewayports:: [],
  },
  _plyqlexservicetype:: "ClusterIP",
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
  local utils = import "../../../common/utils/utils.libsonnet",
  local externalmysqlgatewayports = $._externalports.mysqlgatewayports,
  local nodemysqlgatewayports = $._plyqlnodeports.mysqlgatewayports,
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["plyqlutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._plyqlexservicetype != "None" then
  [
    (import "../plyqlservice.jsonnet") + {
      // override plyqlservice global variables
      _plyqlprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._plyqlprefix + "-" + super._mname + "-ex",
      _sname: self._plyqlprefix + "-" + super._mname,
      _servicetype: $._plyqlexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "mysqlgatewayport" + utils.addcolonforport(externalmysqlgatewayports[0]) + ":3306",
      ],
      _nodeports: [
        "mysqlgatewayport" + utils.addcolonforport(nodemysqlgatewayports[0]) + ":3306",
      ],
    },
  ]
  else
  []) + [
    (import "../plyqlservice.jsonnet") + {
      // override plyqlservice global variables
      _plyqlprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._plyqlprefix + "-" + super._mname,
    },
  ] + [
    (import "../plyql.jsonnet") + {
      // override plyql global variables
      _plyqlprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._plyqlprefix + "-" + super._mname,
      _dockerimage: $._plyqldockerimage,
      _s3utilspath: self._plyqlprefix + "-" + cephbasename[0],
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _replicacount: $._plyqlinstancecount,
      _containerrequestcpu:: $._plyqlrequestcpu,
      _containerrequestmem:: $._plyqlrequestmem,
      _containerlimitcpu:: $._plyqllimitcpu,
      _containerlimitmem:: $._plyqllimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._plyqlprefix,
        "BD_DRUID_PREFIX:" + $._druidprefix,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    },
  ],
}
