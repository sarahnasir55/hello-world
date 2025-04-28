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


FROM node:18 as build

WORKDIR /app

# Install only production dependencies
COPY package.json package-lock.json ./
RUN npm ci --only=production  # much lighter than `npm install`

COPY . .

RUN npm run build

FROM docker.io/library/nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
