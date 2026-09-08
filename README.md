## sub-01

MR scans of a human, adult brain at 3T.

The scans were acquired on a Siemens Magnetom Prisma running syngo MR E11.

This repo provides the DICOM images, raw and in [BIDS](https://bids.neuroimaging.io/index.html) organization.


## Repo Organization

* [raw/](./raw/): the raw DICOM images from the scanner. Anonymized with dicom-anonymizer, see [scripts/](./scripts/) for details on how this was done to preserve metadata required by dcm2bids while removing sensitive information.
* [bids/](./bids/): the DICOM images in BIDS organization


## DICOM series info

For the data in `raw/`:

| Series Prefix | File Count | Modality / Scan Type | Description & Purpose |
|---|---|---|---|
| `0001_MR*.dcm` | 3 files | **Localizer / Scout** | 3-plane anatomical reference for scanner slice positioning (discard or omit from analysis). |
| `0002_MR*.dcm` | 192 slices | **Structural T1-weighted (T1w)** | 1mm isotropic 3D MPRAGE; primary anatomical volume for cortical reconstruction and tissue segmentation. |
| `0003_MR*.dcm` | 192 slices | **Structural T2-weighted (T2w)** | 1mm 3D Turbo Spin Echo (TSE); standard T2 contrast showing CSF hyperintensity. |
| `0004_MR*.dcm` | 192 slices | **Structural T2-weighted (iPAT 3D)** | 1mm 3D T2 TSE with parallel imaging acceleration (`iPAT`). |
| `0005_MR*.dcm` | 240 volumes | **Resting-State fMRI (rs-fMRI BOLD)** | 2D EPI BOLD time series (3mm resolution, 240 volumes) measuring spontaneous low-frequency BOLD fluctuations during rest. |
| `0006_MR*.dcm` | 72 files | **Diffusion MRI (DWI / DTI)** | 2mm 2D EPI diffusion-weighted sequence; multiple diffusion directions/b-values for tractography and tensor estimation. |
| `0007_MR*.dcm` | 72 slices | **DWI Fieldmap / $b=0$ Reference (Pair A)** | Single 3D reference volume for susceptibility distortion correction (e.g., FSL `topup`). |
| `0008_MR*.dcm` | 72 slices | **DWI Fieldmap / $b=0$ Reference (Pair B)** | Complementary reverse phase-encode reference volume for `topup`. |


## Reproduction

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


## License

These neuroimaging data are dedicated to the public domain under the **Creative Commons Zero v1.0 Universal (CC0 1.0)** dedication.

You can copy, modify, distribute, and perform the work, even for commercial purposes, all without asking permission. See the [LICENSE](LICENSE) file for the full legal text, or read the human-readable summary at [Creative Commons](https://creativecommons.org/publicdomain/zero/1.0/).