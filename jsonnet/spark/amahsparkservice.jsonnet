( import "../common/service.jsonnet" ) {
  // global variables
  _amahsparkprefix:: "",

  // override super global variables
  _mname: "amahspark",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "amahport:8084",
    
  ],
}
