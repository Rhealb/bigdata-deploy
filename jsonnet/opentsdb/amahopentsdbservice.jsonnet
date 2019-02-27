( import "../common/service.jsonnet" ) {
  // global variables
  _amahopentsdbprefix:: "",

  // override super global variables
  _mname: "amahopentsdb",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "amahport:8084",
    
  ],
}
