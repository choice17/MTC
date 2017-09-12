addpath ../include 
addpath ../analysis 
addpath ../V2P 


load ../V2P/day1F_train.mat
%%
A = csvread('../V2P/day1.txt');
day1 = A;
save ../V2P/day1.mat day1

%% check accuracy
close all;
tripindex = 8;
tripID = day1F_train.getTripID('TripIndex',1);
figure(1);
trip = day1(day1(:,2)==tripID,[3 4]);
plot(trip(:,2),trip(:,1),'b.');hold on ;
thistrip = day1F_train.TripInCell{tripindex}(:,[3 4]);
plot(thistrip(:,2),thistrip(:,1),'r.');hold off;

