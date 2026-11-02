# Test build of govee2mqtt from a fork branch, compiled on this machine.
ARG BUILD_FROM
FROM rust:1-bookworm AS builder
ARG REPO=https://github.com/DaveBKC/govee2mqtt.git
# Pinned commit on the kettle-out-of-water branch; bumping it makes
# Home Assistant rebuild instead of reusing a cached checkout.
ARG COMMIT=806169a3
WORKDIR /src
RUN git init -q . && git remote add origin "$REPO" \
 && git fetch -q --depth 1 origin kettle-out-of-water \
 && git checkout -q FETCH_HEAD \
 && git log --oneline -1 | grep -q "^${COMMIT}"
RUN cargo build --release --locked

FROM $BUILD_FROM
COPY run.sh /run.sh
RUN chmod +x /run.sh
COPY --from=builder /src/target/release/govee /app/govee
COPY --from=builder /src/assets /app/assets/
COPY --from=builder /src/AmazonRootCA1.pem /app/
CMD [ "/run.sh" ]
