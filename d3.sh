#!/bin/env bash
for dockerimage in $(awk -F '"' '/tags/ { print $2 }' docker-bake.hcl) ; do
        service=$(echo "$dockerimage" | sed -E 's/[a-z0-9]+-[a-z0-9]+-([a-z0-9]+)(-[0-9]+|:).*$/\1/')
        echo "$service"
                container_name="$USER-$service"

                docker run -tid --privileged \
                -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
                --name "$container_name" \
                --cgroupns host \
                -h "t$container_name" \
                "$image_tag" >/dev/null

                docker exec "$container_name" useradd -m -s /bin/bash -p sa3tHJ3/KuYvI "$USER"
                docker exec "$container_name" bash -c "mkdir -p /home/$USER/.ssh && chmod 700 /home/$USER/.ssh && chown -R $USER:$USER /home/$USER/.ssh"
                docker cp "$SSH_KEY_FILE" "$container_name:/home/$USER/.ssh/authorized_keys"
                docker exec "$container_name" bash -c "chmod 600 /home/$USER/.ssh/authorized_keys && chown $USER:$USER /home/$USER/.ssh/authorized_keys"
                docker exec "$container_name" bash -c "echo '$USER ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/$USER"
                docker exec "$container_name" bash -c "systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null || service ssh restart 2>/dev/null"

                echo "Conteneur $container_name créé."


done