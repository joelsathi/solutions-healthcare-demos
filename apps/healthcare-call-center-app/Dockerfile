# Build stage - using latest LTS version
FROM node:24-alpine AS builder

# Install bun
RUN npm install -g bun

WORKDIR /app

# Copy package files
COPY package.json bun.lockb ./

# Install dependencies
RUN bun install lockfile

# Copy source code
COPY . .

# Build with default/placeholder values - real values will be injected at runtime

# Build the application
RUN bun run build

# Production stage - serve with nginx
FROM nginx:alpine AS runner

# Install envsubst and other utilities
RUN apk add --no-cache gettext

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built application from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Create template for runtime env injection
RUN mkdir -p /app/templates
COPY --from=builder /app/dist/index.html /app/templates/index.html.template

# Copy docker entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Create a non-root user
RUN addgroup -g 10001 -S appuser && \
    adduser -u 10001 -S appuser -G appuser

# Change ownership of nginx files
RUN chown -R appuser:appuser /usr/share/nginx/html && \
    chown -R appuser:appuser /var/cache/nginx && \
    chown -R appuser:appuser /var/log/nginx && \
    chown -R appuser:appuser /etc/nginx/conf.d && \
    chown -R appuser:appuser /app/templates

# Make sure nginx can write to required directories
RUN touch /var/run/nginx.pid && \
    chown -R appuser:appuser /var/run/nginx.pid

# Switch to non-root user
USER 10001

# Expose port 8080 (matching your vite config)
EXPOSE 8080

# Use custom entrypoint to inject runtime env vars
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]