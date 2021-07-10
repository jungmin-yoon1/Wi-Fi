clear; clc;
%parameter
rate_b = 1e6;
rate_d = 1e6;
PHY_hdr = 128;
MAC_hdr = 272;
ACK = 112 + PHY_hdr;
RTS = 160 + PHY_hdr; 
CTS = 112 + PHY_hdr;
SIFS = 28e-6;
DIFS = 128e-6;
EP = 8184;
delta = 1e-6;
sigma = 50e-6;
H = PHY_hdr + MAC_hdr;
TIME_OUT=300e-6;

% i \in (0,m) is called backoff stage

% The key approximation in our model is that, at each transmission
% attempt, and regardless of the number of retransmissions
% suffered, each packet collides with constant and independent
% probability p. It is intuitive that this assumption results more
% accurate as long as W and n get larger. p will be referred to as
% conditional collision probability, meaning that this is the probability
% of a collision seen by a packet being transmitted on the channel.
p = 0;
p_diff = 1;
p_diff_th = 1e-4;
loop_max = inf;
loop = 1;
S=zeros(1,99);
P_e_success=zeros(1,99);
P_e_collision=zeros(1,99);
m = 3;%maximum backoff stage
W = 32;%initial contention window
ROT = 0;

% Part A. Packet Transmission Probability
for n=2:100%number of stations
    ROT=ROT+1;
    W_i = 2.^(0:1:m)*W;%contention window initialization
    p = 0;
    p_diff = 1;
    p_diff_th = 1e-4;
    loop_max = inf;
    loop = 1;
while p_diff > p_diff_th
    % b(t): the stochastic process representing the backoff time counter 
    %       for a given station
    % s(t): the stochastic process representing the backoff stage 
    %       (0, ..., m) of the station at time t
    % b_{i,k}=lim_{t \to \inf} P{s(t) = i, b(t) = k}, i \in (0,m), 
    % k \in (0,W_i - 1) be the stationary distribution of the chain.
    b = zeros(m + 1, W_i(m+1)-1+1);
    b(0+1, 0+1) = ... b_{0,0} 
        2*(1 - 2*p)*(1 - p)/((1 - 2*p)*(W + 1) + p*W*(1 - (2*p)^m));
    for i=1:1:(m - 1)
        b(i+1, 0+1) = (p^i)*b(0+1, 0+1); % b_{i,0}
    end
    b(m+1, 0+1) = (p^m)/(1 - p)*b(0+1, 0+1); % b_{m,0}
    i = 0;
    
    for k=1:1:(W_i(i+1) - 1)
        b(i+1, k+1) = (W_i(i+1) - k)/W_i(i+1) ... b_{0,k}
            *(1 - p)*sum(b(:,0+1),1);
    end
    
    for i=1:1:(m - 1)
        for k=1:1:(W_i(i+1) - 1)
            b(i+1, k+1) = (W_i(i+1) - k)/W_i(i+1) ... b_{i,k}
                *p*b((i-1)+1, 0+1);
        end
    end
    
    i = m;
    
    for k=1:1:(W_i(i+1) - 1)
        b(i+1, k+1) = (W_i(i+1) - k)/W_i(i+1) ... b_{m,k}
            *p*(b((m-1)+1, 0+1) + b(m+1, 0+1));
    end
    
    assert(abs(sum(sum(b)) - 1) < 1e-4); % the sum of all the state is 1
    % 조건이 false인 경우 오류 발생시키기(Throw Error)
    
    % We can now express the probability that a station transmits
    % in a randomly chosen slot time.
    tau = b(0+1, 0+1)/(1 - p);%transmission probability
    
    % The fundamental independence assumption given above implies that
    % each transmission “sees” the system in the same state, i.e., in
    % steady state. At steady state, each remaining station transmits a
    % packet with probability \tau.
%     p_history(loop) = p;
    p_old = p;
    p = 1 - (1 - tau)^(n - 1);
    p_diff = abs(p - p_old);
    loop = loop + 1;

    if loop > loop_max
        fprintf('ieee80211dcf: too many iteration. p_diff = %f\n',p_diff);
        break;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%Markov chain finish%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Part B. Throughput

% Let P_{tr} be the probability that there is at least one transmission 
% in the considered slot time
P_tr = 1 - (1 - tau)^n;

% The probability P_s that a transmission occurring on the channel
% is successful is given by the probability that exactly one station
% transmits on the channel, conditioned on the fact that at least
% one station transmits


% the average time the channel is sensed busy by each station
% during a collision.
T_c = (RTS)/rate_b + DIFS + delta +TIME_OUT;

% the average time the channel is sensed busy (i.e.,
% the slot time lasts) because of a successful transmission
T_s = (RTS)/rate_b + SIFS + delta + (CTS)/rate_b + SIFS + delta + (H ...
    + EP)/rate_d + SIFS + delta + (ACK)/rate_b + DIFS + delta + sigma;


P_s = n*tau*(1 - tau)^(n - 1)/P_tr;

% Let S be the normalized system throughput, defined as the
% fraction of time the channel is used to successfully transmit payload
% bits
 
S(ROT)= P_s*P_tr*(EP)/rate_d ...
         /((1 - P_tr)*sigma + P_tr*P_s*T_s + P_tr*(1 - P_s)*T_c);
end