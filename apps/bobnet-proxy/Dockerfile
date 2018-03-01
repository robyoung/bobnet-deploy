FROM arm32v7/nginx:latest

COPY nginx/bobnet.robyoung.digital.conf /etc/nginx/conf.d/bobnet.robyoung.digital.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/conf.d/default.conf
