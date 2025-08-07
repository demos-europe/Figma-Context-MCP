FROM node:18-alpine

# Install dependencies for sharp (image processing)
RUN apk add --no-cache \
    vips-dev \
    build-base \
    python3 \
    make \
    g++

# Create app directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json pnpm-lock.yaml ./

# Install pnpm
RUN npm install -g pnpm@10.10.0

# Install all dependencies (including dev for build)
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Keep dev dependencies for ts runtime
# No build needed, tsx handles TypeScript at runtime

# Expose port
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S figma -u 1001 -G nodejs

# Change ownership of the app directory
RUN chown -R figma:nodejs /usr/src/app
USER figma

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Start the server directly from TypeScript source
CMD ["npx", "tsx", "src/cli.ts"]