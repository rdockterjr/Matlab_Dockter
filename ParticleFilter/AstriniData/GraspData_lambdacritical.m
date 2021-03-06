
%% importing raw data
clear all

%plot settings
fontS = 12;

endData = 21000;
countsPerRev = 500; %encoder (astrini thesis)

filename = {'bladder4Hz1.lvm';'bladder4Hz2.lvm';'gallbladder4Hz1.lvm';'gallbladder4Hz2.lvm';'liver4Hz1.lvm';'liver4Hz2.lvm'};
enumTypes = {'bladder'; 'gallbladder'; 'liver'};% 'smallbowel' };
tissuetypeIn = [1,1,2,2,3,3];

numFiles = length(filename);

headerlinesIn = 24;

for kk = 1:numFiles
    rawd = [];
    
    % data = [ t stress motorCommandActual jaw1contact jaw2contact encoder ] ;
    [tt ,rawd(:,1),rawd(:,2),rawd(:,3),rawd(:,4),rawd(:,5)]  =  textread(char(filename(kk)),'%f %f %f %f %f %f' ,'headerlines', headerlinesIn );

    %angle of grasper
    angle = rawd(:,5);
    angle = (angle / countsPerRev) * 2*pi; %convert to radians.
    
    %time
    time = tt;
    deltaT = mean(diff(time));

    FullData{kk}.t = time;
    FullData{kk}.tissuetype = tissuetypeIn(kk);
    FullData{kk}.ind = 1:1:length(time);
    FullData{kk}.stress = rawd(:,1); %newtons?
    FullData{kk}.stressdot = Calculate_velocity( FullData{kk}.stress, deltaT, 'holobrodko');
    FullData{kk}.stressdotdot = Calculate_velocity( FullData{kk}.stressdot, deltaT, 'holobrodko');
    FullData{kk}.angle = angle; %radians
    FullData{kk}.angledot = Calculate_velocity( FullData{kk}.angle, deltaT, 'holobrodko');  % FAR better than diff USE IT
    FullData{kk}.angledotdot = Calculate_velocity( FullData{kk}.angledot, deltaT, 'holobrodko');

    %In order to see directions
    plotlength = length(FullData{kk}.angle); %8000;
    figure(kk)
    
    subplot(3,1,1)
    plot(FullData{kk}.angle(1:plotlength))
    title('angle')
    
    subplot(3,1,2)
    plot(FullData{kk}.stress(1:plotlength))
    title('stress')

    subplot(3,1,3)
    plot(FullData{kk}.angledot(1:plotlength))
    title('angledot')
    
    str = sprintf('Raw Data: Grasp #: %i, tissue: %s',kk, enumTypes{ FullData{kk}.tissuetype } );
    suptitle(str);
    
end

%% GO BACKWARD IN TIME!

defgraspstep = 0.2;

% SIGNS ARE CORRECT FOR RAW
stressThreshold = 1.2; %Newtons, Critical threshold at which to start counting a grasp. As small as possible!
stressThreshHigh = 3; %Newtons, Critical threshold at which to start counting a grasp. As small as possible!
VelThreshold = 1; %mm/s, minimum positive closing speed at which to consider grasp as occuring
MinGraspInterval = 30; %Minimum number of time steps between grasps
MinGraspStep = defgraspstep; %Minimum namount of time a grasp should last
MinAngleDisp = 1;

