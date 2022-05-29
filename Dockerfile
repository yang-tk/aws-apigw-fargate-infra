FROM azul/zulu-openjdk:11.0.10

WORKDIR /app

COPY ./build/libs/demoapp-0.1-all.jar .

EXPOSE 8080

CMD ["java", "-jar", "demoapp-0.1-all.jar"]