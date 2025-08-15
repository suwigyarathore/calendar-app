# Production stage
FROM node:20-alpine AS runner

RUN npm install -g pnpm
WORKDIR /app

# Create non-root user (Alpine style)
RUN addgroup -S -g 1001 nodejs \
 && adduser  -S -u 1001 -G nodejs calendar-app

# Copy built application (own it by UID:GID to avoid name lookup issues)
COPY --from=builder --chown=1001:1001 /app/.next/standalone ./
COPY --from=builder --chown=1001:1001 /app/.next/static ./.next/static
COPY --from=builder --chown=1001:1001 /app/public ./public

# Switch to non-root user (use numeric to be extra safe)
USER 1001:1001

EXPOSE 3000
ENV NODE_ENV=production
ENV PORT=3000
CMD ["node", "server.js"]
