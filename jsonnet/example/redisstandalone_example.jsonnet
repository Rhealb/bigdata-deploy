{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local redisstandalonestorages = (import "../redisstandalone/deploy/redisstandalonestorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
    local redisstandalone = globalconf.redisstandalone,
    _redisdatastoragesize:: redisstandalone.datastoragesize,
  },

  local redisstandalonepodservice = (import "../redisstandalone/deploy/redisstandalonepodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local redisstandalone = globalconf.redisstandalone,
    _initcontainerimage:: globalconf.initcontainerimage,
    _redisstandaloneexservicetype:: redisstandalone.exservicetype,
    _redisstandalonedockerimage:: redisstandalone.image,
    _redisstandaloneexternalports:: redisstandalone.externalports,
    _redisstandalonenodeports:: redisstandalone.nodeports,
    _redisstandaloneinstancecount:: redisstandalone.instancecount,
    _redisstandalonereplicas:: redisstandalone.replicas,
    _redisstandalonerequestcpu:: redisstandalone.requestcpu,
    _redisstandalonerequestmem:: redisstandalone.requestmem,
    _redisstandalonelimitcpu:: redisstandalone.limitcpu,
    _redisstandalonelimitmem:: redisstandalone.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           redisstandalonestorages.items
         else if deploytype == "podservice" then
           redisstandalonepodservice.items
         else
           error "Unknow deploytype",
}
