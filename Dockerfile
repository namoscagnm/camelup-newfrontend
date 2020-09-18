FROM node:12.18.4-alpine
COPY . /app
WORKDIR /app

RUN npm i
CMD npx elm-app start