FROM node:20-slim

RUN apt-get update -q && apt-get install -y -q strace && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Non-root user so --dangerously-skip-permissions isn't blocked by the root guard
RUN useradd -m testuser

# Place managed settings in a non-/etc location and symlink into the expected path
RUN mkdir -p /opt/claude-config && mkdir -p /etc/claude-code
COPY managed-settings.json /opt/claude-config/managed-settings.json
RUN ln -s /opt/claude-config/managed-settings.json /etc/claude-code/managed-settings.json
RUN chown -R testuser /opt/claude-config
USER testuser
WORKDIR /home/testuser

COPY --chown=testuser test.sh /home/testuser/test.sh
COPY --chown=testuser greetings.md /home/testuser/greetings.md
COPY --chown=testuser secrets.md /home/testuser/secrets.md
RUN chmod +x /home/testuser/test.sh

CMD ["bash", "/home/testuser/test.sh"]
