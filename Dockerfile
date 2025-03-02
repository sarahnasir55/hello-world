# Use Node.js UBI image for building the app
FROM registry.access.redhat.com/ubi8/nodejs-18 AS build

# Set working directory
WORKDIR /app

# Ensure correct permissions
RUN mkdir -p /app && chown -R 1001:0 /app

# Switch to OpenShift's default non-root user
USER 1001

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install --unsafe-perm

# Copy the entire project
COPY . .

# Build the React app
RUN npm run build

# Use OpenShift-compatible Nginx image
FROM registry.access.redhat.com/ubi8/nginx-120

# Set working directory for Nginx
WORKDIR /usr/share/nginx/html

# Copy the build output to Nginx's default public folder
COPY --from=build /app/build .

# Set correct permissions (important for OpenShift)
RUN chmod -R 755 /usr/share/nginx/html

# Switch to OpenShift non-root user
USER 1001

# Expose OpenShift-preferred port
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

