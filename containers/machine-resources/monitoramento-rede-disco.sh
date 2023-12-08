# Obter a primeira amostra
rede1=$(cat /proc/net/dev | grep enp0s3)
disc_data1=$(iostat -d | grep sda)

sleep 1

rede2=$(cat /proc/net/dev | grep enp0s3)

disco=$(df | grep /dev/sda1)
usado=$(echo $disco | awk '{print $3}')
disc_data2=$(iostat -d | grep sda)

# Extrair os valores de bytes e pacotes enviados e recebidos das duas amostras
bytes_sent_1=$(echo "$rede1" | awk '{print $10}')  # bytes enviados na primeira amostra
packet_sent_1=$(echo "$rede1" | awk '{print $11}') # pacotes enviados na primeira amostra

bytes_received_1=$(echo "$rede1" | awk '{print $2}')  # bytes recebidos na primeira amostra
packet_received_1=$(echo "$rede1" | awk '{print $3}') # pacotes recebidos na primeira amostra

bytes_sent_2=$(echo "$rede2" | awk '{print $10}')  # bytes enviados na segunda amostra
packet_sent_2=$(echo "$rede2" | awk '{print $11}') # pacotes enviados na segunda amostra

bytes_received_2=$(echo "$rede2" | awk '{print $2}')  # bytes recebidos na segunda amostra
packet_received_2=$(echo "$rede2" | awk '{print $3}') # pacotes recebidos na segunda amostra

# Calcular as diferenças entre a primeira e a segunda amostra
diff_bytes_sent=$((bytes_sent_2 - bytes_sent_1))
diff_packet_sent=$((packet_sent_2 - packet_sent_1))

diff_bytes_received=$((bytes_received_2 - bytes_received_1))
diff_packet_received=$((packet_received_2 - packet_received_1))

# Salvar os valores de rede no arquivo CSV
echo "$diff_bytes_sent;$diff_packet_sent;$iteration;$date_time" >>log-upload.csv
echo "$diff_bytes_received;$diff_packet_received;$iteration;$date_time" >>log-download.csv

kB_read1=$(echo $disc_data1 | awk '{print $6}')
kB_read2=$(echo $disc_data2 | awk '{print $6}')
kB_wrtn1=$(echo $disc_data1 | awk '{print $7}')
kB_wrtn2=$(echo $disc_data2 | awk '{print $7}')

kB_read=$(($kB_read1 - $kB_read2))
kB_wrtn=$(($kB_wrtn1 - $kB_wrtn2))


echo "$usado;$kB_read;$kB_wrtn;$iteration;$date_time" >>logs/monitoramento-disco.csv
