#!/bin/bash

set -x
set -e

# Функция для ожидания запуска контейнера
wait_for_healthy_container() {
  local SERVICE_NAME="$1"


  while true; do
    STATUS=$(docker inspect --format='{{json .State.Health.Status}}' "$SERVICE_NAME")
    
    if [[ $STATUS == "\"healthy\"" ]]; then
      echo "Контейнер $SERVICE_NAME запущен статус $STATUS."
      break
    else
      echo "Ожидание запуска контейнера $SERVICE_NAME... статус $STATUS"
      sleep 1
    fi
  done
}


###
# Инициализируем конфиг сервер
###
wait_for_healthy_container "configSrv"
docker-compose exec -T configSrv mongosh --quiet --port 27017 <<EOF

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

echo "=======";

###
# Инициализируем шарды
###
wait_for_healthy_container "shard1-1"
wait_for_healthy_container "shard1-2"
wait_for_healthy_container "shard1-3"
docker-compose exec -T shard1-1 mongosh --quiet --port 27017 <<EOF

rs.initiate(
  {
    _id: "rs_shard1",
    members: [
      { _id: 0, host: "shard1-1:27017" },
      { _id: 1, host: "shard1-2:27017" },
      { _id: 2, host: "shard1-3:27017" }
    ]
  }
);

exit();
EOF

echo "=======";

wait_for_healthy_container "shard1-1"
wait_for_healthy_container "shard1-2"
wait_for_healthy_container "shard1-3"
docker-compose exec -T shard2-1 mongosh --quiet --port 27017 <<EOF

rs.initiate(
  {
    _id: "rs_shard2",
    members: [
      { _id: 0, host: "shard2-1:27017" },
      { _id: 1, host: "shard2-2:27017" },
      { _id: 2, host: "shard2-3:27017" }
    ]
  }
);

exit();
EOF

echo "=======";

###
# Инициализируем роутер и шарды, через роутер
###
wait_for_healthy_container "mongos_router"
docker-compose exec -T mongos_router mongosh --quiet --port 27017 <<EOF

sh.addShard("rs_shard1/shard1-1:27017")
sh.addShard("rs_shard2/shard2-1:27017")

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } );

exit();
EOF

echo "=======";

###
# Инициализируем бд через роутер
###

docker compose exec -T mongos_router mongosh --quiet --port 27017 <<EOF

use somedb

for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})

db.helloDoc.countDocuments() 
exit();
EOF

echo "";
echo "=================="
echo "shard1-1 doc count"
echo "=================="
docker compose exec -T shard1-1 mongosh --quiet --port 27017 <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF
echo "=================="

echo "";
echo "=================="
echo "shard2-1 doc count"
echo "=================="
docker compose exec -T shard2-1 mongosh --quiet --port 27017 <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF
echo "=================="