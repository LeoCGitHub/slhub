pushd modules

docker compose -f keycloak/compose.yaml up -d

# DB
bash db_postgresql/up.sh
bash db_mongodb/up.sh

# BACKENDS
bash back_nodejs_nest/up.sh

# FRONTENDS
# bash front_angular/up.sh
# bash front-react/up.sh

# PROMETHEUS/GRAFANA
docker compose -f prometheus_grafana/compose.yaml up -d

popd