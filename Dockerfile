# Minimal python image
FROM python:3.11-slim

# Set environment variables to make apt install non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies for ptouch-print + Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
    build-essential \
    cmake \
    gettext \
    libgd-dev \
    libusb-1.0-0-dev \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Clone and build ptouch-print
RUN git clone https://git.familie-radermacher.ch/linux/ptouch-print.git /opt/ptouch-print \
    && cd /opt/ptouch-print \
    && ./build.sh \
    && make -C build/ install \
    && rm -rf /opt/ptouch-print

# Workdirecotry inside the container
WORKDIR /app

# Copy files into container
COPY . /app

# Update pip
RUN pip install --upgrade pip

# Install python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port the app runs on
EXPOSE 5000

# Command to run the app
CMD ["python", "app.py"]
