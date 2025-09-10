#!/bin/bash -e
#SBATCH --job-name=vllmbench
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --gpus-per-node=A100:1
#SBATCH --partition=milan

for model in "openai/gpt-oss-20b"; do
    for tensor_parallel in 1; do
        for dtype in "auto"; do
            for batch_size in 1 16 32 64; do
                for input_output_len in 128 256 512 1024 2048; do
                    ./benchmark-throughput-power.sh "${model}" "${tensor_parallel}" "${input_output_len}" "${input_output_len}" "${batch_size}" "${dtype}"
                done
            done
        done
    done
done


