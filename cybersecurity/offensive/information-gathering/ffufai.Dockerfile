FROM python:3.9-slim

# Install git and build dependencies
RUN apt-get update && \
    apt-get install -y git python3-dev gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone the repository
RUN git clone https://github.com/GangGreenTemperTatum/ffufai.git /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt cffi

# Create non-root user
RUN useradd -m -r -u 1000 ffufuser && \
    chown -R ffufuser:ffufuser /app
USER ffufuser

EXPOSE 8080

ENTRYPOINT ["python", "/app/ffufai.py"]