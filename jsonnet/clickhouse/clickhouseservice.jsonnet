( import "../common/service.jsonnet" ) {
  // global variables
  _clickhouseprefix:: "",

  // override super global variables
  _mname: "clickhouse",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "port1:8123",
    "port2:9000",
    "port3:9009",
    
  ],
}
