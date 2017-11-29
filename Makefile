# pull the tag from version.txt
TAG:=`cat version.txt`
IMAGE:=usgseros/lcmap-firebird

vertest:
	@echo TAG:$(TAG)
	@echo IMAGE:$(IMAGE)

docker-build:
	docker build -t $(IMAGE):$(TAG) -t $(IMAGE):latest $(PWD)

docker-push:
	docker login
	docker push $(IMAGE):$(TAG)
	docker push $(IMAGE):latest

docker-shell:
	docker run -it --entrypoint=/bin/bash $(IMAGE):latest

deps-up:
	docker-compose -f test/resources/docker-compose.yml up

deps-down: 
	docker-compose -f test/resources/docker-compose.yml down

db-schema:
	docker cp test/resources/schema.setup.cql firebird-cassandra:/
	docker exec -u root firebird-cassandra cqlsh localhost -f schema.setup.cql

spark-lib:
	@rm -rf lib
	@mkdir lib
	wget -P lib https://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.7.tgz
	gunzip lib/*gz
	tar -C lib -xvf lib/spark-2.2.0-bin-hadoop2.7.tar
	rm lib/*tar
	ln -s spark-2.2.0-bin-hadoop2.7 lib/spark
	mvn dependency:copy-dependencies -f pom.xml -DoutputDirectory=lib/spark/jars

tests:
	./test.sh

clean:
	@rm -rf dist build lcmap_firebird.egg-info test/coverage lib/ derby.log spark-warehouse
	@find . -name '*.pyc' -delete
	@find . -name '__pycache__' -delete
