# 🐳 Push to Docker Hub Instructions

## Step 1: Login to Docker Hub
```bash
docker login
```
Enter your Docker Hub username and password when prompted.

## Step 2: Tag Your Image
Replace `YOUR_DOCKERHUB_USERNAME` with your actual Docker Hub username:

```bash
docker tag inventory-app YOUR_DOCKERHUB_USERNAME/inventory-management:latest
```

Example:
```bash
docker tag inventory-app johndoe/inventory-management:latest
```

## Step 3: Push to Docker Hub
```bash
docker push YOUR_DOCKERHUB_USERNAME/inventory-management:latest
```

Example:
```bash
docker push johndoe/inventory-management:latest
```

## Step 4: Verify Upload
Check your Docker Hub repository at: https://hub.docker.com/r/YOUR_DOCKERHUB_USERNAME/inventory-management

## Alternative: Tag with Version
You can also tag with a specific version:
```bash
docker tag inventory-app YOUR_DOCKERHUB_USERNAME/inventory-management:v1.0.0
docker push YOUR_DOCKERHUB_USERNAME/inventory-management:v1.0.0
```

## Complete Example Commands
```bash
# Login
docker login

# Tag (replace 'yourusername' with your actual username)
docker tag inventory-app yourusername/inventory-management:latest

# Push
docker push yourusername/inventory-management:latest
```