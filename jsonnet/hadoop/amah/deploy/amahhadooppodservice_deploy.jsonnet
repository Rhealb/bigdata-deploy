{
  // amahhadoop deploy global variables
  _amahhadoopinstancecount:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _amahhadoopdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _amahhadooprequestcpu:: "0",
  _amahhadooprequestmem:: "0",
  _amahhadooplimitcpu:: "0",
  _amahhadooplimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _amahhadoopexternalports:: [],
  _amahhadoopnodeports:: [],
  _amahhadoopexservicetype:: "ClusterIP",
  _utilsstoretype:: "ConfigMap",
  _hdfsurls:: std.join(",", [$._suiteprefix + "-" + "namenode" + num + ":50070" for num in std.range(1,2)]),
  _yarnurls:: std.join(",", [$._suiteprefix + "-" + "resourcemanager" + num + ":8088" for num in std.range(1,2)]),
  _monitor_cluster_type:: "hadoop",
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
  local externalamahports = $._amahhadoopexternalports.amahports,

  local nodeamahports = $._amahhadoopnodeports.amahports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["hadooputils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._amahhadoopexservicetype != "None" then
  [
    (import "../amahhadoopservice.jsonnet") + {
      // override amahhadoopservice global variables
      _amahhadoopprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahhadoopprefix + "-" + super._mname + "-ex",
      _sname: self._amahhadoopprefix + "-" + super._mname,
      _servicetype: $._amahhadoopexservicetype,
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
    (import "../amahhadoopservice.jsonnet") + {
      // override amahhadoopservice global variables
      _amahhadoopprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahhadoopprefix + "-" + super._mname,
    }
  ] + [
    (import "../amahhadoop.jsonnet") + {
      // override amahhadoop global variables
      _amahhadoopprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahhadoopprefix + "-" + super._mname,
      _dockerimage: $._amahhadoopdockerimage,
      _s3utilspath: self._amahhadoopprefix + "-" + cephbasename[0],
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _replicacount: $._amahhadoopinstancecount,
      _containerrequestcpu:: $._amahhadooprequestcpu,
      _containerrequestmem:: $._amahhadooprequestmem,
      _containerlimitcpu:: $._amahhadooplimitcpu,
      _containerlimitmem:: $._amahhadooplimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._amahhadoopprefix,
        "BD_HDFS_URL:" + $._hdfsurls,
        "BD_YARN_URL:" + $._yarnurls,
        "BD_MONITOR_CLUSTER_TYPE:" + $._monitor_cluster_type,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/amahentrypoint.sh" ],
    }
  ],
}
