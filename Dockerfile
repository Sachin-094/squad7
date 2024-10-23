FROM node:16-alpine AS build

COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /app

COPY . .

RUN if [ ! -f package.json ]; then \
    npm init -y; \
    fi

RUN npm install

FROM nginx:alpine

COPY --from=build /app /usr/share/nginx/html

EXPOSE 3001

CMD ["nginx", "-g", "daemon off;"]
