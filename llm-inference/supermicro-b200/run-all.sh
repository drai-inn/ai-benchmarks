#!/bin/bash -e

for model in "openai/gpt-oss-20b" "Qwen/Qwen3-Coder-30B-A3B-Instruct" ; do
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

for model in "openai/gpt-oss-120b" ; do
    for tensor_parallel in 1 2; do
        for dtype in "auto"; do
            for batch_size in 1 16 32 64; do
                for input_output_len in 128 256 512 1024 2048; do
                    ./benchmark-throughput-power.sh "${model}" "${tensor_parallel}" "${input_output_len}" "${input_output_len}" "${batch_size}" "${dtype}"
                done
            done
        done
    done
done

