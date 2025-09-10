#!/bin/bash -e

SIF=/nesi/project/uoa04463/csco212/llm/containers/vllm-openai-v0.10.1.1.sif

model=$1
tensor_parallel_size=$2
input_len=$3
output_len=$4
batch_size=$5
dtype=$6

run_name=${model##*/}-tps-${tensor_parallel_size}-inlen-${input_len}-outlen-${output_len}-batchsize-${batch_size}-dtype-${dtype}

unset APPTAINER_BIND

# start collecting GPU stats in the background
nvidia-smi --query-gpu=timestamp,uuid,clocks_throttle_reasons.sw_thermal_slowdown,utilization.gpu,utilization.memory,memory.used,memory.total,temperature.gpu,power.draw,clocks.current.sm --format=csv,nounits -l 5 -f ${run_name}-gpu-stats.out &

sleep 5

apptainer exec --nv --no-home --writable-tmpfs --bind /nesi/nobackup/uoa04463/csco212/fakehome:/home/csco212 \
    ${SIF} \
    python3 benchmark-throughput.py \
        --model=$model \
        --tensor-parallel-size=$tensor_parallel_size \
        --input-len=$input_len \
        --output-len=$output_len \
        --batch-size=$batch_size \
        --dtype=$dtype > ${run_name}.out 2>&1

sleep 5
