#! /bin/bash 
sudo apt update 
sudo apt install -y nginx 
echo "<h1>Welcome to the test website</h1>" | sudo tee /var/www/mysite/index.html
echo "{
       listen 81;
       listen [::]:81;

       server_name mysite;

       root /var/www/mysite;
       index index.html;

       location / {
               try_files $uri $uri/ =404;
       }
}" | sudo tee /etc/nginx/sites-enabled/mysite
sudo service nginx restart
sudo apt install -y mysql-client
export USER_NAME=admin 
export PASSWORD=$PASSWORD
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7BLAHAAA
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYBLAAHKEY
export AWS_DEFAULT_REGION=us-west-2