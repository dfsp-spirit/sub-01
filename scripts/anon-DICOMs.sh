#!/bin/bash
#
# requires: dicom-anonymizer 2.1.0 from pip (we used Python 3.12.3, Ubuntu 24 LTS):
#
# python -m venv venv
# source venv/bin/activate
# pip install dicom-anonymizer
#
# This script is not functional in this repo, because the repo does not contain the
# original DICOM files. It is provided for reference only to illustrate how the DICOM files were anonymized.
# If you have the original DICOM files, place them in a directory named 'DICOM' and then run this script.

if [ ! -d "DICOM" ]; then
    echo "DICOM directory not found. Please place your DICOM files in a directory named 'DICOM' before running this script."
    exit 1
fi

dicom-anonymizer DICOM raw/sub-01 --dictionary scripts/dicom-anonymizer-rules.json

# to check the anonymization, you can use dcmdump from dcmtk:
#SAMPLE_DCM=$(find DICOM_anon -type f -name "*.dcm" | head -n 1)
#dcmdump "$SAMPLE_DCM"
#
# you can compare to source:
#SAMPLE_DCM=$(find DICOM -type f -name "*.dcm" | head -n 1)
#dcmdump "$SAMPLE_DCM"


