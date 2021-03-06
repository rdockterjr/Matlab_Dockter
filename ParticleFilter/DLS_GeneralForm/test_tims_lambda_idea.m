%Linear model sim

clear all
close all
clc

%%

%plot settings
fontS = 14;
scale_factor = 0.001;
paramOptions = 2;

ploton = 0;

%run variables
runs = 25;
paramNoise = 0.01;
dataNoise = 0.00001;
trainIDX1 = [1:7,9,10];
trainIDX2 = [1:7,9,10];
runIDX = [8];

%%%%%%%%%%%% inputs
A = 100;
tend = 8;
T = 0.01; % sampling period is fronm 1KHz
t = 0:T:tend;

%input is linear increase with time
input.time = t;
input.signals.values = 10*ones(1,length(t));%A*t; % rand(1,length(t)) - 0.5;

input.time = [input.time]';
input.signals.values = [input.signals.values]';
input.signals.dimensions = 1;


%|xdot    | = |0     1|*|x   | + U
%|xdotdot |   |a1 a2| |xdot|

lambdas0_1 = [0:0.05:1]; %%%%Only in this range
% lambdas1_10 = [1:0.5:10];
% lambdas0_10 = [0:0.1:1,1.5:0.5:10];


%%%%%%%%%%%%%%%%%%%%%%get random parameters [M,D,K]
param_bar = [2,28,45];

% param_arr = [5,12,23;
%             5,14,25;
%             5,20,30;
%             5,25,45;
%             5,50,60;
%             5,100,250];
gamma_arr = [0, 0.01, 0.02, 0.05, 0.1, 0.2];        

for kk = 1:length(gamma_arr)
   param_arr(kk,:) = Create_Gamma_Params(param_bar, gamma_arr(kk)); 
   gamma(kk) =  Compute_Gamma(  param_arr(kk,2:3), param_bar(2:3) );
end


%run through all runs with comparison parameters (phi1)
A1 = [0, 1;
     -param_bar(3)/param_bar(1), -param_bar(2)/param_bar(1)];
phi1 = [A1(2,1);A1(2,2)];

pp = 1; %just for class 1
fprintf('Running simulation 1...')
for kk = 1 :runs

    for jj = 1:length(phi1)
        phi(jj) = phi1(jj) +(randn(1)-.5)*paramNoise*phi1(jj);
    end

    % SIMULINK

    sim('SimpleModel2.slx');

    % no noise, get output stuff
    u1_tmp = input_out.Data(:,1);
    x1_tmp = state.Data(:,3);
    xdot1_tmp = state.Data(:,2);
    xdotdot1_tmp = state.Data(:,1); 
    state1 = state.Data;

    %add in some noise
    x1_tmp = x1_tmp;% + (randn(size(x1_tmp))-.5)*dataNoise*mean(x1_tmp); 
    xdot1_tmp = xdot1_tmp;% + (randn(size(xdot1_tmp))-.5)*dataNoise*mean(xdot1_tmp);
    xdotdot1_tmp = xdotdot1_tmp ;%+ (randn(size(xdotdot1_tmp))-.5)*dataNoise*mean(xdotdot1_tmp);
    
    %get errors
    D1 = [x1_tmp,xdot1_tmp,xdotdot1_tmp];
    param_test = abs([phi(1);phi(2);1]); %[param_bar(3)/param_bar(1);param_bar(2)/param_bar(1);1];
    e_1_tmp(:,kk) = u1_tmp - (D1*param_test); 
    
%     figure(400+kk)
%     plot(1:length(u1_tmp),u1_tmp,'rx');
%     hold on
%     plot(1:length(D1*param_test),D1*param_test,'bx');
%     hold off

    %Store
    simd{1}.input_k(:,kk) = u1_tmp;
    simd{1}.state_k{1}(:,kk) = x1_tmp;
    simd{1}.state_k{2}(:,kk) = xdot1_tmp;
    simd{1}.state_k{3}(:,kk) = xdotdot1_tmp;
    simd{1}.params(kk,:) = phi;
    
    %datars
    simd{1}.run{kk}.input = u1_tmp;
    simd{1}.run{kk}.state(:,1) = x1_tmp;
    simd{1}.run{kk}.state(:,2) = xdot1_tmp;
    simd{1}.run{kk}.state(:,3) = xdotdot1_tmp;

end
fprintf(' DONE\n')

%compute class inherint noise
ec_1(:,pp) = mean(abs(e_1_tmp),2);

