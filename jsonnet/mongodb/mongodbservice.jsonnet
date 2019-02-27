( import "../common/service.jsonnet" ) {
  // global variables
  _mongodbprefix:: "",

  // override super global variables
  _mname: "mongodb",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "clientport:27017",
  ],
}
