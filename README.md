<img src=https://blog.switcheo.network/content/images/size/w2000/2020/03/Switcheo-TradeHub.png></img>

### Important commands

#### Build from Scratch & Start detached
docker-compose build --no-cache && docker-compose up -d
#### Reset (Delete) Containers
docker-compose down
#### Prune unused containers
docker system prune
#### Prune unused volumes
docker volume prune
#### Start the compose stack
docker-compose start
#### Stop the compose stack
docker-compose stop
#### See container logs
docker logs -f (container-name) --tail 10
#### Bash on the container
docker exec -it (container-name) /bin/bash