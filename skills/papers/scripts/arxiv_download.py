#!/usr/bin/env python3
"""Download arXiv paper source (TeX) or PDF to a local directory.

Usage:
    python arxiv_download.py --arxiv-id 2301.12345 --output-dir .claude/papers/my-paper/raw
    python arxiv_download.py --arxiv-id 2301.12345 --output-dir .claude/papers/my-paper/raw --pdf-only

Downloads TeX source (.tar.gz) by default, extracts it, and falls back to PDF if source is unavailable.
With --pdf-only, skips source and downloads PDF directly.
"""

import argparse
import os
import subprocess
import sys
import tarfile
import time
import urllib.request
import urllib.error


def download_file(url: str, dest: str, max_retries: int = 2) -> bool:
    """Download a file from URL to dest path. Returns True on success."""
    for attempt in range(max_retries + 1):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Claude-Papers-Skill/1.0"})
            with urllib.request.urlopen(req, timeout=60) as resp, open(dest, "wb") as f:
                while chunk := resp.read(8192):
                    f.write(chunk)
            return True
        except (urllib.error.HTTPError, urllib.error.URLError, TimeoutError) as e:
            print(f"  Attempt {attempt + 1} failed: {e}", file=sys.stderr)
            if attempt < max_retries:
                time.sleep(4)  # respect arXiv rate limits
    return False


def extract_tar(tar_path: str, dest_dir: str) -> bool:
    """Extract a tar.gz file. Returns True on success."""
    try:
        with tarfile.open(tar_path, "r:gz") as tar:
            # Security: prevent path traversal
            for member in tar.getmembers():
                if member.name.startswith("/") or ".." in member.name:
                    print(f"  Skipping suspicious path: {member.name}", file=sys.stderr)
                    continue
            tar.extractall(path=dest_dir, filter="data")
        return True
    except (tarfile.TarError, EOFError) as e:
        print(f"  Extraction failed: {e}", file=sys.stderr)
        return False


def main():
    parser = argparse.ArgumentParser(description="Download arXiv paper")
    parser.add_argument("--arxiv-id", required=True, help="arXiv paper ID (e.g., 2301.12345)")
    parser.add_argument("--output-dir", required=True, help="Directory to save files")
    parser.add_argument("--pdf-only", action="store_true", help="Download PDF only, skip TeX source")
    args = parser.parse_args()

    arxiv_id = args.arxiv_id.strip()
    output_dir = args.output_dir

    os.makedirs(output_dir, exist_ok=True)

    if not args.pdf_only:
        # Try downloading TeX source first
        source_url = f"https://arxiv.org/e-print/{arxiv_id}"
        tar_path = os.path.join(output_dir, "source.tar.gz")

        print(f"Downloading TeX source for {arxiv_id}...")
        time.sleep(3)  # arXiv rate limit

        if download_file(source_url, tar_path):
            print("  Extracting source archive...")
            if extract_tar(tar_path, output_dir):
                # Check if we got actual TeX files
                tex_files = [f for f in os.listdir(output_dir) if f.endswith(".tex")]
                if tex_files:
                    print(f"  Success! Found {len(tex_files)} .tex file(s): {', '.join(tex_files)}")
                    # Keep the tar.gz as backup, list all extracted files
                    all_files = os.listdir(output_dir)
                    print(f"  All files: {', '.join(sorted(all_files))}")
                    return
                else:
                    print("  No .tex files found in archive, falling back to PDF")
            # Clean up failed extraction
            if os.path.exists(tar_path):
                os.remove(tar_path)
        else:
            print("  Source download failed, falling back to PDF")

    # Download PDF
    pdf_url = f"https://arxiv.org/pdf/{arxiv_id}"
    pdf_path = os.path.join(output_dir, "paper.pdf")

    print(f"Downloading PDF for {arxiv_id}...")
    time.sleep(3)  # arXiv rate limit

    if download_file(pdf_url, pdf_path):
        size_mb = os.path.getsize(pdf_path) / (1024 * 1024)
        print(f"  Success! PDF saved ({size_mb:.1f} MB)")
    else:
        print(f"  ERROR: Could not download paper {arxiv_id}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
