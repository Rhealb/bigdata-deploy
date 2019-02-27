{
  // hadoop deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local componentoramah = globalconf.hadoop.componentoramah,

  local hdfsstorages = (import "../hadoop/hdfs/deploy/hdfsstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local hdfs = globalconf.hadoop.hdfs,
    _utilsstoretype:: globalconf.utilsstoretype,
    _datadirstoragecount:: hdfs.datadirstoragecount,
    local namenode = hdfs.namenode,
    local journalnode = hdfs.journalnode,
    _datadirstoragesize:: hdfs.datadirpvcstoragesize,
    _specusestoragesize:: hdfs.specusepvcstoragesize,
    _nninstancecount:: namenode.instancecount,
    _jninstancecount:: journalnode.instancecount,
  },

  local hdfspodservice = (import "../hadoop/hdfs/deploy/hdfspodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _zkinstancecount:: globalconf.hadoop.zkinstancecount,
    _zkprefix:: globalconf.hadoop.zkprefix,
    _tmpdirstoragecount:: globalconf.hadoop.yarn.tmpdirstoragecount,
    local hdfs = globalconf.hadoop.hdfs,
    _initcontainerimage:: globalconf.initcontainerimage,
    _utilsstoretype:: globalconf.utilsstoretype,
    _datadirstoragecount:: hdfs.datadirstoragecount,
    _hdfsexservicetype:: hdfs.exservicetype,
    _hdfsnodeports:: hdfs.nodeports,
    local namenode = hdfs.namenode,
    local journalnode = hdfs.journalnode,
    local datanode = hdfs.datanode,
    _hdfsdockerimage:: hdfs.image,
    _externalports:: hdfs.externalports,
    _nninstancecount:: namenode.instancecount,
    _jninstancecount:: journalnode.instancecount,
    _dninstancecount:: datanode.instancecount,
    _nnrequestcpu:: namenode.requestcpu,
    _nnrequestmem:: namenode.requestmem,
    _nnlimitcpu:: namenode.limitcpu,
    _nnlimitmem:: namenode.limitmem,
    _jnrequestcpu:: journalnode.requestcpu,
    _jnrequestmem:: journalnode.requestmem,
    _jnlimitcpu:: journalnode.limitcpu,
    _jnlimitmem:: journalnode.limitmem,
    _dnrequestcpu:: datanode.requestcpu,
    _dnrequestmem:: datanode.requestmem,
    _dnlimitcpu:: datanode.limitcpu,
    _dnlimitmem:: datanode.limitmem,
  },

  local yarnstorages = (import "../hadoop/yarn/deploy/yarnstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    local yarn = globalconf.hadoop.yarn,
    _tmpdirstoragecount:: yarn.tmpdirstoragecount,
    _hostpathstoragesize:: yarn.hostpathpvcstoragesize,
    _rmtmpdirstoragesize:: yarn.rmtmpdirpvcstoragesize,
    _nmtmpdirstoragesize:: yarn.nmtmpdirpvcstoragesize,
  },

  local yarnpodservice = (import "../hadoop/yarn/deploy/yarnpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _zkinstancecount:: globalconf.hadoop.zkinstancecount,
    _zkprefix:: globalconf.hadoop.zkprefix,
    _jninstancecount:: globalconf.hadoop.hdfs.journalnode.instancecount,
    _datadirstoragecount:: globalconf.hadoop.hdfs.datadirstoragecount,
    local yarn = globalconf.hadoop.yarn,
    _initcontainerimage:: globalconf.initcontainerimage,
    _utilsstoretype:: globalconf.utilsstoretype,
    _tmpdirstoragecount:: yarn.tmpdirstoragecount,
    _yarnexservicetype:: yarn.exservicetype,
    _yarnnodeports:: yarn.nodeports,
    local resourcemanager = yarn.resourcemanager,
    local nodemanager = yarn.nodemanager,
    local mrjobhistory = yarn.mrjobhistory,
    _yarndockerimage:: yarn.image,
    _hostpathpvcstoragesize:: yarn.hostpathpvcstoragesize,
    _tmpdirpvcstoragesize:: yarn.tmpdirpvcstoragesize,
    _externalports:: yarn.externalports,
    _rminstancecount:: resourcemanager.instancecount,
    _nminstancecount:: nodemanager.instancecount,
    _mrjobhistoryinstancecount:: mrjobhistory.instancecount,
    _rmrequestcpu:: resourcemanager.requestcpu,
    _rmrequestmem:: resourcemanager.requestmem,
    _rmlimitcpu:: resourcemanager.limitcpu,
    _rmlimitmem:: resourcemanager.limitmem,
    _nmrequestcpu:: nodemanager.requestcpu,
    _nmrequestmem:: nodemanager.requestmem,
    _nmlimitcpu:: nodemanager.limitcpu,
    _nmlimitmem:: nodemanager.limitmem,
    _mrjobhistoryrequestcpu:: mrjobhistory.requestcpu,
    _mrjobhistoryrequestmem:: mrjobhistory.requestmem,
    _mrjobhistorylimitcpu:: mrjobhistory.limitcpu,
    _mrjobhistorylimitmem:: mrjobhistory.limitmem,
  },

  local amahhadoopstorages = (import "../hadoop/amah/deploy/amahhadoopstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local amahhadooppodservice = (import "../hadoop/amah/deploy/amahhadooppodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local amahhadoop = globalconf.hadoop.amah,
    _initcontainerimage:: globalconf.initcontainerimage,
    _monitor_cluster_type:: amahhadoop.monitor_cluster_type,
    _amahhadoopexservicetype:: amahhadoop.exservicetype,
    _amahhadoopdockerimage:: amahhadoop.image,
    _amahhadoopexternalports:: amahhadoop.externalports,
    _amahhadoopnodeports:: amahhadoop.nodeports,
    _amahhadoopinstancecount:: amahhadoop.instancecount,
    _amahhadooprequestcpu:: amahhadoop.requestcpu,
    _amahhadooprequestmem:: amahhadoop.requestmem,
    _amahhadooplimitcpu:: amahhadoop.limitcpu,
    _amahhadooplimitmem:: amahhadoop.limitmem,
  },
  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           if componentoramah == "amah" then
             amahhadoopstorages.items
           else
            //hdfsstorages.items + yarnstorages.items
            hdfsstorages.items
         else if deploytype == "podservice" then
           if componentoramah == "component" then
             //hdfspodservice.items + yarnpodservice.items
             hdfspodservice.items
           else if componentoramah == "amah" then
             amahhadooppodservice.items
           else if componentoramah == "both" then
             //hdfspodservice.items + yarnpodservice.items + amahhadooppodservice.items
             hdfspodservice.items + amahhadooppodservice.items
         else
            error "Unknow componentoramah type"
        else
          error "Unknow deploytype",
}
