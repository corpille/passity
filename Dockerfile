FROM google/dart

WORKDIR /app

ADD pubspec.yaml /app
ADD bin /app/bin
ADD dependencies /app/dependencies
ADD lib /app/lib
RUN pub get
RUN pub upgrade

CMD []
ENTRYPOINT ["dart", "bin/api.dart"]
