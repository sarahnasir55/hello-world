# FROM registry.access.redhat.com/ubi8/nodejs-18 AS build

# WORKDIR /app

# RUN mkdir -p /app && chown -R 1001:0 /app

# COPY --chown=1001:0 package.json package-lock.json ./

# USER 1001

# RUN npm install --unsafe-perm

# COPY --chown=1001:0 . .

# RUN npm run build

# FROM registry.access.redhat.com/ubi8/nginx-120

# WORKDIR /usr/share/nginx/html

# COPY --from=build /app/build .

# USER root

# RUN chmod -R 755 /usr/share/nginx/html

# USER 1001

# EXPOSE 8080

# CMD ["nginx", "-g", "daemon off;"]

# Step 1: Build the React app
FROM node:18 as build

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of the app's source code
COPY . .

# Build the app for production
RUN npm run build

# Step 2: Serve the build using a lightweight web server
FROM nginx:alpine

# Copy the build output to Nginx's HTML directory
COPY --from=build /app/build /usr/share/nginx/html

# Copy a custom Nginx config (optional)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose the port Nginx runs on
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
