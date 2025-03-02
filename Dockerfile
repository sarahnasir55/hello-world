# Use Node.js UBI image for building the app
FROM registry.access.redhat.com/ubi8/nodejs-18 AS build

# Set working directory
WORKDIR /app

# Ensure correct permissions for the directory and files
RUN mkdir -p /app && chown -R 1001:0 /app

# Copy package.json and package-lock.json separately to leverage Docker caching
COPY --chown=1001:0 package.json package-lock.json ./

# Switch to OpenShift's default non-root user
USER 1001

# Install dependencies
RUN npm install --unsafe-perm

# Copy the entire project
COPY --chown=1001:0 . .

# Build the React app
RUN npm run build

# Use OpenShift-compatible Nginx image
FROM registry.access.redhat.com/ubi8/nginx-120

# Set working directory for Nginx
WORKDIR /usr/share/nginx/html

# Copy the build output to Nginx's default public folder
COPY --from=build /app/build .

# Ensure proper permissions
RUN chmod -R 755 /usr/share/nginx/html

# Expose port 8080 for OpenShift
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]