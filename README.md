```bash
# Build and run with Docker Compose
docker-compose up --build

# Or build manually
docker build -t calendar-app .
docker run -p 3000:3000 calendar-app
```