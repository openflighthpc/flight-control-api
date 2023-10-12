echo "Preparing..."
mkdir "$RUN_ENV/nodes"

echo "Creating login1..."
cat <<EOF > "$RUN_ENV/nodes/login1"
---
name: login1
state: on
tags:
  - type: login
EOF

for int in {01..03}
do
  name="cnode$int"
  echo "Creating $name..."

  cat <<EOF > "$RUN_ENV/nodes/$name"
---
name: $name
state: on
tags:
    - type: compute
EOF
done

# Download yq for parsing YAML and JSON
echo "wgetting yq"
mkdir "$RUN_ENV/bin"
wget https://github.com/mikefarah/yq/releases/download/v4.35.2/yq_linux_amd64 -P "$RUN_ENV/bin"
chmod +x "$RUN_ENV/bin/yq_linux_amd64"

sleep 3
echo "Prepared"
