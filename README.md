# neo4j-azul-docker

Experimental dockerfiles for testing neo4j 5.3 with unsupported azul jdk (zulu and zing).

Also includes dockerfile for supported openjdk.


Clone the repo

cd to the desired directory run the build file, eg:

docker build . -t "neo4j-5.3-enterprise-openjdk" -f neo4j-5.3-enterprise-openjdk.dockerfile

docker build . -t "neo4j-5.3-enterprise-zulu" -f neo4j-5.3-enterprise-zulu.dockerfile

docker build . -t "neo4j-5.3-enterprise-zing" -f neo4j-5.3-enterprise-zing.dockerfile



To launch:

docker-compose up

Neo4j directories will be exported to local for /data /logs /conf /import


https://www.azul.com/downloads/?package=jdk
