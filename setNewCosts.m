function [costs] = setNewCosts(costs,delta,trial)
%setNewCosts Use delta to set new operation costs
% Takes costs in, returns new costs
% update parameter values by delta, decrement, increment
ntrials = 32;

excdelta = zeros(1,size(costs,2));
excdelta(costs~=0) = 1;
try
    excdelta(costs~=0) = excdelta(costs~=0).*delta(1:sum(costs~=0));
catch
    error = true;
end
% the executable delta vector of the proper size

%costs = costs + (1/(trial-1)).*excdelta;
%costs = costs.*exp(-excdelta.*(trial-1));
costs = costs.*(1+(excdelta.*((trial-1)/ntrials)));
% ^ last delta scheme
%costs = costs.*(1+excdelta);
%costs = costs+(excdelta.*(trial-1)/trial);
%costs = costs+excdelta;

end
