{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,
  local componentoramah = globalconf.zookeeper.componentoramah,

  local mongodbstorages = (import "../mongodb/deploy/mongodbstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
    local mongodb = globalconf.mongodb,
    _mongodbinstancecount:: mongodb.instancecount,
    _mongodbdatastoragesize:: mongodb.datastoragesize,
    _mongodblogstoragesize:: mongodb.logstoragesize,
  },

  local mongodbpodservice = (import "../mongodb/deploy/mongodbpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local mongodb = globalconf.mongodb,
    _initcontainerimage:: globalconf.initcontainerimage,
    _mongodbexservicetype:: mongodb.exservicetype,
    _mongodbdockerimage:: mongodb.image,
    _mongodbexternalports:: mongodb.externalports,
    _mongodbnodeports:: mongodb.nodeports,
    _mongodbinstancecount:: mongodb.instancecount,
    _mongodbrequestcpu:: mongodb.requestcpu,
    _mongodbrequestmem:: mongodb.requestmem,
    _mongodblimitcpu:: mongodb.limitcpu,
    _mongodblimitmem:: mongodb.limitmem,
    _mongodbrsname:: mongodb.mongodbrsname,
  },

  local amahmongodbstorages = (import "../mongodb/deploy/amahmongodbstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local amahmongodbpodservice = (import "../mongodb/deploy/amahmongodbpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    _mongodbinstancecount:: globalconf.mongodb.instancecount,
    local amahmongodb = globalconf.mongodb.amah,
    _initcontainerimage:: globalconf.initcontainerimage,
    _amahmongodbexservicetype:: amahmongodb.exservicetype,
    _amahmongodbdockerimage:: amahmongodb.image,
    _amahmongodbexternalports:: amahmongodb.externalports,
    _amahmongodbnodeports:: amahmongodb.nodeports,
    _amahmongodbinstancecount:: amahmongodb.instancecount,
    _amahmongodbrequestcpu:: amahmongodb.requestcpu,
    _amahmongodbrequestmem:: amahmongodb.requestmem,
    _amahmongodblimitcpu:: amahmongodb.limitcpu,
    _amahmongodblimitmem:: amahmongodb.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
            if componentoramah == "amah" then
              amahmongodbstorages.items
            else
              mongodbstorages.items
          else if deploytype == "podservice" then
            if componentoramah == "component" then
              mongodbpodservice.items
            else if componentoramah == "amah" then
              amahmongodbpodservice.items
            else if componentoramah == "both" then
              mongodbpodservice.items + amahmongodbpodservice.items
           else
              error "Unknow componentoramah type"
          else
            error "Unknow deploytype",
}
