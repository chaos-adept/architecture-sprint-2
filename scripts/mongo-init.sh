#!/bin/bash

set -x
set -e

###
# Инициализируем конфиг сервер
###

docker-compose exec -T configSrv mongosh --port 27017 <<EOF

rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
exit();
EOF


###
# Инициализируем шарды
###

docker-compose exec -T shard1_primary mongosh --port 27017 <<EOF

rs.initiate(
  {
    _id: "rs_shard1",
    members: [
      { _id: 0, host: "shard1_primary:27017" },
      { _id: 1, host: "shard1_secondary1:27017" },
      { _id: 2, host: "shard1_secondary2:27017" }
    ]
  }
);

exit();
EOF

docker-compose exec -T shard2_primary mongosh --port 27017 <<EOF

rs.initiate(
  {
    _id: "rs_shard2",
    members: [
      { _id: 0, host: "shard2_primary:27017" },
      { _id: 1, host: "shard2_secondary1:27017" },
      { _id: 2, host: "shard2_secondary2:27017" }
    ]
  }
);

exit();
EOF

###
# Инициализируем роутер и шарды, через роутер
###

docker-compose exec -T mongos_router mongosh --port 27017 <<EOF

sh.addShard("rs_shard1/shard1_primary:27017")
sh.addShard("rs_shard2/shard2_primary:27017")

sh.enableSharding("mongodb1");
sh.shardCollection("mongodb1.helloDoc", { "name" : "hashed" } );

exit();

EOF


###
# Инициализируем бд через роутер
###

docker compose exec -T mongos_router mongosh --port 27017 <<EOF

use mongodb1

for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})

db.helloDoc.countDocuments() 
exit();
EOF

