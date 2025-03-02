# Use Node.js for building the app
FROM registry.access.redhat.com/ubi8/nodejs-18 AS build

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the entire project
COPY . .

# Build the React app
RUN npm run build

# Use Nginx to serve the app
FROM registry.access.redhat.com/ubi8/nginx-120

# Copy the build output to Nginx's default public folder
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
