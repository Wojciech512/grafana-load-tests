FROM node:lts-alpine

RUN apk add --no-cache \
    bash \
    git \
    make \
    g++ \
    && npm install -g typescript webpack webpack-cli ts-loader

WORKDIR /app

COPY ./package.json ./package-lock.json ./

RUN npm install

COPY ./load-tests/tests /app/tests

RUN tsc

CMD ["k6", "run", "/app/dist/ecommerce-test.ts"]
