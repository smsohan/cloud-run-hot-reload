#!/bin/bash

# This function will be executed when the script receives a SIGINT or SIGTERM signal.
cleanup() {
    echo "Caught signal, shutting down gracefully..."
    # Kill all background processes that are children of this script.
    # The 'jobs -p' command lists the PIDs of all background jobs.
    kill $(jobs -p)
    # Wait for all background processes to terminate.
    wait
    echo "Shutdown complete."
}

# Register the 'cleanup' function to be called on SIGINT and SIGTERM.
trap cleanup SIGINT SIGTERM

# Start the file_handler API in the background.
echo "Starting file_handler service..."
cd /app/file_handler
npm start &

# Start the applet in the background.
echo "Starting applet service..."
cd /app/applet
npm run dev &

# Start nginx in the background.
echo "Starting nginx..."
nginx -g 'daemon off;' &

# Wait for any of the background processes to exit.
# If one of them crashes, the script will proceed to the cleanup step.
wait -n

# If any process exits, run the cleanup function to stop the others.
echo "A process has exited. Cleaning up the remaining processes..."
cleanup
