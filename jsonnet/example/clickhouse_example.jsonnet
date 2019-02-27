{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local componentoramah = globalconf.zookeeper.componentoramah,

  local clickhousestorages = (import "../clickhouse/deploy/clickhousestorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
    local clickhouse = globalconf.clickhouse,
    _clickhouseinstancecount:: clickhouse.instancecount,
  },

  local clickhousepodservice = (import "../clickhouse/deploy/clickhousepodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local clickhouse = globalconf.clickhouse,
    _initcontainerimage:: globalconf.initcontainerimage,
    _zkprefix:: clickhouse.zkprefix,
    _zkinstancecount:: clickhouse.zkinstancecount,
    _clickhouseexservicetype:: clickhouse.exservicetype,
    _clickhousedockerimage:: clickhouse.image,
    _clickhouseexternalports:: clickhouse.externalports,
    _clickhousenodeports:: clickhouse.nodeports,
    _clickhouseinstancecount:: clickhouse.instancecount,
    _clickhousereplicas:: clickhouse.replicas,
    _clickhouserequestcpu:: clickhouse.requestcpu,
    _clickhouserequestmem:: clickhouse.requestmem,
    _clickhouselimitcpu:: clickhouse.limitcpu,
    _clickhouselimitmem:: clickhouse.limitmem,
  },

  local amahclickhousestorages = (import "../clickhouse/deploy/amahclickhousestorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local amahclickhousepodservice = (import "../clickhouse/deploy/amahclickhousepodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local amahclickhouse = globalconf.clickhouse.amah,
    _initcontainerimage:: globalconf.initcontainerimage,
    _clickhouseinstancecount:: amahclickhouse.clickhouseinstancecount,
    _amahclickhouseexservicetype:: amahclickhouse.exservicetype,
    _amahclickhousedockerimage:: amahclickhouse.image,
    _amahclickhouseexternalports:: amahclickhouse.externalports,
    _amahclickhousenodeports:: amahclickhouse.nodeports,
    _amahclickhouseinstancecount:: amahclickhouse.instancecount,
    _amahclickhousereplicas:: amahclickhouse.replicas,
    _amahclickhouserequestcpu:: amahclickhouse.requestcpu,
    _amahclickhouserequestmem:: amahclickhouse.requestmem,
    _amahclickhouselimitcpu:: amahclickhouse.limitcpu,
    _amahclickhouselimitmem:: amahclickhouse.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
          if componentoramah == "amah" then
            amahclickhousestorages.items
          else
            clickhousestorages.items
        else if deploytype == "podservice" then
          if componentoramah == "component" then
            clickhousepodservice.items
          else if componentoramah == "amah" then
            amahclickhousepodservice.items
          else if componentoramah == "both" then
            clickhousepodservice.items + amahclickhousepodservice.items
        else
            error "Unknow componentoramah type"
        else
          error "Unknow deploytype",
}
