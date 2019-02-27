( import "../common/service.jsonnet" ) {
  // global variables
  _amahelasticsearchprefix:: "",

  // override super global variables
  _mname: "amahelasticsearch",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "amahport:8084",
    
  ],
}
