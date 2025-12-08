# ================================
# MindLab multi-stage Dockerfile
# ================================

# ---- Build frontend ----
FROM node:22 AS frontend
WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ .
RUN npm run build

# ---- Build backend ----
FROM node:22 AS backend
WORKDIR /app/backend

COPY backend/package*.json ./
RUN npm ci

COPY backend/ .

# Copy frontend dist into backend/static
RUN mkdir -p backend/static
COPY --from=frontend /app/frontend/dist/ /app/backend/static/

# ---- Runtime image ----
FROM node:22-slim
WORKDIR /app/backend

# Copy app from backend stage
COPY --from=backend /app/backend/ .

EXPOSE 8085

CMD ["node", "src/server.cjs"]
