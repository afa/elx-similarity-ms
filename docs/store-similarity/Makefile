shop:
	docker-compose ps | grep -E 'shopfront.web.1.*Up' || docker-compose up -d
	docker attach `docker-compose ps | grep web | cut -d ' ' -f1`

checkup:
	rubocop --display-only-fail-level-offenses --fail-level=error && \
	rubocop --only Lint/Debugger

build_shop:
	docker-compose build web
	docker images --filter "dangling=true" -q | xargs docker rmi || echo "There are images tagged as <none> in use"

gem_install:
	docker-compose run --rm web bundle install

rconsole:
	docker exec -it `docker-compose ps | grep web | cut -d ' ' -f1` rails console

shop_bash:
	docker exec -it `docker-compose ps | grep web | cut -d ' ' -f1` bash

tests:
	rspec --tag ~type:system

codecov:
	./.dev_conf/test_with_coverage.sh

cleanlogs:
	rm ./log/development.log
	touch ./log/development.log
	rm ./log/test.log
	touch ./log/test.log
	rm ./log/bullet.log
	touch ./log/bullet.log

dbs-test:
	docker exec -i vs_api-db-1 mysql -u root -pexample myapp_test
dbs-dev:
	docker exec -i vs_api-db-1 mysql -u root -pexample myapp_development
db-test:
	docker exec -it vs_api-db-1 mysql -u root -pexample myapp_test
db-dev:
	docker exec -it vs_api-db-1 mysql -u root -pexample myapp_development
server:
	docker exec -it vs_api-web-1 rails s
bash:
	docker exec -it vs_api-web-1 bash
sh:
	docker exec -it vs_api-web-1 rails c
down:
	docker-compose down
up:
	docker-compose up -d
sphinx:
	rm -fv ./tmp/binlog/development/binlog.lock ./data/unit_core.lock ./data/product_core.lock ./log/development.sphinx.pid
	docker exec -it vs_api-web-1 rake ts:start
	docker exec -it vs_api-web-1 rake ts:rebuild
weblog:
	docker logs vs_api-web-1
weblogf:
	docker logs vs_api-web-1 --follow
LINT_PATH := $(or $(LINT_PATH),./)
lint: rubocop
rubocop:
	docker-compose run --rm web rubocop --force-exclusion $(LINT_PATH)
rubocop-new:
	docker-compose run --rm web rubocop --force-exclusion $(shell git diff --name-only master '*.rb')

DFLT_TEST_PATHi=spec/decorators spec/entities spec/for_active_admin  spec/helpers spec/jobs spec/lib spec/mailers  spec/requests spec/decorators spec/models spec/routing spec/views spec/services/analogs spec/services/autobuyer spec/services/boxberry_service spec/services/cdek spec/services/dadata_service spec/services/dolyame spec/services/for_campaign spec/services/fresh_cart spec/services/geocoding_service spec/services/give_rank_spec.rb spec/services/integral spec/services/items spec/services/labirint spec/services/line_item spec/services/logistics spec/services/measoft spec/services/novelty_updater_spec.rb spec/services/operations spec/services/order spec/services/ozon_service spec/services/sales_history spec/services/scraper_spec.rb spec/services/seo spec/services/spellchecker_spec.rb spec/services/user_locator_spec.rb spec/services/vsexshop spec/services/wildberries_service spec/services/wms spec/services/yandex
TEST_PATH := $(or $(TEST_PATH),$(DFLT_TEST_PATHi))
test:
	docker-compose run -e RAILS_ENV=test --rm web bundle exec rspec $(TEST_PATH)
# spec/services/ruspost  -- errors breaking rspec
