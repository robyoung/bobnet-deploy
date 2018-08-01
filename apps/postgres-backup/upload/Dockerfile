FROM arm32v6/python:3.6-alpine3.7

RUN pip install awscli

COPY upload.sh /upload.sh

CMD ["/upload.sh"]
