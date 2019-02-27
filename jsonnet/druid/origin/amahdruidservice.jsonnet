( import "../../common/service.jsonnet" ) {
  // global variables
  _amahdruidprefix:: "",

  // override super global variables
  _mname: "amahdruid",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "amahport:8084",
    
  ],
}
