#!/bin/bash

dnf update
dnf install git -y
su ec2-user -c 'git clone https://github.com/thedojoseries/nodejs-app.git /home/ec2-user/nodejs-app'

cat <<EOF >>/home/ec2-user/install.sh
#!/bin/bash

# The userdata script runs as root. However, we do not want the app to be run as root, so this script needs to make sure it is installing
# Installs NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
. ~/.nvm/nvm.sh

# Installs Node.js v20.10.0 and NPM v10.2.3
nvm install 20.10.0

# Confirms the Node.js and NPM versions
node -e "console.log('Running Node.js ' + process.version)"

# Changes directory into nodejs-app
cd /home/ec2-user/nodejs-app

# Installs Express.js as dependency
cd /home/ec2-user/nodejs-app && npm i
EOF

chown ec2-user:ec2-user /home/ec2-user/install.sh
chmod +x /home/ec2-user/install.sh
su ec2-user -c '/home/ec2-user/install.sh'

cat <<EOF >>/home/ec2-user/run.sh
#!/bin/bash

# Sends a request to the Instance Metadata Service version 2
# to obtain the instance's private IP address
TOKEN=\`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"\`
priv_ip=\`curl -H "X-aws-ec2-metadata-token: \$TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4\`

# Runs the Node.js app passing the instance's private IP as environment variable
. ~/.nvm/nvm.sh && PRIV_IP=\$priv_ip node /home/ec2-user/nodejs-app/index.js
EOF

chown ec2-user:ec2-user /home/ec2-user/run.sh
chmod +x /home/ec2-user/run.sh
su ec2-user -c '/home/ec2-user/run.sh'
