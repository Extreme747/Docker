FROM ubuntu:22.04

# 1. Install dependencies (CURL, Unzip, Libs)
RUN apt-get update && \
    apt-get install -u -y curl unzip libcurl4 openssl && \
    rm -rf /var/lib/apt/lists/*

# 2. Setup Work Directory
WORKDIR /data

# 3. Download Minecraft Bedrock Server
# NOTE: User specified 1.21.132.1. Make sure this URL matches the exact linux server zip for that version.
# If that specific version isn't public yet, use the latest stable link.
# Below is a command to curl the header specific version, usually you need the exact zip link.
# Since 1.21.132.1 is super new/preview, double check the link. I'll use a placeholder for the URL.
ENV MC_URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-1.21.50.07.zip" 
# ^ REPLACE THIS LINK with the direct download link for 1.21.132.1 if you have it!

RUN curl -L -o server.zip $MC_URL && \
    unzip server.zip && \
    rm server.zip

# 4. Install Playit.gg (The Secret Sauce for UDP)
RUN curl -SSL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | tee /etc/apt/sources.list.d/playit.list && \
    apt-get update && \
    apt-get install -y playit

# 5. Expose the port (Internal)
EXPOSE 19132/udp

# 6. The Startup Script
# We run LD_LIBRARY_PATH so Bedrock finds its libs, start the server in background, then start playit.
CMD LD_LIBRARY_PATH=. ./bedrock_server & playit
