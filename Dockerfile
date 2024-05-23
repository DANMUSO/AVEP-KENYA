# Start with the official PHP image with Apache
FROM php:8.1.0-apache

# Set the working directory in the container
WORKDIR /var/www/html

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Update package list and install dependencies
RUN apt-get update -y && apt-get install -y \
    libicu-dev \
    libmariadb-dev \
    unzip \
    zip \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    curl  # Adding curl as it is required for the Node.js install script

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && node -v \
    && npm -v

# Copy Composer from official Composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install necessary PHP extensions
RUN docker-php-ext-install gettext intl pdo_mysql

# Configure and install the GD library
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Clean up to reduce layer size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
