FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    libssl3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download Playit.gg
RUN wget -O /usr/local/bin/playit https://github.com/playit-cloud/playit-agent/releases/download/v0.15.0/playit_0.15.0_linux_amd64 \
    && chmod +x /usr/local/bin/playit

# Download Minecraft Bedrock Server
WORKDIR /bedrock-server
RUN wget -O bedrock-server.zip https://minecraft.azureedge.net/bin-linux/bedrock-server-1.21.51.01.zip \
    && unzip bedrock-server.zip \
    && rm bedrock-server.zip \
    && chmod +x bedrock_server

# Create startup script
RUN echo '#!/bin/bash\n\
cd /bedrock-server\n\
./bedrock_server &\n\
sleep 10\n\
if [ -n "$PLAYIT_SECRET" ]; then\n\
    mkdir -p /etc/playit\n\
    echo "$PLAYIT_SECRET" > /etc/playit/secret\n\
    playit --secret /etc/playit/secret\n\
else\n\
    playit\n\
fi\n\
wait' > /start.sh && chmod +x /start.sh

EXPOSE 19132/udp

CMD ["/start.sh"]
