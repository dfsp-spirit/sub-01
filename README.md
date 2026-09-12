## sub-01

MR scans of a human, adult brain at 3T under CC0 license.

The scans were acquired on a Siemens Magnetom Prisma running syngo MR E11.

This repo provides the DICOM images, raw and in [BIDS](https://bids.neuroimaging.io/index.html) organization.

If you are looking for derived data, like FreeSurfer reconstructions (`recon-all` output) based on these data, please see the [sub-01-derived repo](https://github.com/dfsp-spirit/sub-01-derived).


**This git repo is a convenience access method to a subset of the data in the following dataset, published on Zenodo:**

* [MR scans of a human, adult brain at 3T in BIDS format. Includes DICOMS, preprocessed output of FreeSurfer, fmriprep and qsirecon](https://doi.org/10.5281/zenodo.22697454)


## Repo Organization

* [raw/](./raw/): the raw DICOM images from the scanner, anonymized with `dicom-anonymizer`. See [scripts/](./scripts/) for details on how this was done to preserve metadata required by dcm2bids while removing sensitive information.
* [bids/](./bids/): the DICOM images in BIDS organization


If you want to know how we created the `bids/` directory from the `raw/` directory, read [REPRODUCTION.md](./scripts/REPRODUCTION.md).


## DICOM series info

For the data in `bids/`, this can be determined automatically from the BIDS metadata and organization.

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



## License

These neuroimaging data are dedicated to the public domain under the **Creative Commons Zero v1.0 Universal (CC0 1.0)** dedication.

You can copy, modify, distribute, and perform the work, even for commercial purposes, all without asking permission. See the [LICENSE](LICENSE) file for the full legal text, or read the human-readable summary at [Creative Commons](https://creativecommons.org/publicdomain/zero/1.0/).