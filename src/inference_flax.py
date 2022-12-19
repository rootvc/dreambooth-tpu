import argparse
import glob
import os
import time
from collections import Counter
from operator import itemgetter

import jax
import numpy as np
from deepface import DeepFace
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
    parser.add_argument("--input_dir", type=str, required=True)
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


def analyze_input(path):
    return {
        k: v
        for k, v in DeepFace.analyze(
            path,
            actions=["age", "gender", "race", "emotion"],
            detector_backend="retinaface",
        ).items()
        if k in {"dominant_emotion", "age", "dominant_race", "gender"}
    }


def summarize_input(results):
    keys = results[0].keys()
    return {k: Counter(map(itemgetter(k), results)).most_common(1)[0] for k in keys}


def analyze_inputs(args):
    paths = glob.glob(f"{args.input_dir}/{args.id}/*.jpg")
    return summarize_input(list(map(analyze_input, paths)))


def gen_prompts(args, n):
    attrs = analyze_inputs(args)
    for i in range(0, len(args.prompt), n):
        yield [
            (
                f"a photo of sks person, in the style of {prompt}"
                f", #{attrs['dominant_emotion']} #{attrs['dominant_race']} #{attrs['gender']}"
                f", #{attrs['age']} years old"
                ", front-facing centered portrait"
                ", highly-detailed face"
            )
            for prompt in args.prompt[i : i + n]
        ]


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
        prediction_type="v_prediction",
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
    prng_seed = jax.random.split(jax.random.PRNGKey(0), device_count)

    image_groups = []
    for prompts in gen_prompts(args, 1):
        print("Generating: ", prompts)
        prompt_ids = shard(pipe.prepare_inputs(prompts * device_count))
        images = pipe(
            prompt_ids=prompt_ids,
            params=params,
            jit=True,
            prng_seed=prng_seed,
            num_inference_steps=100,
        ).images
        pils = pipe.numpy_to_pil(
            np.asarray(images.reshape((device_count,) + images.shape[-3:]))
        )
        image_groups.append(pils)

    now = int(time.time() * 1000)
    for i, images in enumerate(image_groups):
        name = args.prompt[i]
        for j, image in enumerate(images):
            image.save(f"{args.output_dir}/{args.id}/{now}_{args.id}_{name}_{j}.png")


if __name__ == "__main__":
    main()
