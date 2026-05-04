# Stage 1 — Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copier uniquement les fichiers de dépendances d'abord (cache Docker)
COPY package*.json ./

# Installer seulement les dépendances de production
RUN npm ci --only=production

# Stage 2 — Image finale légère
FROM node:20-alpine

WORKDIR /app

# Copier les dépendances depuis le builder
COPY --from=builder /app/node_modules ./node_modules

# Copier le code source
COPY src/ ./src/
COPY config/ ./config/
COPY package.json ./

# Exposer le port de l'API
EXPOSE 3000

# Lancer l'application
CMD ["node", "src/index.js"]
