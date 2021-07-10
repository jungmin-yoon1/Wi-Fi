clear;
clc;
close all;

W_rc=[16,32];    %rts_cts W 초기값
m_rc=[3,3];        %rts_cts m
W_ris=[16,32]; %RIS_rts_cts W 초기값
m_ris=[3,3];

Pkt_success_num=1000000; % AP가 받으려는 단말의 packet 수
Packet_Payload=8184;  %bits, 주어진 변수
MAC_hdr=272;
PHY_hdr=128;
Data=Packet_Payload+MAC_hdr+PHY_hdr;  %Data bit size
Channel_Bit_Rate=1;   %1M bit/s

ACK=112+PHY_hdr;
RTS=160+PHY_hdr;
CTS=112+PHY_hdr;

RIS_Control=160+PHY_hdr; %RIS 제어 message

Propagation_Delay=1;  %주어진 시간 변수
Slot_Time=50;
SIFS=28;
DIFS=128;
ACK_Timeout=300;
CTS_Timeout=300;


Total_Time_rc=zeros(1,length(W_rc));    %전체 소요 시간
Total_Time_ris=zeros(1,length(W_ris));

%Station_Num=[20,40,60,2,30,100];         %station 수의 종류
Station_Num=[5,10,15,20,30,50];         %station 수의 종류
%Station_Num=[20]; 
Throughput_rc=zeros(length(W_rc),length(Station_Num)); %rts_cts throughput
Throughput_ris=zeros(length(W_ris),length(Station_Num)); %rts_cts throughput


for simul_rc=1:length(W_rc)
    for station_rc=Station_Num
        suc_pkt_rc=0; %success packet 수
        coll_pkt_rc=0; %collision packet 수
        
        CW_rc=zeros(1,station_rc); %contention window 크기 초기화
        m=zeros(1,station_rc);
        T_nxt_trans_rc=zeros(1,station_rc); %다음 전송까지 걸리는 시간 설정&초기화
        
        for i=1:station_rc  %backoff time 설정
            CW_rc(i)=randi(W_rc(simul_rc))-1; % contention window에서 backoff 값 선택
            T_nxt_trans_rc(i)=DIFS+(2^m(i))*CW_rc(i)*Slot_Time;
        end
    
        while suc_pkt_rc<1000000
            
            T_trans_rc=min(T_nxt_trans_rc);  %최소 backoff 값들 중 최소값 만큼의 backoff slot 이후 전송
            number_trans_rc=sum(T_trans_rc==T_nxt_trans_rc);  
            
            if number_trans_rc==1  %전송 성공
                suc_pkt_rc=suc_pkt_rc+1; %성공시 success packet 수 증가
                
                for i=1:station_rc % 성공시 모든 station의 시간을 측정하고
                    if T_nxt_trans_rc(i)==T_trans_rc
                        Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+DIFS+backoff_time+(RTS+Propagation_Delay)+SIFS+(CTS+Propagation_Delay)+SIFS+(Data+Propagation_Delay)+SIFS+(ACK+Propagation_Delay);
                        m=0;
                        CW_rc(i)=randi(W_rc(simul_rc))-1;
                        else
                            Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+DIFS+backoff_time+(RTS+Propagation_Delay)+SIFS+(CTS+Propagation_Delay)+SIFS+(Data+Propagation_Delay)+SIFS+(ACK+Propagation_Delay);
                        end
                    end
                end
                

                
            else %충돌 발생
                coll_pkt_rc=coll_pkt_rc+1; %충돌시 collision packet 수 증가
               % Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+DIFS+backoff_time+(RTS+Propagation_Delay);
                
                for i=1:length(CW_rc) %backoff 0이 된 단말들 다시 backoff 값 뽑기
                    if CW_rc(i)==0 %충돌 일으킨 단말
                        m=m+1;
                        if m>m_rc(simul_rc)
                            m=m_rc(simul_rc);
                        end
                        CW_rc(i)=randi((2^m)*W_rc(simul_rc))-1;
                    end
                    Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+DIFS+backoff_time+(RTS+Propagation_Delay);
                end
            end
        end
        
        
        %RTS/CTS access throughput 계산
        if station_rc==Station_Num(1)
            Throughput_rc(simul_rc,1)=Throughput_rc(simul_rc,1)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
        elseif station_rc==Station_Num(2)
            Throughput_rc(simul_rc,2)=Throughput_rc(simul_rc,2)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
        elseif station_rc==Station_Num(3)
            Throughput_rc(simul_rc,3)=Throughput_rc(simul_rc,3)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
        elseif station_rc==Station_Num(4)
            Throughput_rc(simul_rc,4)=Throughput_rc(simul_rc,4)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
        elseif station_rc==Station_Num(5)
            Throughput_rc(simul_rc,5)=Throughput_rc(simul_rc,5)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
        else
            Throughput_rc(simul_rc,6)=Throughput_rc(simul_rc,6)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
        end
    end