%Go through every file
for kk = 1:numFiles

    %start grasp at end
    GraspStart_i = length(FullData{kk}.t);
    
    GraspEnd_i = length(FullData{kk}.t);
    ss = GraspEnd_i;
    ee = GraspEnd_i;
    
    %count up total grasps
    nGrasp = 0;
    
    %while stuff is available
    stillEnd = true;
    stillStart = true;
    while(stillEnd)
        
        %back up from last grasp start to find the end of the previous
        ee = ee - 1;
        if(ee < 1)
            stillEnd = false;
            break;
        end
        
        %reset while
        stillStart = true;
        
        %change min grasp step for last grasp
        if(nGrasp == 0)
           MinGraspStep = 0;
        else
           MinGraspStep = defgraspstep;
        end
        
        % Find the end of the grasp, top of the peak
        if (FullData{kk}.t(ee) < FullData{kk}.t(max(GraspStart_i - MinGraspInterval,1)) ) && (FullData{kk}.stress(ee) > stressThreshHigh) && ( FullData{kk}.angledot(ee) > VelThreshold )
            GraspEnd_i = ee;
            ss = GraspEnd_i;
            
            %Now find the start of that grasp
            while(stillStart) 
                
                %back up from grasp end to find start
                ss = ss - 1;
                if(ss < 1)
                    stillStart = false;
                    stillEnd = false;
                    break;
                end
                
                %Find index of the start of that grasp
                if (FullData{kk}.t(ss) < FullData{kk}.t(GraspEnd_i) - MinGraspStep) && (FullData{kk}.stress(ss) < stressThreshold) && (FullData{kk}.angle(GraspEnd_i) - FullData{kk}.angle(ss) > MinAngleDisp)
                    
                    GraspStart_i = ss;
                    
                    nGrasp = nGrasp + 1;
                    segDataTemp{kk}.GraspData{nGrasp}.t = FullData{kk}.t(GraspStart_i:GraspEnd_i);
                    segDataTemp{kk}.GraspData{nGrasp}.stress = FullData{kk}.stress(GraspStart_i:GraspEnd_i);
                    segDataTemp{kk}.GraspData{nGrasp}.stressdot = FullData{kk}.stressdot(GraspStart_i:GraspEnd_i);
                    segDataTemp{kk}.GraspData{nGrasp}.stressdotdot = FullData{kk}.stressdotdot(GraspStart_i:GraspEnd_i);
                    segDataTemp{kk}.GraspData{nGrasp}.angle = FullData{kk}.angle(GraspStart_i:GraspEnd_i);
                    segDataTemp{kk}.GraspData{nGrasp}.angledot = FullData{kk}.angledot(GraspStart_i:GraspEnd_i);
                    segDataTemp{kk}.GraspData{nGrasp}.angledotdot = FullData{kk}.angledotdot(GraspStart_i:GraspEnd_i);
                    segDataTemp{kk}.GraspData{nGrasp}.sampleNum = length( segDataTemp{kk}.GraspData{nGrasp}.t );
                    segDataTemp{kk}.GraspData{nGrasp}.tissuetype = FullData{kk}.tissuetype;
                    
                    fprintf('end: %f, start: %f \n',ee,ss);
                    
                    ee = GraspStart_i;
                    stillStart = false;
                end
                
            end

        end
        
    end
end


