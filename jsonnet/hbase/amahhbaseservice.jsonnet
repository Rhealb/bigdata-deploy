( import "../common/service.jsonnet" ) {
  // global variables
  _amahhbaseprefix:: "",

  // override super global variables
  _mname: "amahhbase",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "amahport:8084",
    
  ],
}
