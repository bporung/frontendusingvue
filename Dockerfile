FROM node:16.3.0-alpine AS build
WORKDIR /app
COPY package.json ./
run npm install
COPY . .
RUN npm run build


FROM nginx:1.21.4-alpine AS prod-stage
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx","-g","daemon off;"]