# Use the official Node.js 22 image.
FROM node:22-slim

# Install nginx
RUN apt-get update && apt-get install -y nginx

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json for file_handler and install dependencies
COPY file_handler/package*.json ./file_handler/
RUN cd file_handler && npm install

# Copy package.json and package-lock.json for applet and install dependencies
COPY applet/package*.json ./applet/
RUN cd applet && npm install

# Copy the rest of the application code
COPY file_handler/ ./file_handler/
COPY applet/ ./applet/

# Copy the nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the start script
COPY start.sh .

# Make the start script executable
RUN chmod +x ./start.sh

# Expose the port nginx is listening on
EXPOSE 8080

# Start the services
CMD ["./start.sh"]
