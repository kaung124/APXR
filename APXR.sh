#!/bin/bash

echo "------------------------------------------"
echo "🔧 Starting APXR SERVER Setup..."
echo "------------------------------------------"

# Update and upgrade Termux packages
echo "📦 Updating Termux packages..."
pkg update -y && pkg upgrade -y
echo "✅ Packages updated successfully!"

# Install Python and necessary libraries
echo "🐍 Installing Python and essential libraries..."
pkg install -y python clang libffi openssl
echo "✅ Python and libraries installed!"

# Setup Termux storage if not already set
if [ ! -d "/sdcard" ]; then
    echo "📂 Setting up Termux storage access..."
    termux-setup-storage
    echo "✅ Storage setup complete! Please grant storage permissions if prompted."
else
    echo "📂 Storage already configured!"
fi

# Upgrade pip and install virtualenv
echo "⬆️ Upgrading pip and installing virtualenv..."
pip install --upgrade pip
pip install virtualenv
echo "✅ pip and virtualenv installed!"

# Navigate to the directory where app.py is located
APP_DIR="/sdcard/ATOM_POINT_EXCHANGER/data"
echo "📁 Navigating to application directory: $APP_DIR"
cd "$APP_DIR" || { echo "❌ Directory $APP_DIR not found! Exiting."; exit 1; }
echo "✅ Successfully navigated to $APP_DIR"

# Create and activate a virtual environment
echo "🔒 Checking for existing virtual environment..."
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found! Creating a new one..."
    python -m venv venv
    echo "✅ Virtual environment created!"
else
    echo "✅ Virtual environment already exists!"
fi

echo "🚀 Activating virtual environment..."
# Ensure you're using bash or replace source with .

# Install Flask and Gunicorn in the virtual environment
echo "📦 Installing Flask and Gunicorn..."
pip install Flask gunicorn requests concurrent.futures gevent 
echo "✅ Flask and Gunicorn installed!"

# Create Gunicorn configuration file (optional but good practice)
echo "🛠️ Creating Gunicorn configuration file..."
cat <<EOF > gunicorn_config.py
bind = "0.0.0.0:5000"
workers = 10
worker_class = "gevent"
EOF
echo "✅ Gunicorn configuration file created!"

# Add the auto-start command to .bashrc if not already added
AUTO_START_CMD="cd $APP_DIR && gunicorn --log-level debug -c gunicorn_config.py loader:app"

if ! grep -Fxq "$AUTO_START_CMD" ~/.bashrc; then
    echo "⚙️ Configuring auto-start on Termux launch..."
    echo "$AUTO_START_CMD" >> ~/.bashrc
    echo "✅ Auto-start setup complete!"
else
    echo "⚙️ Auto-start already configured!"
fi

# Run the Flask app using Gunicorn with debug logs
echo "🚀 Starting the Flask app with Gunicorn in Debug mode..."
export FLASK_ENV=development
gunicorn --log-level debug -c gunicorn_config.py loader:app