%Now reorder so grasps go in correct direction vs index
for kk = 1:numFiles
    %%%%%%%%%%%%%%%%%%%%%%%%%% segment grasps %%%%%%%%%%%%%%%%%%%%%%%
    segData{kk}.t = [];
    segData{kk}.stress = [];
    segData{kk}.stressdot = [];
    segData{kk}.stressdotdot = [];
    segData{kk}.angle = [];
    segData{kk}.angledot = [];
    segData{kk}.angledotdot = [];

    
    indnew = 1;
    %flip the grasp order so linearly increases in time
    for jj = length(segDataTemp{kk}.GraspData):-1:1
        segData{kk}.GraspData{indnew} = segDataTemp{kk}.GraspData{jj};
        
        %all grasps for plots
        segData{kk}.t = [segData{kk}.t; segData{kk}.GraspData{indnew}.t];
        segData{kk}.stress = [segData{kk}.stress; segData{kk}.GraspData{indnew}.stress];
        segData{kk}.stressdot = [segData{kk}.stressdot; segData{kk}.GraspData{indnew}.stressdot];
        segData{kk}.stressdotdot = [segData{kk}.stressdotdot; segData{kk}.GraspData{indnew}.stressdotdot];
        segData{kk}.angle = [segData{kk}.angle; segData{kk}.GraspData{indnew}.angle];
        segData{kk}.angledot = [segData{kk}.angledot; segData{kk}.GraspData{indnew}.angledot];
        segData{kk}.angledotdot = [segData{kk}.angledotdot; segData{kk}.GraspData{indnew}.angledotdot];
        segData{kk}.tissuetype = FullData{kk}.tissuetype;
        
        indnew = indnew + 1;
    end
    
    figure(kk)
    subplot(3,1,1)
    plot(FullData{kk}.t,FullData{kk}.angle)
    hold on
    scatter(segData{kk}.t,segData{kk}.angle,'.r')
    hold off
    xlabel('Time (s)')
    ylabel('angle (rad)')
    
    subplot(3,1,2)
    plot(FullData{kk}.t,FullData{kk}.angledot)
    hold on
    scatter(segData{kk}.t,segData{kk}.angledot,'.r')
    hold off
    xlabel('Time (s)')
    ylabel('angledot (rad)')
    
    subplot(3,1,3)
    plot(FullData{kk}.t,FullData{kk}.stress)
    hold on
    scatter(segData{kk}.t,segData{kk}.stress,'.r')
    hold off
    xlabel('Time (s)')
    ylabel('stress (N)')
    
    str = sprintf('Segmented Data: Grasp #: %i, tissue: %s',kk, enumTypes{ FullData{kk}.tissuetype } );
    suptitle(str);
    
end

return

%% combine segments

%set to empty
for jj = 1:max(tissuetypeIn)
    combineSeg{jj}.t = [];
    combineSeg{jj}.stress = [];
    combineSeg{jj}.stressdot = [];
    combineSeg{jj}.stressdotdot = [];
    combineSeg{jj}.angle = [];
    combineSeg{jj}.angledot = [];
    combineSeg{jj}.angledotdot = [];
    ombineSeg{jj}.D = [];
    combineSeg{jj}.U = [];
    combineSeg{jj}.Phi = [];
end

% combined segmented grasps
for kk = 1:numFiles
    combineSeg{FullData{kk}.tissuetype}.t = [combineSeg{FullData{kk}.tissuetype}.t ; segData{kk}.t ];
    combineSeg{FullData{kk}.tissuetype}.stress = [combineSeg{FullData{kk}.tissuetype}.stress ; segData{kk}.stress ];
    combineSeg{FullData{kk}.tissuetype}.stressdot = [combineSeg{FullData{kk}.tissuetype}.stressdot ; segData{kk}.stressdot ];
    combineSeg{FullData{kk}.tissuetype}.stressdotdot = [combineSeg{FullData{kk}.tissuetype}.stressdotdot ; segData{kk}.stressdotdot ];
    combineSeg{FullData{kk}.tissuetype}.angle = [combineSeg{FullData{kk}.tissuetype}.angle ; segData{kk}.angle ];
    combineSeg{FullData{kk}.tissuetype}.angledot = [combineSeg{FullData{kk}.tissuetype}.angledot ; segData{kk}.angledot ];
    combineSeg{FullData{kk}.tissuetype}.angledotdot = [combineSeg{FullData{kk}.tissuetype}.angledotdot ; segData{kk}.angledotdot ];
    
end


lambda = [0:0.1:1];

%Create D and U matrix for RLS
for jj = 1:max(tissuetypeIn)
    combineSeg{jj}.state = [combineSeg{jj}.angledotdot, combineSeg{jj}.angledot, combineSeg{jj}.angle, combineSeg{jj}.angle.^2, combineSeg{jj}.angle.^3, ones(length(combineSeg{jj}.angle) , 1) ];
    combineSeg{jj}.input = [combineSeg{jj}.stress ];
end

lambda_c = lambda_critical(combineSeg)


