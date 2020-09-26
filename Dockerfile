FROM node:12-alpine
COPY . /app
WORKDIR /app

RUN npm i
RUN npm audit fix
EXPOSE 3000
CMD npx elm-app start