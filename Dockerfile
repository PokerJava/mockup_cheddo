# FROM node:8.12-alpine AS builder

# COPY package*.json /
# RUN apk update && apk add git \
#   && apk add gettext \
#   && npm install && mkdir /app \
#   && cp -r node_modules /app/

# ARG BUILD_ENV
# ARG VERSION
# ARG DATE_VERSION
# ARG COMMIT_NO

# WORKDIR /app
# COPY . .

# RUN envsubst '${VERSION},${DATE_VERSION},${COMMIT_NO}' < ./src/assets/config/app.config.${BUILD_ENV}.json > ./src/assets/config/app.config.${BUILD_ENV}.json

# RUN $(npm bin)/ng build --configuration=${BUILD_ENV}  --prod


FROM node:8-alpine
ENV TZ=Asia/Bangkok

RUN apk --no-cache add g++ gcc libgcc libstdc++ linux-headers make python
RUN npm install --quiet node-gyp -g

RUN apk add tzdata \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
  && echo $TZ > /etc/timezone \
  && npm install \
  && mkdir -p /app/ssl

ARG CONTAINER_PORT
ARG PM2_FILE
ENV PM2_FILE ${PM2_FILE}
WORKDIR /app/

COPY . /app

RUN npm install -g pm2 && npm install express express-winston winston && npm install

EXPOSE ${CONTAINER_PORT}

CMD pm2 start ${PM2_FILE} --no-daemon

#
FROM node:8-alpine
ENV TZ=Asia/Bangkok

RUN apk --no-cache add g++ gcc libgcc libstdc++ linux-headers make python
RUN npm install --quiet node-gyp -g

RUN apk add tzdata \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
  && echo $TZ > /etc/timezone \
  && npm install \
  && mkdir -p /app/ssl

ARG CONTAINER_PORT
ARG PM2_FILE
ENV PM2_FILE ${PM2_FILE}
WORKDIR /app/

COPY . /app

RUN npm install -g pm2 && npm install express express-winston winston && npm install

EXPOSE 9011

CMD pm2 start ${PM2_FILE} --no-daemon