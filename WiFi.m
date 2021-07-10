% made by Jungmin Yoon
%%%%%%%%%%%%%%%%%%% 21.02.09 : WLAN(final) %%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
close all;
W_b=[32,32,128]; %basic W 초기값
m_b_max=[3,5,3];       %basic m
W_rc=[32,128];    %rts_cts W 초기값
m_rc_max=[3,3];        %rts_cts m

Packet_Payload=8184; %bits, 주어진 변수
MAC_hdr=272;
PHY_hdr=128;
Data=Packet_Payload+MAC_hdr+PHY_hdr; %Data bit size
Channel_Bit_Rate=1;   %1M bit/s
Data_trans=Data/Channel_Bit_Rate;

ACK=112+PHY_hdr;
RTS=160+PHY_hdr;
CTS=112+PHY_hdr;


Propagation_Delay=1;  %주어진 시간 변수
Slot_Time=50;
SIFS=28;
DIFS=128;
ACK_Timeout=300;
CTS_Timeout=300;

Total_Time_b=zeros(1,length(W_b));     %전체 소요 시간
Total_Time_rc=zeros(1,length(W_rc));    %전체 소요 시간
Station_Num=[5,10,15,20,30,50];         %station 수의 종류
Throughput_b=zeros(length(W_b),length(Station_Num));  %basic throughput
Throughput_rc=zeros(length(W_rc),length(Station_Num)); %rts_cts throughput


for simul_b=1:length(W_b)   %Basic Access method
    
    for station_b=Station_Num 
        suc_pkt_b=0;  %success packet 수
        coll_pkt_b=0;  %collision packet 수
       
        m_b=zeros(1,station_b); %contention window 크기 초기화
        T_nxt_trans_b=zeros(1,station_b); %다음 전송까지 걸리는 시간 설정&초기화

        for i=1:station_b  %backoff time 설정
            T_nxt_trans_b(i)=DIFS+(randi(W_b(simul_b))-1)*Slot_Time; %rand : 0~1 사이 값, 여기에 W 곱하면 0~32사이 값 나옴
            
        end

        while suc_pkt_b<1000000
            T_trans_b=min(T_nxt_trans_b);  %최소 backoff 값들 중 최소값 만큼의 backoff slot 이후 전송
            number_trans_b=sum(T_trans_b==T_nxt_trans_b);  

            if number_trans_b==1 %전송 성공
                suc_pkt_b=suc_pkt_b+1; %성공시 success packet 수 증가
                for i=1:station_b  % 성공시 모든 station의 시간을 측정하고 성공 횟수가 1000000번이 되면 총 소요 시간 계산
                    if T_nxt_trans_b(i)==T_trans_b %전송을 성공한 station의 경우
                        if suc_pkt_b==1000000
                            Total_Time_b(simul_b)=T_nxt_trans_b(i)+Data_trans+Propagation_Delay+SIFS+ACK+Propagation_Delay+DIFS;
                        end
                        m_b(i)=0;
                        T_nxt_trans_b(i)=T_nxt_trans_b(i)+Data_trans+Propagation_Delay+SIFS+ACK+Propagation_Delay+DIFS+(randi(W_b(simul_b))-1)*Slot_Time;
                    else  %전송을 성공한 station 제외 나머지 경우
                        T_nxt_trans_b(i)=T_nxt_trans_b(i)+Data_trans+Propagation_Delay+SIFS+ACK+Propagation_Delay+DIFS;
                    end
                end

            else  % 충돌발생
                coll_pkt_b=coll_pkt_b+1; %충돌시 collision packet 수 증가
                for i=1:station_b  %충돌시 모든 station의 시간을 측정
                    if T_nxt_trans_b(i)==T_trans_b  %충돌을 일으킨 station의 경우
                        if m_b(i)<m_b_max(simul_b)     %지정한 contention window 크기의 최대(m_b)보다 작으면 stage 증가
                            m_b(i)=m_b(i)+1;
                        end
                        T_nxt_trans_b(i)=T_nxt_trans_b(i)+Data_trans+Propagation_Delay+DIFS+(randi((2^m_b(i))*W_b(simul_b))-1)*Slot_Time;

                    else %충돌을 일으키지 않은 나머지 station의 경우
                        T_nxt_trans_b(i)=T_nxt_trans_b(i)+Data_trans+Propagation_Delay+DIFS;
                    end
                end
            end            
        end
        
        %Basic A ccess throughput 계산
        if station_b==5
            Throughput_b(simul_b,1)=Throughput_b(simul_b,1)+suc_pkt_b*(Packet_Payload)/Total_Time_b(simul_b);
        elseif station_b==10
            Throughput_b(simul_b,2)=Throughput_b(simul_b,2)+suc_pkt_b*(Packet_Payload)/Total_Time_b(simul_b);
        elseif station_b==15
            Throughput_b(simul_b,3)=Throughput_b(simul_b,3)+suc_pkt_b*(Packet_Payload)/Total_Time_b(simul_b);
        elseif station_b==20
            Throughput_b(simul_b,4)=Throughput_b(simul_b,4)+suc_pkt_b*(Packet_Payload)/Total_Time_b(simul_b);
        elseif station_b==30
            Throughput_b(simul_b,5)=Throughput_b(simul_b,5)+suc_pkt_b*(Packet_Payload)/Total_Time_b(simul_b);
        else
            Throughput_b(simul_b,6)=Throughput_b(simul_b,6)+suc_pkt_b*(Packet_Payload)/Total_Time_b(simul_b);
        end
    end   
