function plotPredictRoute(inputs,outputs,targets,option)
% plot the predict route with I/O of the neural network
% inputs/targets: the variables from preparets
% outputs: of the trained neural network
% option: option to display 'roadmap' 'satelite'


if ~option.gps 
    
    plotnum = option.plotnum ;
    st = option.startPos;
    ds = option.cursorwidth;
    
    fignum = option.fignum;
    hold on;
    txtexist=0;
    xodd=[];xeven=[];
    yodd=[];yeven=[];
    zodd=[];zeven=[];
    yellow = [];
    caseswitch = 1;
    delstart = 0;
    j=0;
 


    for i=st:plotnum:size(outputs,1)
        axis([inputs(i,2)-ds inputs(i,2)+ds ...
        inputs(i,1)-ds inputs(i,1)+ds ]);
        if txtexist && mod(j,100)==1 && caseswitch == 1
            if delstart
            delete(xeven);
            delete(yeven);
            delete(zeven);
            end
            caseswitch=2;
        elseif txtexist && mod(j,100)==1 && caseswitch == 2
            if delstart
            delete(xodd);
            delete(yodd);
            delete(zodd);
            end
            caseswitch=1;
            delstart = 1;
        end
        
        axis([inputs(i,2)-ds inputs(i,2)+ds ...
        inputs(i,1)-ds inputs(i,1)+ds ]);
        
        if caseswitch == 1
            
        % current loc
            xodd=[xodd plot(inputs(i,2),inputs(i,1),'g.','MarkerSize',10)];
        % ground true loc on (delay)s time 
            yodd=[yodd plot(targets(i,2),targets(i,1),'b.','MarkerSize',10)];
        % pred
            zodd=[zodd plot(outputs(i,2),outputs(i,1),'r.','MarkerSize',10)];
        else 
        % current loc
            xeven=[xeven plot(inputs(i,2),inputs(i,1),'g.','MarkerSize',10)];
        % ground true loc on (delay)s time 
            yeven=[yeven plot(targets(i,2),targets(i,1),'b.','MarkerSize',10)];
        % pred
            zeven=[zeven plot(outputs(i,2),outputs(i,1),'r.','MarkerSize',10)];
        end
        if option.line
        if ~isempty(yellow)
            delete(yellow);
        end        
        yellow_x = [inputs(i:i,2);inputs(i,2)+10*(inputs(i,2)-inputs(i-1,2))];
        yellow_y = [inputs(i:i,1);inputs(i,1)+10*(inputs(i,1)-inputs(i-1,1))];
        yellow = plot(yellow_x, yellow_y ,'y--','Linewidth',1);
        end
           %% label the point
           if option.label
            if txtexist
                delete(ctxt);
                delete(grtxt);
                delete(pretxt);
            end
            ctxt = text(inputs(i,2)+ds/25,inputs(i,1)+ds/15,'current','Color','green','FontSize',12);
            grtxt =  text(targets(i,2)+ds/10,targets(i,1)+ds/15,'ground tru','Color','blue','FontSize',12);
            pretxt = text(outputs(i,2)-ds/10,outputs(i,1)+ds/15,'predict','Color','red','FontSize',12);
            txtexist=1;
            
            
            
           
           end
             %%
        
        
        if ~option.pause
            pause(option.time);
        else 
            pause();
        end
        
        txtexist=1;  
        j=j+1;
    end

%end

else
    
    
    plotnum = option.plotnum ;
    st = option.startPos;
    ds = option.cursorwidth;
    
    fignum = option.fignum;
    txtexist=0;
    xodd=[];xeven=[];
    yodd=[];yeven=[];
    zodd=[];zeven=[];
    yellow = [];
    caseswitch = 1;
    delstart = 0;
    j=0;
    
    if ~isempty(option.gooMap)
    plot(inputs(st,2),inputs(st,1),'g.','MarkerSize',10);
    
    axis([inputs(st,2)-option.zoom*ds inputs(st,2)+option.zoom*ds ...
    inputs(st,1)-option.zoom*ds inputs(st,1)+option.zoom*ds ]);
    plot_google_map('MapType',option.gooMap,'ShowLabels',0);
    hold on;
    
    pause(0.1);
    end
    
     
    for i=st:plotnum:size(outputs,1)
         if mod(i,option.refreshTime)==0 && option.refresh
            hold off;
         
         
         
        % request a greater size of image in order for reduce refresh time
        axis([inputs(i,2)-option.zoom*ds inputs(i,2)+option.zoom*ds ...
        inputs(i,1)-option.zoom*ds inputs(i,1)+option.zoom*ds ]);
        plot_google_map('MapType',option.gooMap,'ShowLabels',0,'AutoAxis',0);
        hold on;
         end
         
         if option.repeat>0
         if mod(i,option.repeat)==0
              close(figure(fignum));
         end  
         end
        
         try
        axis([inputs(i,2)-ds inputs(i,2)+ds ...
        inputs(i,1)-ds inputs(i,1)+ds ]);
         catch
            return
         end
    if txtexist && mod(j,100)==1 && caseswitch == 1
            if delstart
            delete(xeven);
            delete(yeven);
            delete(zeven);
            end
            caseswitch=2;
        elseif txtexist && mod(j,100)==1 && caseswitch == 2
            if delstart
            delete(xodd);
            delete(yodd);
            delete(zodd);
            end
            caseswitch=1;
            delstart = 1;
        end
        
        
        if caseswitch == 1
        % current loc
        xodd=[xodd plot(inputs(i,2),inputs(i,1),'g.','MarkerSize',10)];
        % ground true loc on (delay)s time 
        yodd=[yodd plot(targets(i,2),targets(i,1),'b.','MarkerSize',10)];
        % pred
        zodd=[zodd plot(outputs(i,2),outputs(i,1),'r.','MarkerSize',10)];
        else 
        % current loc
        xeven=[xeven plot(inputs(i,2),inputs(i,1),'g.','MarkerSize',10)];
        % ground true loc on (delay)s time 
        yeven=[yeven plot(targets(i,2),targets(i,1),'b.','MarkerSize',10)];
        % pred
        zeven=[zeven plot(outputs(i,2),outputs(i,1),'r.','MarkerSize',10)];
        end
        if ~isempty(yellow)
            delete(yellow);
        end
        yellow_x = [inputs(i-1:i,2);inputs(i,2)+10*(inputs(i,2)-inputs(i-1,2))];
        yellow_y = [inputs(i-1:i,1);inputs(i,1)+10*(inputs(i,1)-inputs(i-1,1))];
        yellow = plot(yellow_x, yellow_y ,'y--','Linewidth',1);
        
           %% label the point
           if option.label
            if txtexist
                delete(ctxt);
                delete(grtxt);
                delete(pretxt);
            end
            ctxt = text(inputs(i,2)+ds/25,inputs(i,1)+ds/15,'current','Color','green','FontSize',12);
            grtxt =  text(targets(i,2)+ds/10,targets(i,1)+ds/15,'ground tru','Color','blue','FontSize',12);
            pretxt = text(outputs(i,2)-ds/10,outputs(i,1)+ds/15,'predict','Color','red','FontSize',12);
            txtexist=1;
            
            
            
           
           end
             %%
        
        
        if ~option.pause
            pause(option.time);
        else 
            pause();
        end
        
      txtexist=1;  
     j=j+1;
    end
    plot_google_map('MapType',option.gooMap,'ShowLabels',1);
end


end