if(ploton)
    figure(100+pp)
    plot(1:length(ec_1(:,pp)),ec_1(:,pp),'rx');
    
    title('inherent system noise (class 1)')
    xlabel('time')
    ylabel('error')
    
    %See noises
    avg_x = mean(simd{1}.state_k{1},2);
    avg_xdot = mean(simd{1}.state_k{2},2);
    avg_xdotdot = mean(simd{1}.state_k{3},2);
    
    phi = [-param_bar(3)/param_bar(1), -param_bar(2)/param_bar(1) ];
    sim('SimpleModel2.slx');
        % no noise, get output stuff
    u1_tmp = input_out.Data(:,1);
    x1_tmp = state.Data(:,3);
    xdot1_tmp = state.Data(:,2);
    xdotdot1_tmp = state.Data(:,1); 
    state1 = state.Data;
    
    figure(101+pp)
    for kk = 1 :runs
        hh1 = plot(simd{1}.state_k{1}(:,kk),simd{1}.state_k{2}(:,kk),'bx');
        hold on
    end
    hh2 = plot(x1_tmp,xdot1_tmp,'gx');
    hold on
    hh3 = plot(avg_x+abs(ec_1),avg_xdot+abs(ec_1),'rx');
    hold on
    hh4 = plot(avg_x-abs(ec_1),avg_xdot-abs(ec_1),'rx');
    hold off
    
    title('Simulated data with error bars','FontSize',fontS)
    xlabel('x','FontSize',fontS)
    ylabel('xdot','FontSize',fontS)
    legend([hh1,hh2,hh3],'simdata','Actual','error bars','FontSize',12)
    
   
end

%Merge all class 1 runs for comparison
simd{1}.state(:,1) = reshape(simd{1}.state_k{1},[],1);
simd{1}.state(:,2) = reshape(simd{1}.state_k{2},[],1);
simd{1}.state(:,3) = reshape(simd{1}.state_k{3},[],1);
simd{1}.input = reshape(simd{1}.input_k,[],1);

%Loop through all possible param variations
for pp = 1:length(gamma_arr)

    A2 = [0, 1;
         -param_arr(pp,3)/param_arr(pp,1), -param_arr(pp,2)/param_arr(pp,1)];


    %Variation Parameter vector
    phi2 = [A2(2,1);A2(2,2)];
    
    fprintf('Running simulation 2...')
    for kk = 1 :runs

        for jj = 1:length(phi2)
            phi(jj) = phi2(jj) +(randn(1)-.5)*paramNoise*phi2(jj);
        end

        % SIMULINK

        sim('SimpleModel2.slx');


        % no noise, get output stuff
        u2_tmp = input_out.Data(:,1); 
        x2_tmp = state.Data(:,3); 
        xdot2_tmp = state.Data(:,2); 
        xdotdot2_tmp = state.Data(:,1); 
        state2 = state.Data;

        %add in some noise
        x2_tmp = x2_tmp;% + (randn(size(x2_tmp))-.5)*dataNoise*mean(x2_tmp); 
        xdot2_tmp = xdot2_tmp;% + (randn(size(xdot2_tmp))-.5)*dataNoise*mean(xdot2_tmp);
        xdotdot2_tmp = xdotdot2_tmp;% + (randn(size(xdotdot2_tmp))-.5)*dataNoise;%*max(xdotdot2_tmp);

        %get errors
        D2 = [x2_tmp,xdot2_tmp,xdotdot2_tmp];
        param_test = abs([phi(1);phi(2);1]); %[param_arr(pp,3)/param_arr(pp,1);param_arr(pp,2)/param_arr(pp,1);1];
        e_2_tmp(:,kk) = u2_tmp - (D2*param_test); 

        
        %Store
        simd{2}.gamma{pp}.input_k(:,kk) = u2_tmp;
        simd{2}.gamma{pp}.state_k{1}(:,kk) = x2_tmp;
        simd{2}.gamma{pp}.state_k{2}(:,kk) = xdot2_tmp;
        simd{2}.gamma{pp}.state_k{3}(:,kk) = xdotdot2_tmp;
        simd{2}.gamma{pp}.params(kk,:) = phi;
        
        simd{2}.gamma{pp}.run{kk}.input = u2_tmp;
        simd{2}.gamma{pp}.run{kk}.state(:,1) = x2_tmp;
        simd{2}.gamma{pp}.run{kk}.state(:,2) = xdot2_tmp;
        simd{2}.gamma{pp}.run{kk}.state(:,3) = xdotdot2_tmp;
    end
    fprintf(' DONE\n')
   
    %compute class inherint noise
    ec_2(:,pp) = mean(abs(e_2_tmp),2) ./2;
    
    %Merge all runs
    simd{2}.gamma{pp}.state(:,1) = reshape(simd{2}.gamma{pp}.state_k{1},[],1);
    simd{2}.gamma{pp}.state(:,2) = reshape(simd{2}.gamma{pp}.state_k{2},[],1);
    simd{2}.gamma{pp}.state(:,3) = reshape(simd{2}.gamma{pp}.state_k{3},[],1);
    simd{2}.gamma{pp}.input = reshape(simd{2}.gamma{pp}.input_k,[],1);
    
