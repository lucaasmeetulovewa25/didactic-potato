#!/usr/bin/env bash
set -euo pipefail

# Token wajib diisi (lewat Secrets Cerebrium). Tanpa token, siapa pun yang
# bisa menjangkau port ini bisa menjalankan kode di container.
: "${JUPYTER_TOKEN:?JUPYTER_TOKEN belum diset. Tambahkan lewat: cerebrium secrets add JUPYTER_TOKEN=...}"

# Notebook disimpan di persistent volume supaya tidak hilang saat instance mati.
NOTEBOOK_DIR="/persistent-storage/notebooks"
mkdir -p "$NOTEBOOK_DIR"

# Opsional: ubah jika Anda butuh prefix path tertentu di belakang proxy.
BASE_URL="${JUPYTER_BASE_URL:-/}"

echo "Starting JupyterLab on port 8888 (root_dir=$NOTEBOOK_DIR, base_url=$BASE_URL)"

exec jupyter lab \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root \
  --ServerApp.root_dir="$NOTEBOOK_DIR" \
  --ServerApp.base_url="$BASE_URL" \
  --ServerApp.token="$JUPYTER_TOKEN" \
  --ServerApp.allow_remote_access=True \
  --ServerApp.trust_xheaders=True
  # Jika koneksi websocket kernel ditolak (403) di belakang gateway, tambahkan:
  # --ServerApp.allow_origin_pat='https://.*\.cerebrium\.ai'
