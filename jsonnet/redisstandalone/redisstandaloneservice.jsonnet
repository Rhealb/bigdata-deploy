( import "../common/service.jsonnet" ) {
  // global variables
  _redisstandaloneprefix:: "",

  // override super global variables
  _mname: "redisstandalone",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "httpport:6379",
    
  ],
}
