function [pw, Jf, Jpf] = fromFrame(F, pf)
% FROMFRAME Transform a point pf from local frame F to the global frame.
%
% In:
% F : reference frame F = [f x ; f y ; f alpha]
% pf: point in frame pf = [pf x ; pf y]
% Out:
% pw: point in global frame
% Jf: Jacobian wrt F
% Jpf: Jacobian wrt pf

% (c) 2010, 2011, 2012 Joan Sola
    t = F(1:2);
    a = F(3);
    R = [cos(a) -sin(a) ; sin(a) cos(a)];
    pw = R*pf + repmat(t,1,size(pf,2)); % Allow for multiple points
    
    if nargout > 1 % Jacobians requested
        px = pf(1);
        py = pf(2);
        Jf = [...
        [ 1, 0, -py*cos(a) - px*sin(a)]
        [ 0, 1, px*cos(a) - py*sin(a)]];
        Jpf = R;
    end
end