# Update the package list:
sudo apt update


# Install NGINX:
sudo apt install nginx -y


# Start and enable NGINX to run on boot:
sudo systemctl start nginx
sudo systemctl enable nginx


#Verify NGINX is running:
sudo systemctl status nginx



