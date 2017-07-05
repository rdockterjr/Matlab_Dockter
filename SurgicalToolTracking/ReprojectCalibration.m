%%
% Test accuracy of point reconstruction


dataDir = [pwd '/myCVdataFolder/']
myExt = '.txt';  

filesInfo = dir(dataDir); 

filesInfo = filesInfo(~[filesInfo.isdir])

fileList = 'DepthCalibration.txt'

data = load([dataDir fileList]);
size(data)

%%

% Dimensions
width = 640;
height = 480;

xcenter = width / 2.0;
ycenter = height / 2.0;

% Get Middle Point For X and Y from Each Channel
pixX = (data(:,1) + data(:,3)) / 2.0;
pixY = (data(:,2) + data(:,4)) / 2.0;

disp = data(:,5);

realX = data(:,6);
realY = data(:,7);
realZ = data(:,8);

%%

% values for equations
% Z:
% 712.8527   -0.0137   -0.0163   -0.0708    7.1985
% X:
% 0.0016    0.6588
% Y:
% 0.0016   -0.8497

%%

Az = [712.8527,-0.0137,-0.0163,-0.0708,7.1985];

indataz = [disp,pixX-xcenter,ycenter-pixY];

ZData = depthCal(Az,indataz);


%%

indatax = [ZData,pixX-xcenter];

Ax = [0.0016,0.6588];

XData = XYCal(Ax,indatax);


%%

indatay = [ZData,ycenter-pixY];

Ay = [0.0016,-0.8497];

YData = XYCal(Ay,indatay);

%%

% Plot

s = 5;
c1 = [0,0,1];
c2 = [1,0,0];

figure('name','Checking reprojection at 138mm');


scatter3(XData(1:25), YData(1:25), ZData(1:25),s,c1);
axis([-100 100 -100 100 0 200])
grid on

hold on

scatter3(realX(1:25),realY(1:25),realZ(1:25),s,c2);

hold off

%%

% Plot

s = 5;
c1 = [0,0,1];
c2 = [1,0,0];

figure('name','Checking reprojection at 187mm');


scatter3(XData(26:50), YData(26:50), ZData(26:50),s,c1);
axis([-100 100 -100 100 0 210])
grid on

hold on

scatter3(realX(26:50),realY(26:50),realZ(26:50),s,c2);

hold off

%%

% Plot

s = 5;
c1 = [0,0,1];
c2 = [1,0,0];

figure('name','Checking reprojection at 243mm');


scatter3(XData(51:85), YData(51:85), ZData(51:85),s,c1);
axis([-100 100 -100 100 100 260])
grid on

hold on

scatter3(realX(51:85),realY(51:85),realZ(51:85),s,c2);

hold off

%%

% Plot

s = 5;
c1 = [0,0,1];
c2 = [1,0,0];

figure('name','Checking reprojection at 280mm');


scatter3(XData(86:120), YData(86:120), ZData(86:120),s,c1);
axis([-100 100 -100 100 200 300])
grid on

hold on

scatter3(realX(86:120),realY(86:120),realZ(86:120),s,c2);

hold off

%%

% Plot

s = 5;
c1 = [0,0,1];
c2 = [1,0,0];

figure('name','Checking reprojection at 320mm');


scatter3(XData(121:155), YData(121:155), ZData(121:155),s,c1);
axis([-100 100 -100 100 200 350])
grid on

hold on

scatter3(realX(121:155),realY(121:155),realZ(121:155),s,c2);

hold off