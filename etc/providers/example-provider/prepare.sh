echo "Preparing..."

# Set up instance types and costs
echo "Creating instance types"
mkdir "$RUN_ENV/instance_types"
cat <<EOF > "$RUN_ENV/instance_types/compute_small.yaml"
---
name: compute_small
cost_per_hour: 5
EOF

cat <<EOF > "$RUN_ENV/instance_types/compute_large.yaml"
---
name: compute_large
cost_per_hour: 10
EOF

cat <<EOF > "$RUN_ENV/instance_types/login.yaml"
---
name: login
cost_per_hour: 5
EOF

cat <<EOF > "$RUN_ENV/instance_types/gpu.yaml"
---
name: gpu
cost_per_hour: 20
EOF


# Set up login node
mkdir "$RUN_ENV/nodes"

echo "Creating login1..."
cat <<EOF > "$RUN_ENV/nodes/login1.yaml"
---
name: login1
state: on
tags:
  - type: login
EOF

# Set up compute nodes
for int in {01..03}
do
  name="cnode$int"
  echo "Creating $name..."

  cat <<EOF > "$RUN_ENV/nodes/$name.yaml"
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
