# Install pack CLI
curl -LO https://github.com/buildpacks/pack/releases/download/v0.8.1/pack-v0.8.1-linux.tgz
sudo tar xvzf pack-v0.8.1-linux.tgz -C /usr/local/bin/ pack
rm pack-v0.8.1-linux.tgz

# Install sample apps
git clone https://github.com/buildpacks/samples

echo "done" >> /root/tool-install-finished
