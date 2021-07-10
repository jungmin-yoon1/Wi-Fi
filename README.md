## Wi-Fi

#### DCF 동작 개요
- 단말들은 AP로의 데이터 전송을 위해 채널 상태를 지속적으로 센싱
- 채널이 DIFS (Distributed Interframe Space)동안 idle 상태이면, 단말들은 경쟁을 통한 데이터 전송을 시도
- DCF는 exponential backoff scheme을 사용하기 때문에 각 station들은 contention window(W)를 활용하여 [0, W-1] 내에서 임의의 값을 uniform하게 선택하고 backoff 값으로써 활용
- W는 특정 데이터의 최초 전송 시에 minimum contention window 값 (CWmin)을 가지며, 전송 실패 시 마다 maximum contention window 값(CWmax)까지 2배씩 증가
- 각 단말들은 DIFS 이후에 backoff 값을 backoff slot 마다 1씩 감소시킴, Backoff 값이 0이 되면 해당 단말은 데이터 전송을 시도
- 채널이 특정 단말에 의해 점유되어 busy 상태로 전환하는 경우, 채널을 점유하고 있지 않은 단말들은 backoff 값의 감소를 중지하고 채널상태를 센싱, 채널이 다시 DIFS 시간 동안 idle 상태를 유지하는 경우 station들은 다시 backoff 값을 감소시킬 수 있으며 0이 되면 데이터 전송을 시도
- 1개의 단말만이 backoff값 0에 도달하여 데이터를 전송하는 경우 AP는 충돌 없이 데이터를 수신하며, SIFS (Short Interframe Space) 이후에 데이터를 전송한 단말의 정보를 포함한 ACK (Acknowledgement)를 전송함으로써 성공적으로 데이터 전송이 완료되었음을 알림
- 2개 이상의 단말이 동시에 데이터를 전송하면 충돌이 발생하게 되며, AP는 충돌로 인해 정상적으로 데이터를 수신할 수 없기 때문에 ACK를 전송하지 않음. 데이터를 전송한 단말은 미리 설정된 ACK-timeout 시간 동안 ACK를 수신하지 못하면 충돌이 발생한 것으로 판단
- 충돌이 발생한 단말들은 contention window 크기를 증가시키고 증가된 범위 내에서 backoff 값을 선택,단말이 성공적으로 데이터를 전송하는 경우에는 contention window 크기가 초기 값(CWmin)으로 설정됨
- DCF에는 패킷 전송에 있어서 2가지 방법을 사용, 기본적인 방법으로 Basic access 방법이 있고 다른 하나는 RTS (Ready To Send)/CTS (Clear To Send)를 사용한 access 방법이 있음

#### Basic access
- 단말의 backoff 값이 0이 되는 경우 데이터를 전송
- 특정 단말이 데이터 전송에 성공하는 경우 SIFS시간 이후에 AP가 ACK를 전송
- ACK 전송 이후에는 채널이 idle 상태로 전환되며, DIFS 동안 채널이 idle 상태인 경우 단말들은 다시 데이터 전송을 시도
- 만약 2개 이상의 단말이 데이터를 전송하게 되어 충돌이 발생하면, 데이터 전송 시간 동안 채널을 점유

<img src="https://user-images.githubusercontent.com/58179712/125152180-f1e2ba80-e185-11eb-95af-60dbe42ac3df.PNG"  width="600">


#### RTS/CTS access
- 단말의 backoff 값이 0에 도달하면, 단말은 ACK 수신까지 요구되는 총 채널 점유 시간, 자신의 주소, AP의 주소 등을 포함하여 RTS를 전송
- 단말이 RTS 전송에 성공하면 RTS를 수신한 다른 단말들은 RTS 내에 포함된 총 채널 점유 시간 동안 채널이 busy한 것으로 판단
- AP의 경우 총 채널 점유 시간, 자신의 주소, RTS를 전송한 단말의 주소 등을 포함하여 CTS를 전송
- 단말들은 CTS에 포함된 주소 정보와 자신의 주소를 비교하며, 자신의 주소와 일치하는 경우 데이터를 전송
- 만약 자신의 주소와 일치하지 않는 경우 CTS에 포함된 총 채널 점유 시간 동안 채널이 busy한 것으로 판단
- 단말의 데이터 전송 이후에 AP는 ACK를 전송하며, 이후 단말의 데이터 전송 과정은 반복

<img src="https://user-images.githubusercontent.com/58179712/125152182-f313e780-e185-11eb-8298-96073b797638.PNG"  width="800">


#### Simulation Result

<img src="https://user-images.githubusercontent.com/58179712/125152660-0eccbd00-e189-11eb-86cb-8515809bfcc7.PNG"  width="500">

