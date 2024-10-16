# mobsf_deploy

## Clone the Repository

```bash
# Clone the MobSF deployment repository from GitHub
git clone https://github.com/defencore/mobsf_deploy

# Navigate to the directory containing the deployment files
cd mobsf_deploy

# Run the initialization script to set up the necessary environment
./init_script.sh
```

## Build MobSF Container

```bash
# Build MobSF container
docker build -f Dockerfile -t mobsf_a .
```

## Run MobSF in Docker

```bash
# Run MobSF in a Docker container named "MobSF_A" and expose it on port 8000
# The _output/ folder is mounted to /root/.MobSF/uploads/ for access to scans
docker run --name "MobSF_A" -it -p 8000:8000 -v ./_output/:/root/.MobSF/uploads/ mobsf_a

# Use CTRL+C after the MobSF server boots up to stop it
# This will gracefully stop the container after initialization
```

## Start and Stop the MobSF Container

```bash
# Start the "MobSF_A" container in interactive mode (resumes from where it was stopped)
docker start -i "MobSF_A"

# Stop the "MobSF_A" container (without removing it)
docker stop -i "MobSF_A"
```

## Manage Docker Containers and Images

```bash
# List all containers, both running and stopped
docker ps -a

# List all Docker images available on the system
docker images
```

## Stop and Remove Containers and Images

```bash
# Stop all running containers
docker stop $(docker ps -q)

# Remove all containers, regardless of their state (stopped or running)
docker rm $(docker ps -a -q)

# Remove all Docker images
docker rmi $(docker images -q)

docker builder prune
```

# Changes
## API
### /api/v1/apk/unpack
### /api/v1/apk/analyze
### /api/v1/apk/list
```
curl --url http://127.0.0.1:8000/api/v1/apk/list -H "Authorization: e72372a4d5b01c31d6ef57c4ae738a9251726e025088d13f4ef441fb8bc9ea37"
```

```
{"apk_list": [{"hash": "bb1d34f21a4e65e76186206d9ef92a9a", "file": "com.android.chrome@129.0.6668.81.zip", "package_name": "Unknown"}], "count": 1}%
```