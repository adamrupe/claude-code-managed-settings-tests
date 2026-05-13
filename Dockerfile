FROM node:20-slim

RUN apt-get update -q && apt-get install -y -q strace && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Place managed settings where Claude Code reads them on Linux
RUN mkdir -p /etc/claude-code
COPY first-settings.json /etc/claude-code/managed-settings.json

# Non-root user so --dangerously-skip-permissions isn't blocked by the root guard
RUN useradd -m testuser
USER testuser
WORKDIR /home/testuser

COPY --chown=testuser test.sh /home/testuser/test.sh
COPY --chown=testuser greetings.md /home/testuser/greetings.md
COPY --chown=testuser secrets.md /home/testuser/secrets.md
RUN chmod +x /home/testuser/test.sh

CMD ["bash", "/home/testuser/test.sh"]
