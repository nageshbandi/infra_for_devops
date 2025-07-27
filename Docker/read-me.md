
## 1. Remove Exited Containers

docker rm $(docker ps -a -f status=exited -q)

## 2. Remove Unused Docker Images

docker image prune
docker image prune -a

## 3. Remove Unused Docker Volumes

docker volume prune

## 4. Prune All Unused Docker Resources (One-Line Command)

docker system prune -a --volumes

## 5. Remove All Stopped Containers (Alternate)

docker container prune

## Tips

- Run `docker ps -a` to list all containers (including stopped ones).
- Run `docker images -a` to list all images.
- Run `docker volume ls` to list all volumes.
