## SSH setup

ssh-keygen -t ed25519 -C "RGTechMain_GitHub"

Stored in ~/.ssh as id_ed25519 and id_ed25519.pub.
Upload id_ed25519.pub to Github, check with ssh -T git@github.com

## Git setup

git config --global init.defaultBranch main
git config --global user.name "Jaime Roquero"
git config --global user.email jaime.roquero@gmail.com

## AWS setup

Need to generate from AWS both AWS Access Key ID and AWS Secret Access Key.

aws configure

Stored in ~/.aws/credentials

## SSL certificate for Jupyter notebooks

Create folder ~/ssl/

openssl req -x509 -noenc -days 365 -newkey rsa:2048 -keyout mykey.key -out mycert.pem
