{
  // opentsdb deploy global variables
  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,
  local componentoramah = globalconf.opentsdb.componentoramah,

  local opentsdbstorages = (import "../opentsdb/deploy/opentsdbstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local opentsdb = globalconf.opentsdb,
    _utilsstoretype:: globalconf.utilsstoretype,
    _opentsdbinstancecount:: opentsdb.instancecount,
    _opentsdblogstoragesize :: opentsdb.logpvcstoragesize,
  },

  local opentsdbpodservice = (import "../opentsdb/deploy/opentsdbpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _zkinstancecount:: globalconf.opentsdb.zkinstancecount,
    local opentsdb = globalconf.opentsdb,
    _initcontainerimage:: globalconf.initcontainerimage,
    _zkprefix:: opentsdb.zkprefix,
    _hbaseprefix:: opentsdb.hbaseprefix,
    _utilsstoretype:: globalconf.utilsstoretype,
    _opentsdbdockerimage:: opentsdb.image,
    _opentsdbexservicetype:: opentsdb.exservicetype,
    _opentsdbinstancecount:: opentsdb.instancecount,
    _opentsdbrequestcpu:: opentsdb.requestcpu,
    _opentsdbrequestmem:: opentsdb.requestmem,
    _opentsdblimitcpu:: opentsdb.limitcpu,
    _opentsdblimitmem:: opentsdb.limitmem,
    _externalports:: opentsdb.externalports,
    _opentsdbnodeports:: opentsdb.nodeports,
    _opentsdbjavaxms:: opentsdb.javaxms,
    _opentsdbjavaxmx:: opentsdb.javaxmx,
  },

  local amahopentsdbstorages = (import "../opentsdb/deploy/amahopentsdbstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local amahopentsdbpodservice = (import "../opentsdb/deploy/amahopentsdbpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local amahopentsdb = globalconf.opentsdb.amah,
    _initcontainerimage:: globalconf.initcontainerimage,
    _amahopentsdbexservicetype:: amahopentsdb.exservicetype,
    _amahopentsdbdockerimage:: amahopentsdb.image,
    _amahopentsdbexternalports:: amahopentsdb.externalports,
    _amahopentsdbnodeports:: amahopentsdb.nodeports,
    _amahopentsdbinstancecount:: amahopentsdb.instancecount,
    _amahopentsdbrequestcpu:: amahopentsdb.requestcpu,
    _amahopentsdbrequestmem:: amahopentsdb.requestmem,
    _amahopentsdblimitcpu:: amahopentsdb.limitcpu,
    _amahopentsdblimitmem:: amahopentsdb.limitmem,
  },
  kind: "List",
  apiVersion: "v1",

  items: if deploytype == "storage" then
           if componentoramah == "amah" then
             amahopentsdbstorages.items
           else
             opentsdbstorages.items
         else if deploytype == "podservice" then
           if componentoramah == "component" then
             opentsdbpodservice.items
           else if componentoramah == "amah" then
             amahopentsdbpodservice.items
           else if componentoramah == "both" then
             opentsdbpodservice.items + amahopentsdbpodservice.items
          else
             error "Unknow componentoramah type"
         else
           error "Unknow deploytype",


}
