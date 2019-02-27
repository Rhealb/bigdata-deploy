{
  // amahspark deploy global variables
  _amahsparkinstancecount:: 1,
  _sparkmasterinstancecount:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _amahsparkdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _amahsparkrequestcpu:: "0",
  _amahsparkrequestmem:: "0",
  _amahsparklimitcpu:: "0",
  _amahsparklimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _amahsparkexternalports:: [],
  _amahsparknodeports:: [],
  _amahsparkexservicetype:: "ClusterIP",
  _utilsstoretype:: "ConfigMap",
  _sparkmasterurl:: std.join(",", [$._suiteprefix + "-" + "master" + num + ":8080" for num in std.range(1, $._sparkmasterinstancecount)]),
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
  local externalamahports = $._amahsparkexternalports.amahports,

  local nodeamahports = $._amahsparknodeports.amahports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["sparkutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._amahsparkexservicetype != "None" then
  [
    (import "../amahsparkservice.jsonnet") + {
      // override amahsparkservice global variables
      _amahsparkprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahsparkprefix + "-" + super._mname + "-ex",
      _sname: self._amahsparkprefix + "-" + super._mname,
      _servicetype: $._amahsparkexservicetype,
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
    (import "../amahsparkservice.jsonnet") + {
      // override amahsparkservice global variables
      _amahsparkprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahsparkprefix + "-" + super._mname,
    }
  ] + [
    (import "../amahspark.jsonnet") + {
      // override amahspark global variables
      _amahsparkprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahsparkprefix + "-" + super._mname,
      _dockerimage: $._amahsparkdockerimage,
      _s3utilspath: self._amahsparkprefix + "-" + cephbasename[0],
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _replicacount: $._amahsparkinstancecount,
      _containerrequestcpu:: $._amahsparkrequestcpu,
      _containerrequestmem:: $._amahsparkrequestmem,
      _containerlimitcpu:: $._amahsparklimitcpu,
      _containerlimitmem:: $._amahsparklimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._amahsparkprefix,
        "BD_SPARK_MASTER_URL:" + $._sparkmasterurl,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/amahentrypoint.sh" ],
    }
  ],
}
