function [Y] = circledisplay(ofs,de,D)
% plot initial circle
clear X Y;
r=D/2;
theta = 0 : 0.0001 : 2*pi;
j = r*cos(theta) + ofs;
k = r*sin(theta);
% figure(1)
% plot(j,k);
% xlabel('xaxis');
% ylabel('yaxis');
% title('Circle Fit Demonstration');
% axis([-200 200 -200 200]);
% Get circle points
X=[-25+de,-104.2,-104.2,-25+de];
Y=[sqrt(r^2-(-25-ofs)^2),sqrt(r^2-(-104.2-ofs)^2),-sqrt(r^2-(-104.2-ofs)^2),-sqrt(r^2-(-25-ofs)^2)];

% hold on
% plot(X,Y,'*')
% hold off
% % Determine center
% xbar = (1/numel(X))*sum(X);
% ybar = (1/numel(Y))*sum(Y);
% u = X-xbar;
% v = Y-ybar;
% u2 = sum(u.*u);
% uv = sum(u.*v);
% u3 = sum(u.*u.*u);
% uv2 = sum(u.*v.*v);
% v2 = sum(v.*v);
% v3 = sum(v.*v.*v);
% vu2 = sum(v.*u.*u);
% syms uc vc;
% f(1) = uc*u2+vc*uv-(1/2)*(u3+uv2);
% f(2) = vc*v2+uc*uv-(1/2)*(v3+vu2);
% [uc,vc] = solve(f(1), f(2));
% xc=vpa(uc+xbar);
% yc=vpa(vc+ybar);
% [data]=[xc,yc];
% %display center on existing graph
% hold on
% plot(subs(xc),subs(yc),'*');
% hold off
