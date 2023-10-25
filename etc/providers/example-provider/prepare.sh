echo "Preparing..."

# Set up instance models and costs
echo "Creating instance models"
mkdir "$RUN_ENV/instance_models"
cat <<EOF > "$RUN_ENV/instance_models/compute_small.yaml"
---
model: compute_small
provider: example-provider
currency: GBP
price_per_hour: 1
cpu: 2
gpu: 2
mem: 2
EOF

cat <<EOF > "$RUN_ENV/instance_models/compute_large.yaml"
---
model: compute_large
provider: example-provider
currency: GBP
price_per_hour: 1.5
cpu: 4
gpu: 4
mem: 4
EOF

cat <<EOF > "$RUN_ENV/instance_models/mining_rig.yaml"
---
model: mining_rig
provider: example-provider
currency: Bitcoin
price_per_hour: 0.000123
cpu: 1
gpu: 8192
mem: 8.1632
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

echo "Creating projects dir..."
mkdir "$RUN_ENV/projects"
echo "Created."

# Download yq for parsing YAML and JSON
echo "Downloading yq..."
mkdir "$RUN_ENV/bin"
wget https://github.com/mikefarah/yq/releases/download/v4.35.2/yq_linux_amd64 -P "$RUN_ENV/bin"
chmod +x "$RUN_ENV/bin/yq_linux_amd64"
echo "Downloaded."

sleep 3
echo "Prepared."
