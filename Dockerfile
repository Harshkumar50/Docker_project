# Use official Nginx image
FROM nginx:alpine

# Remove the default Nginx website content
RUN rm -rf /usr/share/nginx/html/*

# Copy all contents of the current directory (your website) to Nginx web root
COPY . /usr/share/nginx/html

# Expose port 80 for web traffic
EXPOSE 80

# Start Nginx from docker
CMD ["nginx", "-g", "daemon off;"]
