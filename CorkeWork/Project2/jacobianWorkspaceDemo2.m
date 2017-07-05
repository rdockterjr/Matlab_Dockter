
% mdl_planar2;
% mdl_twolink;
% mdl_twolink_mdh;

% Make planar 2 link robot
L1 = 1;
L2 = 1;
L(1) = Link( [ 0 0 L1 0]);
L(2) = Link( [ 0 0 L2 0]);

TwoLink = SerialLink(L, 'name', 'my2Link')

%% t = [0:.05:2]'; % time vector

q0 = [0 0];
qf = rand(1,2)*2;
%q = jtraj(q0, qf, t); % generate joint coordinate trajectory

figure(1)
TwoLink.plot(q0); hold on
% TwoLink.plot(qf);


%% Jacobians
% 
% % jacobn Jacobian matrix in tool frame
% % jacob dot Jacobian derivative
% % maniplty manipulability
% % vellipse display velocity ellipsoid
% % fellipse display force ellipsoid
% % qmincon null space motion to centre joints between limits

figure(10)
TwoLink.vellipse(qf); hold on
TwoLink.vellipse(q0); hold on
J0 = TwoLink.jacob0 (q0)

figure(11);clf; 
for i = [0:.5:2*pi]
    for j = [0:.2:2*pi]
        J = TwoLink.jacob0([i,j]);
        %plot_ellipse( J(1:3)*J(1:3)'); hold on     
        T = TwoLink.fkine([i,j]);
        x = T(1,end);
        y = T(2,end);
        
        plot3(x,y, TwoLink.maniplty([i j], 'yoshikawa'),'rx'); hold on
        plot3(x,y, TwoLink.maniplty([i j], 'asada'),'gx'); hold on
        plot3(x,y, sqrt(det(J(1:2,1:2)*J(1:2,1:2)')),'b.'); hold on
    end
end
grid on
xlabel('q1')
ylabel('q2')
zlabel('Manipulability')
legend('Yoshikawa', 'asada' ,'sqrt(det(J(1:2)*J(1:2)''');


%%
figure(12);clf; 
Jdet = [];
for i = [0:.5:2*pi]
    for j = [0:.2:2*pi]
        J = TwoLink.jacob0([i,j]);
        %plot_ellipse( J(1:3)*J(1:3)'); hold on 
        J = J(1:2, 1:2);
        S = svd(J);
        plot3(i,j, min(S),        'rx'); hold on
        plot3(i,j, max(S),        'gx'); hold on
        plot3(i,j, min(S)./max(S),'b.'); hold on
    end
end
grid on
xlabel('q1')
ylabel('q2')
zlabel('Manipulability')
legend('min(\sigma)', 'max(\sigma)' ,'min(\sigma)./max(\sigma)');


%% Reachable workspace
figure(13);clf; 
Jdet = [];
NullSpace = [];
for i = [0:.5:2*pi]
    for j = [0:.05:2*pi]
        J = TwoLink.jacob0([i,j]);
        %plot_ellipse( J(1:3)*J(1:3)'); hold on 
        J = J(1:2, 1:2);
        Jdet = det(J);
        if abs(Jdet) < .2
            plot3(i,j, Jdet,'b.'); hold on
            NullSpace(end+1,:) = [i j];
        end
    end
end
grid on
xlabel('q1')
ylabel('q2')
zlabel('Jdet')
title('|det(J)| < \epsilon = 0.1 ')

%%
figure(14);
clf
for i = 1:length(NullSpace)
    
    subplot(2,1,1)
    plot(NullSpace(i,:),'.'); hold on
    xlabel('q1')
    ylabel('q2')
    title('Null Space over Joints')
    
    subplot(2,1,2);
    T = TwoLink.fkine(NullSpace(i,:));
    x = T(1, end);
    y = T(2, end);
    plot( x,y ,'.'); hold on
    xlabel('x pos')
    ylabel('y pos')
    title('Null Space over Base Cooredinates (Cartesian x,y)')
end
