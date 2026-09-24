# Stage 1: Build Flutter Web
FROM ghcr.io/cirrusci/flutter:3.29.0 AS builder

WORKDIR /app

# Copy dependency manifests
COPY pubspec.yaml pubspec.lock ./

# Fetch dependencies
RUN flutter pub get

# Copy full application code
COPY . .

# Build web release
RUN flutter build web --release

# Stage 2: Serve static files with Nginx
FROM nginx:alpine AS runner

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
