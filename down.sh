pushd modules

docker compose -f keycloak/compose.yaml down

# DB
bash db_postgresql/down.sh
bash db_mongodb/down.sh

# BACKENDS
bash back_nodejs_nest/down.sh

# FRONTENDS
bash front_angular/down.sh
# bash front-react/down.sh

docker compose -f prometheus_grafana/compose.yaml down

popd