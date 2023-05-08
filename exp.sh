#!/bin/bash
debug=
# debug=echo
trap 'onCtrlC' INT

function onCtrlC () {
  echo 'Ctrl+C is captured'
  for pid in $(jobs -p); do
    kill -9 $pid
  done
  
  kill -HUP $( ps -A -ostat,ppid | grep -e '^[Zz]' | awk '{print $2}')
  exit 1
}

envs=${1:-dmc_proprio}
tasks=${2:-dmc_walker_walk}
model_sizes=${2:-small,medium,large,xlarge}
args=${3:-}
gpus=${3:-1,2,3,4,5,6,7}
threads=${4:-7}
times=${5:-5}

tasks=(${tasks//,/ })
model_sizes=(${model_sizes//,/ })
gpus=(${gpus//,/ })
envs=(${envs//,/ })

echo "ENVS:" ${env_ids[@]}
echo "THREADS:" $threads
echo "GPU LIST:" ${gpus[@]}
echo "TIMES:" $times
echo "LRs:" ${lrs[@]}



# run parallel
count=0
for model_size in "${model_sizes[@]}"; do
    for env in "${envs[@]}"; do
        for task in "${tasks[@]}"; do
            for((i=0;i<times;i++)); do
                gpu=${gpus[$(($count % ${#gpus[@]}))]}  
                group="${config}-${tag}"
                $debug ./run.sh $gpu $env $model_size $task --seed $i &
                count=$(($count + 1))     
                if [ $(($count % $threads)) -eq 0 ]; then
                    wait
                fi
                # for random seeds
                sleep $((RANDOM % 3 + 3))
            done
        done
    done
done
wait
