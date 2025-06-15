#!/bin/bash

# Update system and install dependencies
sudo yum update -y
sudo amazon-linux-extras install -y nginx1 docker
sudo yum install -y git

# Install Node.js 20
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

# Configure Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# Clone both repositories
cd /home/ec2-user
sudo git clone https://github.com/Khhafeez47/reactapp.git
sudo git clone https://github.com/Khhafeez47/nodejs-iba.git
sudo chown -R ec2-user:ec2-user reactapp nodejs-iba

# ===== REACT APP SETUP =====
cd /home/ec2-user/reactapp

# Create Dockerfile for React app
cat << 'EOF' > Dockerfile
FROM node:20-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create Nginx config for React
mkdir -p nginx
cat <<EOF > nginx/nginx.conf
server {
    listen 80;
    server_name localhost;
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# Build and run React container
docker build -t react-app .
docker run -d -p 3000:80 --name react-container react-app

# ===== NODE.JS APP SETUP =====
cd /home/ec2-user/nodejs-iba

# Add health check endpoint (critical for ALB)
if ! grep -q "/api/health" index.js; then
    cat <<EOF >> index.js

// Health check endpoint for ALB
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});
EOF
fi

# Build and run Node.js container
docker build -t nodeapp .
docker run -d -p 4000:5000 --name nodeapp-container nodeapp

# ===== NGINX REVERSE PROXY =====
cat <<EOF | sudo tee /etc/nginx/conf.d/app.conf
upstream react_app {
    server 127.0.0.1:3000;
}

upstream node_app {
    server 127.0.0.1:4000;
}

server {
    listen 80;
    server_name ummul-project.apparelcorner.shop;

    # React frontend
    location / {
        proxy_pass http://react_app;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # Node.js backend with health check
    location /api {
        proxy_pass http://node_app;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Enable and restart services
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "Deployment complete!"
echo "React running on port 3000 (accessible via /)"
echo "Node.js running on port 4000 (accessible via /api)"
echo "Health check endpoints:"
echo "- React: http://localhost:3000/"
echo "- Node.js: http://localhost:4000/api/health"