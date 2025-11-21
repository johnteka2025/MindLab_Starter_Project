FROM node:20-alpine
WORKDIR /app

# Copy backend
COPY backend ./backend
WORKDIR /app/backend

# Install production deps if package.json exists
RUN if [ -f package.json ]; then npm ci --omit=dev || npm install --omit=dev; fi

# Add curl for healthchecks and debugging
RUN apk add --no-cache curl

ENV PORT=8085
EXPOSE 8085

CMD ["node","server.js"]
