# Stage 1 — Install dependencies
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2 — Runtime
FROM node:18-alpine
WORKDIR /app

# Create non-root user for security
RUN addgroup -S epicbook && adduser -S epicbook -G epicbook

# Copy only production dependencies from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy application source
COPY . .

# Set ownership
RUN chown -R epicbook:epicbook /app

USER epicbook

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget -qO- http://localhost:8080/ || exit 1

CMD ["node", "server.js"]
