( import "../common/service.jsonnet" ) {
  // global variables
  _amahmongodbprefix:: "",

  // override super global variables
  _mname: "amahmongodb",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "amahport:8084",
    
  ],
}
