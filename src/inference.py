from diffusers import StableDiffusionPipeline, DDIMScheduler
import torch
import time
import argparse
import os

parser = argparse.ArgumentParser("simple inference")
parser.add_argument("--prompt", help="A text prompt for the inference model", type=str)
parser.add_argument("--name", help="A name for this prompt to use in the filename", type=str)
parser.add_argument("--id", help="A unique identifier for this subject (person)", type=str)
parser.add_argument("--num", help="How many images to generate", type=int)
parser.add_argument("--step", help="Step to begin transfer learning", type=int)
args = parser.parse_args()

device = "cuda"

if __name__ == "__main__":
    # use DDIM scheduler, you can modify it to use other scheduler
    scheduler = DDIMScheduler(
        beta_start=0.00085,
        beta_end=0.012,
        beta_schedule="scaled_linear",
        clip_sample=False,
        set_alpha_to_one=True,
        steps_offset=1
    )

    # Use proxies to help with fetching from HF
    proxies = {
        "http": "http://10.10.1.10:3128",
        "https": "https://10.10.1.10:1080",
    }
    
    # modify the model path
    pipe = StableDiffusionPipeline.from_pretrained(
        os.path.expandvars(f"$DREAMBOOTH_DIR/models/{args.step}"),
        scheduler=scheduler,
        safety_checker=None,
        torch_dtype=torch.float16,
        proxies=proxies,
    ).to(device)
    
    # enable xformers memory attention
    pipe.enable_xformers_memory_efficient_attention()
    
    prompt = args.prompt
    negative_prompt = ""
    num_samples = args.num
    guidance_scale = 7.5
    num_inference_steps = 50
    height = 512
    width = 512
    
    with torch.autocast("cuda"), torch.inference_mode():
        images = pipe(
            prompt,
            height=height,
            width=width,
            negative_prompt=negative_prompt,
            num_images_per_prompt=num_samples,
            num_inference_steps=num_inference_steps,
            guidance_scale=guidance_scale
        ).images
        
        now = int(time.time() * 1000)
        count = 1
        for image in images:
            # save image to local directory
            save_file = os.path.expandvars(f"$DREAMBOOTH_DIR/s3/output/{args.id}/{now}_{args.id}_{args.name}_{count}.png")
            image.save(save_file)
            count += 1
