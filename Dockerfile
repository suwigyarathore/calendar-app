# syntax=docker/dockerfile:1.7

FROM node:20-alpine AS base
RUN npm i -g pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .

FROM base AS builder
RUN pnpm build

FROM node:20-alpine AS runner
RUN npm i -g pnpm
WORKDIR /app

# Create non-root user/group with fixed IDs
RUN addgroup -S -g 1001 nodejs \
 && adduser -S -u 1001 -G nodejs calendar-app

# Copy build output (use numeric chown to avoid name lookup issues)
COPY --from=builder --chown=1001:1001 /app/.next/standalone ./
COPY --from=builder --chown=1001:1001 /app/.next/static ./.next/static
COPY --from=builder --chown=1001:1001 /app/public ./public

USER 1001:1001
EXPOSE 3000
ENV NODE_ENV=production PORT=3000 HOSTNAME=0.0.0.0
CMD ["node", "server.js"]
