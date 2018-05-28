FROM arm32v6/alpine

RUN apk update \
  && apk add curl jq httpie 

ADD setup.sh .

CMD ["/setup.sh"]
