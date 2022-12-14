import argparse
import functools
import os
import time

import jax
import numpy as np
from diffusers import FlaxDDIMScheduler, FlaxDDPMScheduler, FlaxStableDiffusionPipeline
from flax.jax_utils import replicate
from flax.training.common_utils import shard
from jax.experimental.compilation_cache import compilation_cache as cc
from jax.lax import stop_gradient

cc.initialize_cache(os.path.expanduser("~/.cache/jax/compilation_cache"))
device_count = jax.local_device_count()


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


def gen_prompts(lst, n):
    for i in range(0, len(lst), n):
        yield [
            f"perfectly-centered-portrait of {prompt}"
            ", intricate, highly detailed face, sharp focus, glamor pose, smooth"
            for prompt in lst[i : i + n]
        ]


@functools.partial(jax.jit, static_argnums=(3,))
def eval(pipe, params, seed, prompts):
    image_groups = []
    for prompts in gen_prompts(prompts, 2):
        images = pipe(  # type: ignore
            prompt_ids=shard(
                pipe.prepare_inputs(
                    ([prompts[0]] * (device_count // 2))
                    + ([prompts[1]] * (device_count // 2))
                )
            ),
            params=params,
            jit=True,
            prng_seed=seed,
            num_inference_steps=75,
        ).images
        pil_data = np.asarray(
            images.reshape((2, device_count // 2) + images.shape[-3:])
        )
        pils = [pipe.numpy_to_pil(i) for i in pil_data]
        image_groups.extend(pils)


def main():
    args = parse_args()
    model_path = os.path.expandvars(f"{args.model_dir}/{args.step}")

    og_scheduler, _ = FlaxDDPMScheduler.from_pretrained(
        model_path, subfolder="scheduler"
    )
    scheduler = FlaxDDIMScheduler(
        beta_start=0.00085,
        beta_end=0.012,
        beta_schedule="scaled_linear",
        set_alpha_to_one=True,
        steps_offset=1,
        prediction_type=og_scheduler.config.prediction_type,
    )

    # modify the model path
    pipe, params = FlaxStableDiffusionPipeline.from_pretrained(
        model_path,
        scheduler=scheduler,
        safety_checker=None,
        from_flax=True,
        dtype=jax.numpy.bfloat16,
    )
    params["scheduler"] = scheduler.create_state()

    params = replicate(stop_gradient(params))
    prng_seed = jax.random.split(jax.random.PRNGKey(0), 8)
    results = eval(pipe, params, prng_seed, args.prompt)

    names = {"a", "the", "an"}
    now = int(time.time() * 1000)
    for i, images in enumerate(results):
        prompt = args.prompt[i]
        name = next(x for x in prompt.split(" ") if x not in names)
        names.add(name)
        for j, image in enumerate(images):
            image.save(f"{args.output_dir}/{args.id}/{now}_{args.id}_{name}_{j}.png")


if __name__ == "__main__":
    main()
