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