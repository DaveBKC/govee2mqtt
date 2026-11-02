# Test build of govee2mqtt from a fork branch, compiled on this machine.
ARG BUILD_FROM
FROM rust:1-bookworm AS builder
ARG REPO=https://github.com/DaveBKC/govee2mqtt.git
ARG BRANCH=kettle-out-of-water
RUN git clone --depth 1 --branch "$BRANCH" "$REPO" /src
WORKDIR /src
RUN cargo build --release --locked

FROM $BUILD_FROM
COPY run.sh /run.sh
RUN chmod +x /run.sh
COPY --from=builder /src/target/release/govee /app/govee
COPY --from=builder /src/assets /app/assets/
COPY --from=builder /src/AmazonRootCA1.pem /app/
CMD [ "/run.sh" ]
