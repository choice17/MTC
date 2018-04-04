%% load v2p data
function plotdemo()
 clear
 load('DSRC_V2P_11_10.mat')
% load('V2Ppair1_pedestrian.mat')
% 
% %%
v1.data  = DSRC_V2P_11_10.vehicleGT;
p1.gps = DSRC_V2P_11_10.pedesGT;
v1.pred_1s = DSRC_V2P_11_10.vehiclePred;
p1.pred_1s = DSRC_V2P_11_10.pedesPred;
ws = 30-1;

%% set plot object
% ground truth
%gps1=table2array(v1.data(:,1:2)); % vehicle
gps1=v1.data;
gps2=p1.gps; % pedestrian
% predicted GPS in t 
predV = v1.pred_1s; % vehicle 
predP = p1.pred_1s; % pedestrian

figure
% set the range of axes 
maxLat = max([gps1(:,1);gps2(:,1)]);
maxLon = max([gps1(:,2);gps2(:,2)]);
minLat = min([gps1(:,1);gps2(:,1)]);
minLon = min([gps1(:,2);gps2(:,2)]);
axis([minLon maxLon minLat maxLat]);
   plot_google_map('MapType','satellite')
   % ground truth
   h1=animatedline('Color','r','LineWidth',3);
   h2=animatedline('Color','b','LineWidth',3);
   % predicted route
   h3=animatedline('Color','g','LineWidth',1);
   h4=animatedline('Color','c','LineWidth',1);
   hPlot1 = plot(NaN,NaN,'go'); % vehicle circle
   hPlot2 = plot(NaN,NaN,'co');
   hPlot_alert = plot(NaN,NaN,'ro');
%%   plotting
   for k2 = 1: length(gps1)

       addpoints(h1,gps1(k2,2),gps1(k2,1));
       addpoints(h2,gps2(k2,2),gps2(k2,1));
       % plot predicted route and circle zone. 
       
       if k2 > ws  
          
            % vehicle 
            % predicted point          
            addpoints(h3,predV(k2-ws,2),predV(k2-ws,1)); 
            % circle zone
            speedV = predV(k2-ws, 3);
            rV = speedV * 5 + 15; 
                 
            % pedestrian 
            
            addpoints(h4,predP(k2-ws,2),predP(k2-ws,1));
            
            speedP = 1 ;% predP(k2-ws, 3);
            rP = speedP * 4 + 15;
            
            if (rP + rV)*0.25 > disMethod4(predV(k2-ws,1),predV(k2-ws,2),predP(k2-ws,1),predP(k2-ws,2))*1000 %&& k2 <23 % if there's collision
                delete(hPlot1); 
                set(hPlot_alert,'MarkerSize',rV); % set the circle marker
                set(hPlot_alert,'XData',predV(k2-ws,2),'YData',predV(k2-ws,1));
                 hPlot1 = plot(NaN,NaN,'go');

            else
%                 delete(hPlot_alert);
                set(hPlot1,'MarkerSize',rV); % set the circle marker
                set(hPlot1,'XData',predV(k2-ws,2),'YData',predV(k2-ws,1));
                
            end
            set(hPlot2,'MarkerSize',rP); 
            set(hPlot2,'XData',predP(k2-ws,2),'YData',predP(k2-ws,1));   
       end
       
       
       pause(0.02); 
       drawnow
   end
end
   