% made by Jungmin Yoon
%%%%%%%%%%%%%%%%%%% 21.02.09 : WLAN_basic(final) %%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
close all;

W=[32,32,128];
m=[3,5,3];

% W=32;     % Minimum contention window size
% m=3;  %maximum backoff stage

Packet_Payload=8184; %bits
MAC_hdr=272;
PHY_hdr=128;
Data=Packet_Payload+MAC_hdr+PHY_hdr; %Data bit size
Channel_Bit_Rate=1;   %1M bit/s
Data_trans=Data/Channel_Bit_Rate;

ACK=112+PHY_hdr;
RTS=160+PHY_hdr;
CTS=112+PHY_hdr;


Propagation_Delay=1;
Slot_Time=50;
SIFS=28;
DIFS=128;
ACK_Timeout=300;

Total_Time=zeros(1,length(W)); %전체 소요 시간
Station_Num=[5,10,15,20,30,50];
Throughput=zeros(length(W),length(Station_Num));


for simul=1:length(W)
    
    for station=Station_Num
        suc_pkt=0;
        coll_pkt=0;
        CW=zeros(1,station);
        T_nxt_trans=zeros(1,station);

        for i=1:station  %backoff time 설정
            CW(i)=0;
            T_nxt_trans(i)=DIFS+round(W(simul)*rand)*Slot_Time; %rand : 0~1 사이 값, 여기에 W 곱하면 0~32사이 값 나옴
        end

        while suc_pkt<1000000
            T_trans=min(T_nxt_trans);  %최소 backoff 값들 중 최소값 만큼의 backoff slot 이후 전송
            number_trans=sum(T_trans==T_nxt_trans);  %

            if number_trans==1 %전송 성공
                suc_pkt=suc_pkt+1;
                for i=1:station
                    if T_nxt_trans(i)==T_trans
                        if suc_pkt==1000000
                            Total_Time(simul)=T_nxt_trans(i)+Data_trans+Propagation_Delay+SIFS+ACK+Propagation_Delay+DIFS;
                        end
                        CW(i)=0;
                        T_nxt_trans(i)=T_nxt_trans(i)+Data_trans+Propagation_Delay+SIFS+ACK+Propagation_Delay+DIFS+round(W(simul)*rand)*Slot_Time;
                    else
                        T_nxt_trans(i)=T_nxt_trans(i)+Data_trans+Propagation_Delay+SIFS+ACK+Propagation_Delay+DIFS;
                    end
                end

            else  % 충돌발생
                coll_pkt=coll_pkt+1;
                for i=1:station
                    if T_nxt_trans(i)==T_trans
                        if CW(i)<m(simul)
                            CW(i)=CW(i)+1;
                        end
                        T_nxt_trans(i)=T_nxt_trans(i)+Data_trans+Propagation_Delay+ACK_Timeout+DIFS+round((2^CW(i))*W(simul)*rand)*Slot_Time;

                    else
                        T_nxt_trans(i)=T_nxt_trans(i)+Data_trans+Propagation_Delay+ACK_Timeout+DIFS;
                    end
                end
            end
        end
        
        if station==5
            Throughput(simul,1)=Throughput(simul,1)+suc_pkt*(Packet_Payload)/Total_Time(simul);
        elseif station==10
            Throughput(simul,2)=Throughput(simul,2)+suc_pkt*(Packet_Payload)/Total_Time(simul);
        elseif station==15
            Throughput(simul,3)=Throughput(simul,3)+suc_pkt*(Packet_Payload)/Total_Time(simul);
        elseif station==20
            Throughput(simul,4)=Throughput(simul,4)+suc_pkt*(Packet_Payload)/Total_Time(simul);
        elseif station==30
            Throughput(simul,5)=Throughput(simul,5)+suc_pkt*(Packet_Payload)/Total_Time(simul);
        else
            Throughput(simul,6)=Throughput(simul,6)+suc_pkt*(Packet_Payload)/Total_Time(simul);
        end
    end   
end


figure
hold on; grid on;
plot(Station_Num,Throughput(1,:),'-^');
plot(Station_Num,Throughput(2,:),'-s');
plot(Station_Num,Throughput(3,:),'-o');
xlabel('Number of Stations');
ylabel('Saturation Throughput');
legend('basic, W=32, m=3');
xlim([0,50]); ylim([0.50, 0.90]);































