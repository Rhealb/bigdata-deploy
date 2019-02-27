{
  // ping deploy global variables
  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,

  local pingstorages = (import "../ping/deploy/pingstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local ping = globalconf.ping,
    _utilsstoretype:: globalconf.utilsstoretype,
    _pingdatastoragesize:: ping.datastoragesize,
  },

  local pingpodservice = (import "../ping/deploy/pingpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _zkinstancecount:: globalconf.ping.zkinstancecount,
    _jninstancecount:: globalconf.ping.jninstancecount,
    _kafkainstancecount:: globalconf.ping.kafkainstancecount,
    local ping = globalconf.ping,
    _initcontainerimage:: globalconf.initcontainerimage,
    _zkprefix:: ping.zkprefix,
    _kafkaprefix:: ping.kafkaprefix,
    _hdfsprefix:: ping.hdfsprefix,
    _utilsstoretype:: globalconf.utilsstoretype,
    _pingdockerimage:: ping.image,
    _pinginstancecount:: ping.instancecount,
    _pingrequestcpu:: ping.requestcpu,
    _pingrequestmem:: ping.requestmem,
    _pinglimitcpu:: ping.limitcpu,
    _pinglimitmem:: ping.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           pingstorages.items
         else if deploytype == "podservice" then
           pingpodservice.items
         else
           error "Unknow deploytype",
}
