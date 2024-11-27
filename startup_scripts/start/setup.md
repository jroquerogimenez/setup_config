Needed to give permissions to the docker daemon

sudo chmod 666 /var/run/docker.sock

Needed to change ownership of /usr/local/lib

sudo chown -R $USER /usr/local/

# Access amazon ECR

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 677993236947.dkr.ecr.us-east-1.amazonaws.com
