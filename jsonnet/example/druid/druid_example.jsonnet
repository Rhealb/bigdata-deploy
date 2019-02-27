{
  // druid deploy global variables

  local globalconf = import "../global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,
  local componentoramah = globalconf.druid.origin.componentoramah,

  local druidstorages = (import "../../druid/origin/deploy/druidstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local druid = globalconf.druid.origin,
    local historical = druid.historical,
    local middlemanager = druid.middlemanager,
    _utilsstoretype:: globalconf.utilsstoretype,
    _histsegmentcachestoragesize:: historical.histsegmentcachepvcstoragesize,
    _mmsegmentsstoragesize:: middlemanager.mmsegmentsstoragesize,
  },

  local druidpodservice = (import "../../druid/origin/deploy/druidpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    local druid = globalconf.druid.origin,
    local broker = druid.broker,
    local coordinator = druid.coordinator,
    local historical = druid.historical,
    local middlemanager = druid.middlemanager,
    local overlord = druid.overlord,
    _initcontainerimage:: globalconf.initcontainerimage,
    _zkprefix:: druid.zkprefix,
    _zkinstancecount:: druid.zkinstancecount,
    _hdfsprefix:: druid.hdfsprefix,
    _mysqlprefix:: druid.mysqlprefix,
    _componentoramah:: componentoramah,
    _utilsstoretype:: globalconf.utilsstoretype,
    _mysqlpasswd:: druid.mysqlpasswd,
    _mysqlusername:: druid.mysqlusername,
    _druidexservicetype:: druid.exservicetype,
    _druiddockerimage:: druid.image,
    _externalports:: druid.externalports,
    _druidnodeports:: druid.nodeports,
    _brokerinstancecount:: broker.instancecount,
    _coordinatorinstancecount:: coordinator.instancecount,
    _historicalinstancecount:: historical.instancecount,
    _middlemanagerinstancecount:: middlemanager.instancecount,
    _overlordinstancecount:: overlord.instancecount,
    _brokerrequestcpu:: broker.requestcpu,
    _brokerrequestmem:: broker.requestmem,
    _brokerlimitcpu:: broker.limitcpu,
    _brokerlimitmem:: broker.limitmem,
    _coordinatorrequestcpu:: coordinator.requestcpu,
    _coordinatorrequestmem:: coordinator.requestmem,
    _coordinatorlimitcpu:: coordinator.limitcpu,
    _coordinatorlimitmem:: coordinator.limitmem,
    _historicalrequestcpu:: historical.requestcpu,
    _historicalrequestmem:: historical.requestmem,
    _historicallimitcpu:: historical.limitcpu,
    _historicallimitmem:: historical.limitmem,
    _middlemanagerrequestcpu:: middlemanager.requestcpu,
    _middlemanagerrequestmem:: middlemanager.requestmem,
    _middlemanagerlimitcpu:: middlemanager.limitcpu,
    _middlemanagerlimitmem:: middlemanager.limitmem,
    _overlordrequestcpu:: overlord.requestcpu,
    _overlordrequestmem:: overlord.requestmem,
    _overlordlimitcpu:: overlord.limitcpu,
    _overlordlimitmem:: overlord.limitmem,
  },

  local amahdruidstorages = (import "../../druid/origin/deploy/amahdruidstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local amahdruidpodservice = (import "../../druid/origin/deploy/amahdruidpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local amahdruid = globalconf.druid.origin.amah,
    _initcontainerimage:: globalconf.initcontainerimage,
    _amahdruidexservicetype:: amahdruid.exservicetype,
    _amahdruiddockerimage:: amahdruid.image,
    _amahdruidexternalports:: amahdruid.externalports,
    _amahdruidnodeports:: amahdruid.nodeports,
    _amahdruidinstancecount:: amahdruid.instancecount,
    _amahdruidreplicas:: amahdruid.replicas,
    _amahdruidrequestcpu:: amahdruid.requestcpu,
    _amahdruidrequestmem:: amahdruid.requestmem,
    _amahdruidlimitcpu:: amahdruid.limitcpu,
    _amahdruidlimitmem:: amahdruid.limitmem,
  },


  kind: "List",
  apiVersion: "v1",

  items: if deploytype == "storage" then
           if componentoramah == "amah" then
             amahdruidstorages.items
           else
             druidstorages.items
         else if deploytype == "podservice" then
           if componentoramah == "component" then
             druidpodservice.items
           else if componentoramah == "amah" then
             amahdruidpodservice.items
           else if componentoramah == "both" then
             druidpodservice.items + amahdruidpodservice.items
          else
             error "Unknow componentoramah type"
         else
           error "Unknow deploytype",



}
