    FROM node:22-alpine AS base
    WORKDIR /app

    COPY package.json package-lock.json ./
    RUN npm ci

    FROM base AS test
    WORKDIR /app
    COPY . .
    RUN npm run test

    FROM base AS dev
    WORKDIR /app
    COPY . .
    EXPOSE 3000
    CMD ["npm", "run", "dev"]

    FROM base AS build
    WORKDIR /app
    COPY . .
    RUN npm run build

    FROM nginx:stable-alpine AS production
    COPY nginx.conf /etc/nginx/conf.d/default.conf
    COPY --from=build /app/dist /usr/share/nginx/html
    EXPOSE 80
    CMD ["nginx", "-g", "daemon off;"]