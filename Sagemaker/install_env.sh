#!/bin/bash
source activate python3
conda create --name text2video python=3.8
conda activate text2video
conda install ipykernel
python -m ipykernel install --user --name text2video --display-name "Python3 (text2video)"