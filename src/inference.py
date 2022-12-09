import argparse
import os
import time

import torch
from accelerate import Accelerator
from diffusers import FlaxStableDiffusionPipeline
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


def main():
    accelerator = Accelerator()
    device = accelerator.device
    args = parse_args()

    # modify the model path
    pipe, params = FlaxStableDiffusionPipeline.from_pretrained(
        os.path.expandvars(f"{args.model_dir}/{args.step}"),
        safety_checker=None,
        torch_dtype=torch.float16,
        from_flax=True,
    )

    pipe, params = accelerator.prepare(pipe, params)  # type: ignore

    names = set()

    with torch.inference_mode():
        image_groups = []
        for i in range(args.num_images):
            image_groups[i] = pipe(  # type: ignore
                prompt_ids=pipe.prepare_inputs(args.prompt),
                params=params,
                neg_prompt_ids=pipe.prepare_inputs("a realistic photo"),
                jit=True,
            ).images

        now = int(time.time() * 1000)
        for i, images in enumerate(image_groups):
            prompt = args.prompt[i]
            name = next(x for x in prompt.split(" ") if x not in names)
            names.add(name)
            for j, image in enumerate(images):
                image.save(
                    f"{args.output_dir}/{args.id}/{now}_{args.id}_{name}_{j}.png"
                )


if __name__ == "__main__":
    main()
