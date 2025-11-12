# Specify a base image
FROM node:20-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json first (for better Docker layer caching)
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Default command to run the application
CMD ["npm", "start"]

# Explicacion porque usamos COPY package.json ./ y luego COPY . .
# Escenario común: Cambias index.js pero NO cambias dependencias

# ✅ Capa 1 (package.json): Sin cambios → Usa caché
# ✅ Capa 2 (npm install): Sin cambios → Usa caché (¡Se ahorra minutos!)
# ❌ Capa 3 (código): Cambió → Se reconstruye