end

for simul_rc=1:length(W_rc)   %RTS/CTS Access method
    
    for station_rc=Station_Num
        suc_pkt_rc=0; %success packet 수
        coll_pkt_rc=0; %collision packet 수
       
        m_rc=zeros(1,station_rc); %contention window 크기 초기화
        T_nxt_trans_rc=zeros(1,station_rc); %다음 전송까지 걸리는 시간 설정&초기화

        for i=1:station_rc  %backoff time 설정
            m_rc(i)=0;  %RTS_CTS
            T_nxt_trans_rc(i)=DIFS+(randi(W_rc(simul_rc))-1)*Slot_Time; %rand : 0~1 사이 값, 여기에 W 곱하면 0~32사이 값 나옴
            
        end

        while suc_pkt_rc<1000000
            T_trans_rc=min(T_nxt_trans_rc);  %최소 backoff 값들 중 최소값 만큼의 backoff slot 이후 전송
            number_trans_rc=sum(T_trans_rc==T_nxt_trans_rc);  

            if number_trans_rc==1 %전송 성공
                suc_pkt_rc=suc_pkt_rc+1; %성공시 success packet 수 증가
                for i=1:station_rc % 성공시 모든 station의 시간을 측정하고 성공 횟수가 1000000번이 되면 총 소요 시간 계산
                    if T_nxt_trans_rc(i)==T_trans_rc   %전송을 성공한 station의 경우
                        if suc_pkt_rc==1000000
                            Total_Time_rc(simul_rc)=T_nxt_trans_rc(i)+(RTS+Propagation_Delay)+SIFS+(CTS+Propagation_Delay)+SIFS+(Data+Propagation_Delay)+SIFS+(ACK+Propagation_Delay)+DIFS;
                        end
                        m_rc(i)=0;
                        T_nxt_trans_rc(i)=T_nxt_trans_rc(i)+(RTS+Propagation_Delay)+SIFS+(CTS+Propagation_Delay)+SIFS+(Data+Propagation_Delay)+SIFS+(ACK+Propagation_Delay)+DIFS+(randi(W_rc(simul_rc))-1)*Slot_Time;
                    else    %전송을 성공한 station 제외 나머지 경우
                        T_nxt_trans_rc(i)=T_nxt_trans_rc(i)+(RTS+Propagation_Delay)+SIFS+(CTS+Propagation_Delay)+SIFS+(Data+Propagation_Delay)+SIFS+(ACK+Propagation_Delay)+DIFS;
                    end
                end

            else  % 충돌발생
                coll_pkt_rc=coll_pkt_rc+1; %충돌시 collision packet 수 증가
                for i=1:station_rc %충돌시 모든 station의 시간을 측정
                    if T_nxt_trans_rc(i)==T_trans_rc %충돌을 일으킨 station의 경우
                        if m_rc(i)<m_rc_max(simul_rc)  %지정한 contention window 크기의 최대(m_rc)보다 작으면 stage 증가
                            m_rc(i)=m_rc(i)+1; 
                        end
                        T_nxt_trans_rc(i)=T_nxt_trans_rc(i)+RTS+Propagation_Delay+DIFS+(randi((2^m_rc(i))*W_rc(simul_rc))-1)*Slot_Time;

                    else %충돌을 일으키지 않은 나머지 station의 경우
                        T_nxt_trans_rc(i)=T_nxt_trans_rc(i)+RTS+Propagation_Delay+DIFS;
                    end
                end
            end            
        end
        
        %RTS/CTS access throughput 계산
        if station_rc==5
            Throughput_rc(simul_rc,1)=Throughput_rc(simul_rc,1)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
        elseif station_rc==10
            Throughput_rc(simul_rc,2)=Throughput_rc(simul_rc,2)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
        elseif station_rc==15
            Throughput_rc(simul_rc,3)=Throughput_rc(simul_rc,3)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
        elseif station_rc==20
            Throughput_rc(simul_rc,4)=Throughput_rc(simul_rc,4)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
        elseif station_rc==30
            Throughput_rc(simul_rc,5)=Throughput_rc(simul_rc,5)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
        else
            Throughput_rc(simul_rc,6)=Throughput_rc(simul_rc,6)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
        end
    end   
end


figure
hold on; grid on;
plot(Station_Num,Throughput_b(1,:),'-^');
plot(Station_Num,Throughput_b(2,:),'-s');
plot(Station_Num,Throughput_b(3,:),'-o');
plot(Station_Num,Throughput_rc(1,:),'-*');
plot(Station_Num,Throughput_rc(2,:),'-d');
xlabel('Number of Stations');
ylabel('Saturation Throughput');
legend('basic, W=32, m=3');
xlim([0,50]); ylim([0.50, 0.90]);
legend('basic, W=32, m=3', 'basic, W=32, m=5','basic, W=128, m=3','rts-cts, W=32, m=3','rts-cts, W=128, m=3')































