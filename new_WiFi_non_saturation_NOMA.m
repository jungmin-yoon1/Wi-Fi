%%%%%%%made by Jungmin Yoon%%%%%%%%%%%
%%%%%%%% WiFi_no_saturation_NOMA %%%%%%%%% propagation delay 없음

clear;
clc;
close all;

W_rc=[16,32];
m_rc=[3,3];

Packet_Payload=8184;
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

Total_Time_rc=zeros(1,length(W_rc));    %전체 소요 시간
Station_Num=[20 40 60 80 100 120];
Throughput_rc=zeros(length(W_rc),length(Station_Num)); %rts_cts throughput

for simul_rc=1:length(W_rc)
    
    for station_rc=Station_Num
      
        Total_Time_rc=zeros(1,length(W_rc));    %전체 소요 시간
        suc_pkt_rc=0;
        
        while suc_pkt_rc<1000000 %받으려는 전체 패킷 수  
            
            backoff=randi([0,W_rc(simul_rc)-1],[1,station_rc]);
            CWcase=ones(1,station_rc);
            
            while sum(backoff)~=0 %station 개수만큼 반복
                min_backoff=min(backoff);
                backoff=backoff-min_backoff;
                Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+DIFS+min_backoff*Slot_Time;
                
                if  nnz(backoff==0)>1 %충돌 나는 경우 backoff 0의 개수가 2 이상일때
                    col_case=find(backoff==0); %find: 조건에 맞는 숫자의 위치 정보 배열로 저장
                    
                    P=zeros(1,length(backoff));%NOMA를 위한 전체 high/low 확률
                    for i_p=1:length(P)
                        P(i_p)=rand;
                    end
                    P_col=zeros(1,length(col_case));% 충돌난 부분의 high/low
                    for i_pc=1:length(P_col)
                        P_col(i_pc)=P(col_case(i_pc));
                    end
                       
                    high=0; %high low 개수 파악
                    low=0;
                    for i_h=1:length(P_col)
                        if P_col(i_h)>0.5
                            high=high+1;
                        else
                            low=low+1;
                        end
                    end
                    k=1;
                    
                    if high==1
                        if low==1 %Noma로 2개 전송 가능
                            suc_pkt_rc=suc_pkt_rc+2;
                            CWcase(backoff==0)=[];
                            backoff(backoff==0)=[];
                            Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+(RTS+Propagation_Delay)+SIFS+(CTS+Propagation_Delay)+SIFS+(Data+Propagation_Delay)+SIFS+(ACK+Propagation_Delay);
                            
                        else %high 1개 성공 나머지 low 충돌
                            for i_cc=1:length(col_case)
                                if P(col_case(i_cc))>0.5
                                    suc_pkt_rc=suc_pkt_rc+1;
                                    CWcase(col_case(i_cc))=[];
                                    backoff(col_case(i_cc))=[];
                                    Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+(RTS+Propagation_Delay)+SIFS+(CTS+Propagation_Delay)+SIFS+(Data+Propagation_Delay)+SIFS+(ACK+Propagation_Delay);
                                    
                                    col_case_update=find(backoff==0); 
                                    for i=1:length(col_case_update)
                                        if CWcase(col_case_update(i))<m_rc(simul_rc)
                                            backoff(col_case_update(i))=randi([0, W_rc(simul_rc)*2^(CWcase(col_case_update(i)))-1]);
                                            CWcase(col_case_update(i))=CWcase(col_case_update(i))+1;
                                        else
                                            backoff(col_case_update(i))=randi([0,W_rc(simul_rc)*2^(CWcase(col_case_update(i)))-1]);
                                        end
                                        
                                    end 
                                end
                            end 
                        end
                        
                    else % 충돌 high 2개 이상
                        for i=1:length(col_case)
                            if CWcase(col_case(i))<m_rc(simul_rc)
                                backoff(col_case(i))=randi([0, W_rc(simul_rc)*2^(CWcase(col_case(i)))-1]);
                                CWcase(col_case(i))=CWcase(col_case(i))+1;
                            else
                                backoff(col_case(i))=randi([0,W_rc(simul_rc)*2^(CWcase(col_case(i)))-1]);
                            end
                            Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+RTS+Propagation_Delay;
                        end 
                    end
  
                else %충돌 안난 경우
                    suc_pkt_rc=suc_pkt_rc+1;
                    CWcase(backoff==0)=[];
                    backoff(backoff==0)=[];
                    Total_Time_rc(simul_rc)=Total_Time_rc(simul_rc)+(RTS+Propagation_Delay)+SIFS+(CTS+Propagation_Delay)+SIFS+(Data+Propagation_Delay)+SIFS+(ACK+Propagation_Delay);
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

figure
hold on; grid on;
plot(Station_Num,Throughput_rc(1,:),'-*');
plot(Station_Num,Throughput_rc(2,:),'-d');
xlabel('Number of Stations');
ylabel('Saturation Throughput');
xlim([20,120]); ylim([0.50, 1.5]);
legend('rts-cts, W=16, m=3','rts-cts, W=32, m=3')
















