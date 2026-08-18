# ---------- Build stage ----------
FROM node:24-alpine AS builder

WORKDIR /usr/src/app

# Copy dependency files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev

# Copy application source
COPY . .


# ---------- Runtime stage ----------
FROM node:24-alpine AS runtime

# Remove npm from the runtime image
RUN apk del npm 2>/dev/null || true

# Create non-root user
RUN addgroup -S app && adduser -S -G app app

WORKDIR /usr/src/app

# Copy only required application files
COPY --from=builder /usr/src/app/package*.json ./
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/app.js ./app.js

# Run as non-root user
USER app

EXPOSE 3000

CMD ["node", "app.js"]