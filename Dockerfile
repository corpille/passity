FROM google/dart

WORKDIR /app

ADD pubspec.yaml /app
ADD bin /app/bin
ADD dependencies /app/dependencies
ADD lib /app/lib
RUN pub get
RUN pub upgrade

EXPOSE 8001

CMD []
ENTRYPOINT ["dart", "bin/api.dart"]
