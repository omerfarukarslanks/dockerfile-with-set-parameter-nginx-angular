FROM node:14.17.1-alpine as build
WORKDIR /app
COPY ./package.json package-lock.json ./ /app/
RUN npm install
COPY ./ .
ARG BUILD_TYPE
#ENV BUILD_TYPE_2 $BUILD_TYPE // Image oluşturulruken ENV değerlerinin default olarak tanımlanması. 
RUN if ["$BUILD_TYPE" == ""] ; then npm run build ; else npm run build-$BUILD_TYPE; fi

FROM nginx:1.20-alpine as final
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/dist/ /usr/share/nginx/html/

EXPOSE 80
CMD ["/bin/sh",  "-c", "envsubst < /usr/share/nginx/html/assets/env.sample.js > /usr/share/nginx/html/assets/env.js && exec nginx -g 'daemon off;'"]
