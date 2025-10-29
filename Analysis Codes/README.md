Directory contains the following scripts:

DS3_BrainState_notebook.mlx : matlab notebook to reproduce Figure 1-2 in the manuscript
CellAnalysis_RunRest_main.m: matlab script to reproduce Figure 3 and Figure S3C with stats
AnalyzeCellRecruitment_FollowUp.m: matlab script to reproduce Figure S3 A-B

All other function are helper functions needed in the 3 main scripts.

Input data is availabe at *Tarcsay, Gergely; Saxena, Rajat; Long, Royston; Shobe, Justin L.; McNaughton, Bruce L.; Ewell, Laura A. (2025), “Dentate spikes comprise a continuum of relative input strength 
from the lateral and medial entorhinal cortex”, Mendeley Data, V1, doi: 10.17632/grcn2dd9st.1  - processedData folder*

* DS_dataA: DS classification output file for each mouse in data A
* DS_dataB: DS classification output file for each mouse in data B. Note that in this case rest/behavior sessions were concatanated, therefore this file is not used directly for rate analysis.
* DS_dataC: DS classification output file for each mouse in data C
* FM_run: DS classification for the behavior session for freely moving mice
* HF_qw: calculated rates for head-fixed rest session (restricted to post-behavior from DS_dataB)
* HF_run: calculated rates for head-fixed during running (restricted to behavior session from DS_dataB)
* CellTable_Ewell: for single-unit analysis, freely moving mice
* CellTable_swil: for single-unit analysis, head-fixed mice
