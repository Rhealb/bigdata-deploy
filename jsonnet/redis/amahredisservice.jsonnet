( import "../common/service.jsonnet" ) {
  // global variables
  _amahredisprefix:: "",

  // override super global variables
  _mname: "amahredis",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "amahport:8084",
    
  ],
}
