{
  // spark deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,
  local componentoramah = globalconf.spark.componentoramah,

  local sparkstorages = (import "../spark/deploy/sparkstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local spark = globalconf.spark,
    _utilsstoretype:: globalconf.utilsstoretype,
    _workerworkdirstoragesize:: spark.workerworkdirpvcstoragesize,
    _localdirstoragesize:: spark.localdirpvcstoragesize,
  },

  local sparkpodservice = (import "../spark/deploy/sparkpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _zkinstancecount:: globalconf.spark.zkinstancecount,
    _zkprefix:: globalconf.spark.zkprefix,
    _hadoopprefix:: globalconf.spark.hadoopprefix,
    _jninstancecount:: globalconf.hadoop.hdfs.journalnode.instancecount,
    local spark = globalconf.spark,
    local master = spark.master,
    local worker = spark.worker,
    local historyserver = spark.historyserver,
    _initcontainerimage:: globalconf.initcontainerimage,
    _utilsstoretype:: globalconf.utilsstoretype,
    _sparkdockerimage:: spark.image,
    _sparkexservicetype:: spark.exservicetype,
    _externalports:: spark.externalports,
    _sparknodeports:: spark.nodeports,
    _masterinstancecount:: master.instancecount,
    _workerinstancecount:: worker.instancecount,
    _historyserverinstancecount:: historyserver.instancecount,
    _masterrequestcpu:: master.requestcpu,
    _masterrequestmem:: master.requestmem,
    _masterlimitcpu:: master.limitcpu,
    _masterlimitmem:: master.limitmem,
    _workerrequestcpu:: worker.requestcpu,
    _workerrequestmem:: worker.requestmem,
    _workerlimitcpu:: worker.limitcpu,
    _workerlimitmem:: worker.limitmem,
    _sparkworkercores:: worker.sparkworkercores,
    _historyserverrequestcpu:: historyserver.requestcpu,
    _historyserverrequestmem:: historyserver.requestmem,
    _historyserverlimitcpu:: historyserver.limitcpu,
    _historyserverlimitmem:: historyserver.limitmem,
    _sparkeventlogdir:: historyserver.sparkeventlogdir,
    _cephhostports:: ceph.hostports,
  },

  local amahsparkstorages = (import "../spark/deploy/amahsparkstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local amahsparkpodservice = (import "../spark/deploy/amahsparkpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    _sparkmasterinstancecount:: globalconf.spark.master.instancecount,
    local amahspark = globalconf.spark.amah,
    _initcontainerimage:: globalconf.initcontainerimage,
    _amahsparkexservicetype:: amahspark.exservicetype,
    _amahsparkdockerimage:: amahspark.image,
    _amahsparkexternalports:: amahspark.externalports,
    _amahsparknodeports:: amahspark.nodeports,
    _amahsparkinstancecount:: amahspark.instancecount,
    _amahsparkrequestcpu:: amahspark.requestcpu,
    _amahsparkrequestmem:: amahspark.requestmem,
    _amahsparklimitcpu:: amahspark.limitcpu,
    _amahsparklimitmem:: amahspark.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           if componentoramah == "amah" then
             amahsparkstorages.items
           else
             sparkstorages.items
         else if deploytype == "podservice" then
           if componentoramah == "component" then
             sparkpodservice.items
           else if componentoramah == "amah" then
             amahsparkpodservice.items
           else if componentoramah == "both" then
             sparkpodservice.items + amahsparkpodservice.items
           else
             error "Unknow componentoramah type"
         else
           error "Unknow deploytype",
}