end

%% Plot phase portraits for each class

colormap = {[1 0 0],[0 1 0], [0 0 1], [0 1 1], [1 0 1], [0 1/2 1/2] , [1/2 0 1]};

% '--gs',...
%     'LineWidth',2,...
%     'MarkerSize',10,...
%     'MarkerEdgeColor','b',...
%     'MarkerFaceColor',[0.5,0.5,0.5])

figure(111)

stepps = 25;


h1 = quiver(simd{1}.state(:,1),simd{1}.state(:,2),simd{1}.state(:,2)*0.01,simd{1}.state(:,3)*0.01,'color',[0 0 0],'AutoScale','off');
hold on

pp = 3;
datar1 = simd{2}.gamma{pp}.state(1:stepps:end,1);
datar2 = simd{2}.gamma{pp}.state(1:stepps:end,2);
h(pp) = scatter(datar1,datar2,'cx','LineWidth',0.2);
hold on 
pp = 5;
datar1 = simd{2}.gamma{pp}.state(1:stepps:end,1);
datar2 = simd{2}.gamma{pp}.state(1:stepps:end,2);
h(pp) = scatter(datar1,datar2,'rx','LineWidth',0.5);
hold on 
pp = 6;
datar1 = simd{2}.gamma{pp}.state(1:stepps:end,1);
datar2 = simd{2}.gamma{pp}.state(1:stepps:end,2);
h(pp) = scatter(datar1,datar2,'gx','LineWidth',0.5);
hold off



str_p=sprintf('Linear model phase portraits');

title(str_p,'FontSize',fontS)
xlabel('x','FontSize',fontS)
ylabel('x dot','FontSize',fontS)
h_legend1=legend([h1,h(3),h(5),h(6)],'class 1','class 2 \gamma=0.02','class 2 \gamma=0.1','class 2 \gamma=0.2');
set(h_legend1,'FontSize',12);



%% Loop through various gammas and test lambdas from X

[nn,order] = size(simd{1}.state)
classes = length(simd);

%Loop through all possible param variations
for pp = 1:length(gamma_arr)
    fprintf('param: %f \n',gamma_arr(pp))
    
    clear datars
    datars{1} = simd{1};
    datars{2} = simd{2}.gamma{pp};
    
    Lambdars{pp} = Lambda_Analytical_Min(datars);
    %Lambdars{pp} = Lambda_Analytical(datars);
%     Lambdars{pp}{1,2}=0.1;
%     Lambdars{pp}{2,1}=0.1;
end

%% Test Lambda stuffs

for pp = 1:length(gamma_arr)
    for ii = 1:classes
        for jj = 1:classes
            %subtract other classes with lambda
            if ii ~= jj
                disp('normal')
                Lambdars{pp}{ii,jj}
                disp('opposite')
                %inv(Lambdars{pp}.class{jj}.opposite{ii})
                Lambdars{pp}{jj,ii}
            end
        end
    end
end


%% Train params with lambdars

for pp = 1:length(gamma_arr)
    fprintf('gamma: %f \n',gamma_arr(pp))

    clear datars
    datars{1} = simd{1};
    datars{2} = simd{2}.gamma{pp};
    
    Parameters{pp} = DLS_TrainGeneral_LambdaMatrix(datars, Lambdars{pp}, 1);
    
end

%% Train params with lambdars

tic
parfor pp = 1:length(gamma_arr)
    
    for oo = 1:length(datars)
        
        Classify{pp}.class{oo} = DLS_Online_Pairwise(simd{1}, simd{2}.gamma{pp}, oo, Parameters{pp});
        
    end
    
end

toc