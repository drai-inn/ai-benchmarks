#!/bin/bash -e

model=$1
tensor_parallel_size=$2
input_len=$3
output_len=$4
batch_size=$5
dtype=$6

run_name=${model##*/}-tps-${tensor_parallel_size}-inlen-${input_len}-outlen-${output_len}-batchsize-${batch_size}-dtype-${dtype}
LOG=${run_name}.out

source ~/vllmenv/bin/activate

# start collecting GPU stats in the background
nvidia-smi --query-gpu=timestamp,uuid,clocks_throttle_reasons.sw_thermal_slowdown,utilization.gpu,utilization.memory,memory.used,memory.total,temperature.gpu,power.draw,clocks.current.sm --format=csv,nounits -l 5 -f ${run_name}-gpu-stats.out &
gpu_stats_pid=$!

if [ "${tensor_parallel_size}" = "1" ]; then
    export CUDA_VISIBLE_DEVICES=0
elif [ "${tensor_parallel_size}" = "2" ]; then
    export CUDA_VISIBLE_DEVICES=0,1
elif [ "${tensor_parallel_size}" = "2" ]; then
    export CUDA_VISIBLE_DEVICES=0,1,2,3
fi

nvidia-smi > ${LOG} 2>&1

echo "Begin..." >> ${LOG}
echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES" >> ${LOG}

sleep 5

python3 benchmark-throughput-power.py \
    --model=$model \
    --tensor-parallel-size=$tensor_parallel_size \
    --input-len=$input_len \
    --output-len=$output_len \
    --batch-size=$batch_size \
    --dtype=$dtype >> ${LOG} 2>&1

sleep 5
kill ${gpu_stats_pid}
