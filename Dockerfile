# --- Etapa 1: Construcción (Builder) ---
# Usar una imagen oficial de Node.js como base.
# Especifica una versión LTS de Node para consistencia, ej: 18-alpine
FROM node:slim AS builder

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar package.json y package-lock.json (o yarn.lock)
# Copiarlos primero aprovecha el cache de Docker si no cambian
COPY package.json package-lock.json* ./
# Si usas yarn:
# COPY package.json yarn.lock ./

# Instalar dependencias del proyecto
# 'npm ci' es generalmente recomendado para CI/CD porque usa el package-lock.json
RUN npm ci
# Si usas yarn:
# RUN yarn install --frozen-lockfile

# Copiar el resto de los archivos del proyecto
COPY . .

# Construir la aplicación para producción
# Esto debería generar una carpeta 'dist' (o como esté configurado en vite.config.js)
RUN npm run build
# Si usas yarn:
# RUN yarn build

# --- Etapa 2: Servidor (Runner) ---
# Usar una imagen oficial de Nginx como base.
FROM nginx:alpine

# Eliminar la configuración por defecto de Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copiar nuestra configuración personalizada de Nginx (la crearemos a continuación)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar los archivos construidos desde la etapa 'builder' al directorio web de Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# Exponer el puerto 80 (Nginx escucha en este puerto por defecto)
EXPOSE 80

# Comando para iniciar Nginx cuando el contenedor arranque
CMD ["nginx", "-g", "daemon off;"]