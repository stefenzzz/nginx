# Stage 1: Build stage to set up the environment
FROM nginx:alpine AS builder

# Add non-root user
RUN addgroup -S -g 1000 appgroup && adduser -S -u 1000 appuser -G appgroup

# Copy NGINX configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Create directories for NGINX and set permissions
RUN mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp && \
    mkdir -p /var/run/nginx && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/cache/nginx /var/run/nginx /var/run/nginx.pid

# Stage 2: Final stage to create the runtime environment
FROM nginx:alpine

# Copy the prepared files and permissions from the builder stage
COPY --from=builder /etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /var/cache/nginx /var/cache/nginx
COPY --from=builder /var/run/nginx /var/run/nginx
COPY --from=builder /var/run/nginx.pid /var/run/nginx.pid

# Copy user and group information from the builder stage
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Ensure permissions are correct
RUN chown -R appuser:appgroup /var/cache/nginx /var/run/nginx /var/run/nginx.pid

# Switch to non-root user
USER appuser

