import argparse
import functools
import os
import time

import jax
import numpy as np
import torch
from diffusers import FlaxDDIMScheduler, FlaxStableDiffusionPipeline
from flax.jax_utils import replicate
from flax.training.common_utils import shard
from jax.experimental.compilation_cache import compilation_cache as cc

cc.initialize_cache(os.path.expanduser("~/.cache/jax/compilation_cache"))


def parse_args():
    parser = argparse.ArgumentParser("simple inference")
    parser.add_argument("--output_dir", type=str, required=True)
    parser.add_argument("--model_dir", type=str, required=True)
    parser.add_argument(
        "--prompt",
        help="A text prompt for the inference model",
        type=str,
        action="append",
        required=True,
    )
    parser.add_argument(
        "--id",
        help="A unique identifier for this subject (person)",
        type=str,
        required=True,
    )
    parser.add_argument(
        "--num-images", help="How many images to generate", type=int, required=True
    )
    parser.add_argument(
        "--step", help="Step to begin transfer learning", type=int, required=True
    )
    return parser.parse_args()


def inference_mode(f):
    @functools.wraps(f)
    def wrapper(*args, **kwargs):
        with torch.inference_mode():
            return f(*args, **kwargs)

    return wrapper


@inference_mode
def main():
    args = parse_args()

    scheduler = FlaxDDIMScheduler(
        beta_start=0.00085,
        beta_end=0.012,
        beta_schedule="scaled_linear",
        set_alpha_to_one=True,
        steps_offset=1,
    )

    # modify the model path
    pipe, params = FlaxStableDiffusionPipeline.from_pretrained(
        os.path.expandvars(f"{args.model_dir}/{args.step}"),
        scheduler=scheduler,
        safety_checker=None,
        torch_dtype=torch.float16,
        from_flax=True,
    )
    params["scheduler"] = scheduler.create_state()

    names = set()
    device_count = jax.device_count()

    image_groups = []
    for i, prompt in enumerate(args.prompt):
        images = pipe(  # type: ignore
            prompt_ids=shard(pipe.prepare_inputs([prompt] * device_count)),
            params=replicate(params),
            jit=True,
            prng_seed=jax.random.split(jax.random.PRNGKey(0), 8),
        ).images
        pil = pipe.numpy_to_pil(
            np.asarray(images.reshape((device_count,) + images.shape[-3:]))
        )
        image_groups.append(pil)

    now = int(time.time() * 1000)
    for i, images in enumerate(image_groups):
        prompt = args.prompt[i]
        name = next(x for x in prompt.split(" ") if x not in names)
        names.add(name)
        for j, image in enumerate(images):

            image.save(f"{args.output_dir}/{args.id}/{now}_{args.id}_{name}_{j}.png")


if __name__ == "__main__":
    main()
