WANDB_API_KEY=$(cat $HOME/.oxwhirl_wandb_api_key)

NV_GPU=$1 nvidia-docker run --rm -e WANDB_API_KEY=$WANDB_API_KEY -v ~/logdir:/logdir dreamerv3:benlis sh /scripts/xvfb_run.sh python3 dreamerv3/train.py --logdir "/logdir/$(date +%Y%m%d-%H%M%S)" --configs $2 $3 --task $4 ${@:5}
