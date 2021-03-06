function K=lbending(Angle,L,E,I)
theta=Angle*(3.1415/180);
S2=sin(theta)*sin(theta);
SC=sin(theta)*cos(theta);
C2=cos(theta)*cos(theta);
S=sin(theta);
C=cos(theta);
coef=(E*I)/(L^3);
K1=[12*S2,-12*SC,-6*L*S,-12*S2,12*SC,-6*L*S];
K2=[-12*SC,12*C2,6*L*C,12*S*C,-12*C2,6*L*C];
K3=[-6*L*S,6*L*C,4*L*L,6*L*S,-6*L*C,2*L*L];
K4=[-12*S2,12*SC,6*L*S,12*S2,-12*SC,6*L*S];
K5=[12*SC,-12*C2,-6*L*C,-12*SC,12*C2,-6*L*C];
K6=[-6*L*S,6*L*C,2*L*L,6*L*S,-6*L*C,4*L*L];
K=coef*[K1;K2;K3;K4;K5;K6];
