{
  // elasticsearch deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local componentoramah = globalconf.elasticsearch.componentoramah,

  local esstorages = (import "../elasticsearch/deploy/esstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local elasticsearch = globalconf.elasticsearch,
    _utilsstoretype:: globalconf.utilsstoretype,
    _esdatastoragesize:: elasticsearch.esdatastoragesize,
  },

  local espodservice = (import "../elasticsearch/deploy/espodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    local elasticsearch = globalconf.elasticsearch,
    local esmaster = elasticsearch.master,
    local esdata = elasticsearch.data,
    local esclient = elasticsearch.client,
    _initcontainerimage:: globalconf.initcontainerimage,
    _utilsstoretype:: globalconf.utilsstoretype,
    _esdockerimage:: elasticsearch.image,
    _esexservicetype:: elasticsearch.exservicetype,
    _esexternalports:: elasticsearch.externalports,
    _esnodeports:: elasticsearch.nodeports,
    _esmasterinstancecount:: esmaster.instancecount,
    _esdatainstancecount:: esdata.instancecount,
    _esclientinstancecount:: esclient.instancecount,
    _esmasterrequestcpu:: esmaster.requestcpu,
    _esmasterrequestmem:: esmaster.requestmem,
    _esmasterlimitcpu:: esmaster.limitcpu,
    _esmasterlimitmem:: esmaster.limitmem,
    _esmasterjavaxms:: esmaster.javaxms,
    _esmasterjavaxmx:: esmaster.javaxmx ,
    _esdatarequestcpu:: esdata.requestcpu,
    _esdatarequestmem:: esdata.requestmem,
    _esdatalimitcpu:: esdata.limitcpu,
    _esdatalimitmem:: esdata.limitmem,
    _esdatajavaxms:: esdata.javaxms,
    _esdatajavaxmx:: esdata.javaxmx ,
    _esclientrequestcpu:: esclient.requestcpu,
    _esclientrequestmem:: esclient.requestmem,
    _esclientlimitcpu:: esclient.limitcpu,
    _esclientlimitmem:: esclient.limitmem,
    _esclientjavaxms:: esclient.javaxms,
    _esclientjavaxmx:: esclient.javaxmx ,
  },


  local amahesstorages = (import "../elasticsearch/deploy/amahelasticsearchstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local amahespodservice = (import "../elasticsearch/deploy/amahelasticsearchpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local amahelasticsearch = globalconf.elasticsearch.amah,
    _initcontainerimage:: globalconf.initcontainerimage,
    _amahelasticsearchexservicetype:: amahelasticsearch.exservicetype,
    _amahelasticsearchdockerimage:: amahelasticsearch.image,
    _amahelasticsearchexternalports:: amahelasticsearch.externalports,
    _amahelasticsearchnodeports:: amahelasticsearch.nodeports,
    _amahelasticsearchreplicas:: amahelasticsearch.instancecount,
    _amahelasticsearchrequestcpu:: amahelasticsearch.requestcpu,
    _amahelasticsearchrequestmem:: amahelasticsearch.requestmem,
    _amahelasticsearchlimitcpu:: amahelasticsearch.limitcpu,
    _amahelasticsearchlimitmem:: amahelasticsearch.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           if componentoramah == "amah" then
             amahesstorages.items
           else
             esstorages.items
         else if deploytype == "podservice" then
           if componentoramah == "component" then
             espodservice.items
           else if componentoramah == "amah" then
             amahespodservice.items
           else if componentoramah == "both" then
             espodservice.items + amahespodservice.items
          else
             error "Unknow componentoramah type"
         else
           error "Unknow deploytype",
}
