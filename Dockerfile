# Stage 1: Build the VITE app
FROM node:20 as build
WORKDIR /app
# Copy package.json and lock file
COPY package*.json ./
# Install dependencies
RUN npm install
# Copy the app's source code
COPY . .
# Build the app
RUN npm run build
# Stage 2: Serve the built app using Nginx
FROM nginx:alpine
# Copy the built files to the Nginx directory
COPY --from=build /app/dist /usr/share/nginx/html
# Expose port 80
EXPOSE 80
# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
