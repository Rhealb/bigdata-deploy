{
  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,
  local componentoramah = globalconf.hbase.componentoramah,

  local hbasestorages = (import "../hbase/deploy/hbasestorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local hbasepodservice = (import "../hbase/deploy/hbasepodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _zknum:: globalconf.hbase.zkinstancecount,
    _zkprefix:: globalconf.hbase.zkprefix,
    _hdfsprefix:: globalconf.hbase.hdfsprefix,
    local hbase = globalconf.hbase,
    local hmaster = hbase.master,
    local regionserver = hbase.regionserver,
    _initcontainerimage:: globalconf.initcontainerimage,
    _utilsstoretype:: globalconf.utilsstoretype,
    _hbasedockerimage:: hbase.image,
    _hbaseexservicetype:: hbase.exservicetype,
    _externalports:: hbase.externalports,
    _hbasenodeports:: hbase.nodeports,
    _tsdbttl:: hbase.tsdbttl,
    _hminstancecount:: hmaster.instancecount,
    _rsinstancecount:: regionserver.instancecount,
    _hmrequestcpu:: hmaster.requestcpu,
    _hmrequestmem:: hmaster.requestmem,
    _hmlimitcpu:: hmaster.limitcpu,
    _hmlimitmem:: hmaster.limitmem,
    _hmasterpermsize:: hmaster.permsize,
    _hmastermaxpermsize:: hmaster.maxpermsize,
    _hmasterjavaxmx:: hmaster.javaxmx,
    _rsrequestcpu:: regionserver.requestcpu,
    _rsrequestmem:: regionserver.requestmem,
    _rslimitcpu:: regionserver.limitcpu,
    _rslimitmem:: regionserver.limitmem,
    _hregionserverpermsize:: regionserver.permsize,
    _hregionservermaxpermsize:: regionserver.maxpermsize,
    _hregionserverjavaxmx:: regionserver.javaxmx,
    _cephhostports:: ceph.hostports,
  },

  local amahhbasestorages = (import "../hbase/deploy/amahhbasestorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local amahhbasepodservice = (import "../hbase/deploy/amahhbasepodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _zknum:: globalconf.hbase.zkinstancecount,
    _zkprefix:: globalconf.hbase.zkprefix,
    _utilsstoretype:: globalconf.utilsstoretype,
    local amahhbase = globalconf.hbase.amah,
    _initcontainerimage:: globalconf.initcontainerimage,
    _hbasemasterinstancecount:: amahhbase.hbasemasterinstancecount,
    _amahhbaseexservicetype:: amahhbase.exservicetype,
    _amahhbasedockerimage:: amahhbase.image,
    _amahhbaseexternalports:: amahhbase.externalports,
    _amahhbasenodeports:: amahhbase.nodeports,
    _amahhbaseinstancecount:: amahhbase.instancecount,
    _amahhbaserequestcpu:: amahhbase.requestcpu,
    _amahhbaserequestmem:: amahhbase.requestmem,
    _amahhbaselimitcpu:: amahhbase.limitcpu,
    _amahhbaselimitmem:: amahhbase.limitmem,
  },


  kind: "List",
  apiVersion: "v1",

  items: if deploytype == "storage" then
           if componentoramah == "amah" then
             amahhbasestorages.items
           else
             hbasestorages.items
         else if deploytype == "podservice" then
           if componentoramah == "component" then
             hbasepodservice.items
           else if componentoramah == "amah" then
             amahhbasepodservice.items
           else if componentoramah == "both" then
             hbasepodservice.items + amahhbasepodservice.items
          else
             error "Unknow componentoramah type"
         else
           error "Unknow deploytype",


}
