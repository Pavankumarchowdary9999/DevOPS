# Stage 1: compile and create jar
FROM eclipse-temurin:17-jdk as builder

WORKDIR /src
COPY testfile.java /src/

# compile and produce a runnable jar with Main-Class set to 'testfile'
RUN javac /src/testfile.java \
 && jar cfe /app/testfile.jar testfile -C /src .

# Stage 2: runtime image
FROM eclipse-temurin:17-jre

COPY --from=builder /app/testfile.jar /app/testfile.jar
WORKDIR /app
ENTRYPOINT ["java","-jar","/app/testfile.jar"]
