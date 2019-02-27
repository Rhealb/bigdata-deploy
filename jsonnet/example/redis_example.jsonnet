{
  // redis deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,
  local componentoramah = globalconf.redis.componentoramah,

  local redisstorages = (import "../redis/deploy/redisstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
    _redisinstancecount:: globalconf.redis.instancecount,
    _redisdatastoragesize:: globalconf.redis.redisdatastoragesize,
  },

  local redispodservice = (import "../redis/deploy/redispodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local redis = globalconf.redis,
    _zkprefix: redis.zkprefix,
    local redismaster = redis.master,
    local redisslave = redis.slave,
    _initcontainerimage:: globalconf.initcontainerimage,
    _zkinstancecount:: redis.zkinstancecount,
    _redisinstancecount:: redis.instancecount,
    _redisexservicetype:: redis.exservicetype,
    _redisdockerimage:: redis.image,
    _redisexternalports:: redis.externalports,
    _redisnodeports:: redis.nodeports,
    _redismasterrequestcpu:: redismaster.requestcpu,
    _redismasterrequestmem:: redismaster.requestmem,
    _redismasterlimitcpu:: redismaster.limitcpu,
    _redismasterlimitmem:: redismaster.limitmem,
    _redisslaverequestcpu:: redisslave.requestcpu,
    _redisslaverequestmem:: redisslave.requestmem,
    _redisslavelimitcpu:: redisslave.limitcpu,
    _redisslavelimitmem:: redisslave.limitmem,
    _redisdatastoragesize:: globalconf.redis.redisdatastoragesize,
  },

  local amahredisstorages = (import "../redis/deploy/amahredisstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local amahredispodservice = (import "../redis/deploy/amahredispodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local amahredis = globalconf.redis.amah,
    _initcontainerimage:: globalconf.initcontainerimage,
    _amahredisexservicetype:: amahredis.exservicetype,
    _amahredisdockerimage:: amahredis.image,
    _amahredisexternalports:: amahredis.externalports,
    _amahredisnodeports:: amahredis.nodeports,
    _amahredisinstancecount:: amahredis.instancecount,
    _amahredisrequestcpu:: amahredis.requestcpu,
    _amahredisrequestmem:: amahredis.requestmem,
    _amahredislimitcpu:: amahredis.limitcpu,
    _amahredislimitmem:: amahredis.limitmem,
  },

  kind: "List",
  apiVersion: "v1",

  items: if deploytype == "storage" then
           if componentoramah == "amah" then
             amahredisstorages.items
           else
             redisstorages.items
         else if deploytype == "podservice" then
           if componentoramah == "component" then
             redispodservice.items
           else if componentoramah == "amah" then
             amahredispodservice.items
           else if componentoramah == "both" then
             redispodservice.items + amahredispodservice.items
          else
             error "Unknow componentoramah type"
         else
           error "Unknow deploytype",

}
