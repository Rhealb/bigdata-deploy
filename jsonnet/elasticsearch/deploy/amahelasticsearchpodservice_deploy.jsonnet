{
  // amahelasticsearch deploy global variables
  _amahelasticsearchinstancecount:: 1,
  _amahelasticsearchreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _esclienturl:: $._suiteprefix + "-esclient-ex:9200",
  _amahelasticsearchdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _amahelasticsearchrequestcpu:: "0",
  _amahelasticsearchrequestmem:: "0",
  _amahelasticsearchlimitcpu:: "0",
  _amahelasticsearchlimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _amahelasticsearchexternalports:: [],
  _amahelasticsearchnodeports:: [],
  _amahelasticsearchexservicetype:: "ClusterIP",
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
  local externalamahports = $._amahelasticsearchexternalports.amahports,

  local nodeamahports = $._amahelasticsearchnodeports.amahports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["esutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._amahelasticsearchexservicetype != "None" then
  [
    (import "../amahelasticsearchservice.jsonnet") + {
      // override amahelasticsearchservice global variables
      _amahelasticsearchprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahelasticsearchprefix + "-" + super._mname + "-ex",
      _sname: self._amahelasticsearchprefix + "-" + super._mname,
      _servicetype: $._amahelasticsearchexservicetype,
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
    (import "../amahelasticsearchservice.jsonnet") + {
      // override amahelasticsearchservice global variables
      _amahelasticsearchprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahelasticsearchprefix + "-" + super._mname,
    }
  ] + [
    (import "../amahelasticsearch.jsonnet") + {
      // override amahelasticsearch global variables
      _amahelasticsearchprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahelasticsearchprefix + "-" + super._mname,
      _dockerimage: $._amahelasticsearchdockerimage,
      _s3utilspath: self._amahelasticsearchprefix + "-" + cephbasename[0],
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _replicacount: $._amahelasticsearchreplicas,
      _containerrequestcpu:: $._amahelasticsearchrequestcpu,
      _containerrequestmem:: $._amahelasticsearchrequestmem,
      _containerlimitcpu:: $._amahelasticsearchlimitcpu,
      _containerlimitmem:: $._amahelasticsearchlimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._amahelasticsearchprefix,
        "BD_ESCLIENT_SERVER:" + $._esclienturl,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/amahentrypoint.sh" ],
    }
  ],
}