end





% plot(W_ris,Total_Time_ris,'-*');

% 
% 
% for simul_rc=1:length(W_rc)
%     for station_rc=Station_Num
%         suc_pkt_rc=0; %success packet 수
%         coll_pkt_rc=0; %collision packet 수
%         
%         CW_rc=zeros(1,station_rc); %contention window 크기 초기화
%         
%         for i_backoff=1:station_rc  %backoff time 설정
%             CW_rc(i_backoff)=randi(W_rc(simul_rc))-1; % contention window에서 backoff 값 선택
%         end
%     
%         while suc_pkt_rc<1000000
%             
%             min_backoff=min(CW_rc); %backoff 최소값 뽑기, 해당 단말 전송
%             backoff_time=min_backoff*Slot_Time; % 최소값 만큼 시간 지남
%             CW_rc=CW_rc-min_backoff; %전송후 남은 단말 backoff count down
%             number_trans_rc=sum(0==CW_rc); %backoff=0 되어서 전송하려는 단말 수
%             
%             if number_trans_rc==1  %전송 성공
%                 suc_pkt_rc=suc_pkt_rc+1; %성공시 success packet 수 증가
%                 
%                 for i=1:station_rc % 성공시 모든 station의 시간을 측정하고
%                     for j=1:length(CW_rc)
%                         if CW_rc(i)==0
%                             Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+DIFS+backoff_time+(RTS+Propagation_Delay)+SIFS+(CTS+Propagation_Delay)+SIFS+(Data+Propagation_Delay)+SIFS+(ACK+Propagation_Delay);
%                             m=0;
%                             CW_rc(i)=randi(W_rc(simul_rc))-1;
%                         else
%                             Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+DIFS+backoff_time+(RTS+Propagation_Delay)+SIFS+(CTS+Propagation_Delay)+SIFS+(Data+Propagation_Delay)+SIFS+(ACK+Propagation_Delay);
%                         end
%                     end
%                 end
%                 
% 
%                 
%             else %충돌 발생
%                 coll_pkt_rc=coll_pkt_rc+1; %충돌시 collision packet 수 증가
%                % Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+DIFS+backoff_time+(RTS+Propagation_Delay);
%                 
%                 for i=1:length(CW_rc) %backoff 0이 된 단말들 다시 backoff 값 뽑기
%                     if CW_rc(i)==0 %충돌 일으킨 단말
%                         m=m+1;
%                         if m>m_rc(simul_rc)
%                             m=m_rc(simul_rc);
%                         end
%                         CW_rc(i)=randi((2^m)*W_rc(simul_rc))-1;
%                     end
%                     Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+DIFS+backoff_time+(RTS+Propagation_Delay);
%                 end
%             end
%         end
%         
%         
%         %RTS/CTS access throughput 계산
%         if station_rc==Station_Num(1)
%             Throughput_rc(simul_rc,1)=Throughput_rc(simul_rc,1)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
%         elseif station_rc==Station_Num(2)
%             Throughput_rc(simul_rc,2)=Throughput_rc(simul_rc,2)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
%         elseif station_rc==Station_Num(3)
%             Throughput_rc(simul_rc,3)=Throughput_rc(simul_rc,3)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
%         elseif station_rc==Station_Num(4)
%             Throughput_rc(simul_rc,4)=Throughput_rc(simul_rc,4)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
%         elseif station_rc==Station_Num(5)
%             Throughput_rc(simul_rc,5)=Throughput_rc(simul_rc,5)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
%         else
%             Throughput_rc(simul_rc,6)=Throughput_rc(simul_rc,6)+suc_pkt_rc*(Packet_Payload)/Total_Time_rc(simul_rc);
%         end
%     end
% end




figure
hold on; grid on;


plot(Station_Num,Throughput_rc(1,:),'-s');
plot(Station_Num,Throughput_rc(2,:),'-d');
xlabel('Number of Stations');
ylabel('Saturation Throughput');
legend('RIS-WiFi, W=32','RIS-WiFi, W=128','WiFi, W=32','WiFi, W=128')





















