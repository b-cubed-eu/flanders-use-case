# Use official R image
FROM r-base:latest

# Create a working directory in the container
WORKDIR /usr/src/app

# Copy the R script into the container
COPY script.R .

# Run the script when the container starts
CMD ["Rscript", "script.R"]