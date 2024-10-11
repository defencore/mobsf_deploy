# mobsf_deploy

```
# Clone the MobSF deployment repository from GitHub
git clone https://github.com/defencore/mobsf_deploy

# Navigate to the directory containing the deployment files
cd mobsf_deploy

# Run the initialization script to set up the necessary environment
./init_script.sh
```

```
# Run MobSF in a Docker container named "MobSF_A" and expose it on port 8000
# The _output/ folder is mounted to /root/.MobSF/uploads/ for access to scans
docker run --name "MobSF_A" -it -p 8000:8000 -v ./_output/:/root/.MobSF/uploads/ mobsf_a
# Use CTRL+C after the MobSF server boots up to stop it
# This will gracefully stop the container after initialization
```

```
# Start the "MobSF_A" container in interactive mode (resumes from where it was stopped)
docker start -i "MobSF_A"

# Stop the "MobSF_A" container (without removing it)
docker stop -i "MobSF_A"
```

```
# List all containers, both running and stopped
docker ps -a

# List all Docker images available on the system
docker images
```

```
# Stop all running containers
docker stop $(docker ps -q)

# Remove all containers, regardless of their state (stopped or running)
docker rm $(docker ps -a -q)

# Remove all Docker images
docker rmi $(docker images -q)
```
