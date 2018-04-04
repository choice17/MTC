# MTC project 

**Note** I intensively use "section run" features in matlab by "Ctrl+Enter" which enable to run sessions in the script instead of whole file, to run the script, please read the instruction of the script and run selected session instead of whole script.

in MTC Project, it consists of 5 folders 
 1.analysis 
 2.data 
 3.document 
 4.include 
 5.model 


## 1. analysis 

there are 5 main scripts in .m files 

**create_day1_100Trips_Obj.m** 

script to extract and create day1_100Trip_Obj from raw data set from data/day1_full.mat
which is essential element to do experiment 
read file description in the script for details 

**discontinousTrainingDay1_XHz_train.m** 

there is 3 scripts for 1Hz, 2Hz, 10Hz 

The objects used in the scripts store in data/  
most experiment is performed in the segmentation session 
time series session is deprecated, and may not runable  
 
you may setup input vector in the training parameter so it can train for multiple parameters

**model_prediction_analysis(_XHz).m** 

input the training parameter used in discontinousTrainingDay1_XHz_train.m 

note: you must select training parameter of the model you want to test instead of vector training parameter 

read script for more details 

**sysIntegrationDemoRun.m** 

script to run implement prediction model to testing data, this script specify for MCITY data 

the last session includes reading the OBD data of MCITY data with resampling function 

**DSRCanalysis.m** 

script to implement prediction model to testing data with specify for DSRC data 

please run in sessions to perform all necessarily data processing step 

`with 1 folder for V2P demo script`

**yifu demo**

function to plot the pedestrian/ vehicle ground truth/ prediction into image. 
input: sequence of pedestrian/ vehicle ground truth/ prediction 
output: demo animation

## 2. data 

**DSRC/**  

DSRC raw data for testing/visualization 

**day1_XHz_Train.mat**  

extracted 100trips from day1_full.mat  

**day1_100_obj.mat**  

extracted 100trips from day1_full.mat without any further processing/resampling 

**day1_full.mat**  

raw data for this project, origin from MTC collection 1 
-19 attri col

**demoTrip.mat** 

1Hz MCITY data extracted from OBD_DATA_Loop1PreTest&Test1.csv 

**demoTrip_2Hz.mat** 

2Hz MCITY data extracted from OBD_DATA_Loop1PreTest&Test1.csv 


**DSRC_V2P_XXX.mat** 

saved prediction result generated from DSRCanalysis.m 

## 3. document 

**How_to_Use_the_Vehicle_Future_Path_Prediction_System_v0.1.docx**  

describe how to use VehicleFutPathPred obj, and sysIntegrationDemoRun.m 

**MTC Trips Summary_2Hz 31Dec2017.xlsx** 

trips summary of the extracted trips with experiment result for 2Hz data 
more experiment result please visit folder model/ 
model experiment info also store in the model/net-GPS-datetime.m  

**weekly report of the project**  

please contact team leader Krishna for more weekly process 
team member: Song Wang, Shruthi  

## 4. include 

store main function/obj  

**/day1TripObj**  

main object class: 
I. day1TripAnalysis - for data processing 
II.day1TripTrain - for experiment/model training 

please inspect/alter getLocalInCell.m for all normalization step if any  

please inspect/alter methods of day1TripTrain.m for other experiment if needed 

**/randomSeed**  

stored of random seed for random function (important for reproducing the experiment result) 

**/utility** 

miscellaneous function  

**/VehicleFutPathPred** 

main object class:

VehicleFutPathPred.m 

do not have training components, can only implement model trained by discontinousTrainingDay1_XHz_train.m 

Note: freq/deltaT/window size value must match the pre-trained model  

**/model** 

see model description.txt and document/MTC Trips Summary_2Hz 31Dec2017.xlsx for more details of the model. 

you can also inspect the K-fold trips loss by open net-datetime.mat model file.





----------------------------------------------------------------------------------------
## APPENDIX ---------------- 
---------------------------- 


### class : VehicleFutPathPred 

```python
prediction method of the vehicelFutPathPred :  

VehicleFutPathPred.pathPredict()  
%Objective:  
predict the future path GPS value by previous/current GPS location  

%input:  
gps_lat: vector of lat sequence,   
gps_lng: vector of lng sequence  

%output:  
gps_lat: vector of lat prediction sequence,   
gps_lng: vector of lng prediction sequence,
speed  : vector of predicted speed
heading: vector of predicted heading  

%note:  
sequence length must equal for larger than the model input size  
(5seconds in this model, 1Hz, i.e. 5 time stamp data)  
else the function outputs empty value [].  
```


* more details please read analysis/sysIntegrationDemoRun.m script for illustration 
  contact tcyu@umich.edu 


sysIntegrationDemoRun.m includes illustration on  
 1. create prediction object with different parameter setup 
 2. vehicle future path prediction procedure 
 3. check prediction by plotting 
 4. reaing OBD data file 
