{
  // amahmongodb deploy global variables
  _amahmongodbinstancecount:: 1,
  _mongodbinstancecount:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _amahmongodbdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _amahmongodbrequestcpu:: "0",
  _amahmongodbrequestmem:: "0",
  _amahmongodblimitcpu:: "0",
  _amahmongodblimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _amahmongodbexternalports:: [],
  _amahmongodbnodeports:: [],
  _amahmongodbexservicetype:: "ClusterIP",
  _utilsstoretype:: "ConfigMap",
  _mongodburl:: std.join(",", [$._suiteprefix + "-" + "mongodb" + num + ":27017" for num in std.range(1, $._mongodbinstancecount)]),
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
  local externalamahports = $._amahmongodbexternalports.amahports,

  local nodeamahports = $._amahmongodbnodeports.amahports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["mongodbutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._amahmongodbexservicetype != "None" then
  [
    (import "../amahmongodbservice.jsonnet") + {
      // override amahmongodbservice global variables
      _amahmongodbprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahmongodbprefix + "-" + super._mname + "-ex",
      _sname: self._amahmongodbprefix + "-" + super._mname,
      _servicetype: $._amahmongodbexservicetype,
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
    (import "../amahmongodbservice.jsonnet") + {
      // override amahmongodbservice global variables
      _amahmongodbprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahmongodbprefix + "-" + super._mname,
    }
  ] + [
    (import "../amahmongodb.jsonnet") + {
      // override amahmongodb global variables
      _amahmongodbprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahmongodbprefix + "-" + super._mname,
      _dockerimage: $._amahmongodbdockerimage,
      _s3utilspath: self._amahmongodbprefix + "-" + cephbasename[0],
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _replicacount: $._amahmongodbinstancecount,
      _containerrequestcpu:: $._amahmongodbrequestcpu,
      _containerrequestmem:: $._amahmongodbrequestmem,
      _containerlimitcpu:: $._amahmongodblimitcpu,
      _containerlimitmem:: $._amahmongodblimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._amahmongodbprefix,
        "BD_MONGO_URL:" + $._mongodburl,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/amahentrypoint.sh" ],
    }
  ],
}
