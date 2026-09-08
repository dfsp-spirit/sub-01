## Reproduction

If you want to reproduce the conversion of the data in `raw/` to the data in `bids`, read on.

We used this dcm2bids 3.3.0 from pip (Python 3.12.3, Ubuntu 24 LTS).

```shell
dcm2bids --version
   dcm2bids version:	3.3.0
   default BIDS version:	v1.11.1 unless overridden by --bids_version.
```

To perform the BIDS conversion:

```sh
#!/usr/bin/env bash
# ==============================================================================
# Workflow: Convert Anonymized MRI DICOMs to BIDS Using dcm2bids
# Assumes input DICOMs are located in: raw/sub-01
# ==============================================================================

set -euo pipefail

# 1. Environment & Dependency Setup
# ------------------------------------------------------------------------------
# Ensure dcm2bids and dcm2niix are installed:
#   pip install dcm2bids
#   conda install -c conda-forge dcm2niix  (or sudo apt install dcm2niix)

# 2. Scaffold BIDS Project Directory Structure
# ------------------------------------------------------------------------------
# Generates base BIDS scaffolding: dataset_description.json, README, code/, etc.
dcm2bids_scaffold -o bids

# 3. Write Conversion Configuration File (bids/code/config.json)
# ------------------------------------------------------------------------------
# Maps sequence SeriesDescriptions and ImageTypes to BIDS datatypes and suffixes.
# - T1w: MPRAGE anatomical scan
# - T2w: Standard TSE and iPAT 3D TSE (tagged with acq-ipat3d)
# - func: BOLD resting-state fMRI (TaskName injected into sidecar)
# - dwi: Raw diffusion scan filtered by ImageType to ignore scanner ADC/FA maps
cat << 'EOF' > bids/code/config.json
{
  "descriptions": [
    {
      "datatype": "anat",
      "suffix": "T1w",
      "criteria": {
        "SeriesDescription": "*T1w_MPRAGE*"
      }
    },
    {
      "datatype": "anat",
      "suffix": "T2w",
      "criteria": {
        "SeriesDescription": "*T2w_TSE_1mm"
      }
    },
    {
      "datatype": "anat",
      "suffix": "T2w",
      "custom_entities": "acq-ipat3d",
      "criteria": {
        "SeriesDescription": "*T2w_TSE_1mm_iPAT_3D*"
      }
    },
    {
      "datatype": "func",
      "suffix": "bold",
      "custom_entities": "task-rest",
      "criteria": {
        "SeriesDescription": "*ep2d_bold*"
      },
      "sidecar_changes": {
        "TaskName": "rest"
      }
    },
    {
      "datatype": "dwi",
      "suffix": "dwi",
      "criteria": {
        "SeriesDescription": "*ep2d_diff_2mm*",
        "ImageType": ["ORIGINAL", "PRIMARY", "DIFFUSION", "NONE", "ND", "MOSAIC"]
      }
    }
  ]
}
EOF

# 4. Execute Conversion
# ------------------------------------------------------------------------------
# Converts DICOMs to NIfTI via dcm2niix, sorts according to config.json,
# and overwrites existing target files if re-running.
dcm2bids \
  -d raw/sub-01 \
  -p 01 \
  -c bids/code/config.json \
  -o bids \
  --clobber \
  --auto_extract_entities

# 5. Clean Up Temporary Files
# ------------------------------------------------------------------------------
# Remove working scratchpad and logs produced during conversion
rm -rf bids/tmp_dcm2bids bids/tmp_helper

# 6. Verify BIDS Directory Tree
# ------------------------------------------------------------------------------
echo "Conversion complete. Final structure:"
tree bids/sub-01
```

