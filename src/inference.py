from diffusers import StableDiffusionPipeline, DDIMScheduler
import torch
import time
import argparse

parser = argparse.ArgumentParser("simple inference")
parser.add_argument("prompt", help="A text prompt for the inference model", type=str)
parser.add_argument("num", "How many images to generate", type=int)
ars = parser.parse_args()

device = "cuda"
# use DDIM scheduler, you can modify it to use other scheduler
scheduler = DDIMScheduler(beta_start=0.00085, beta_end=0.012, beta_schedule="scaled_linear", clip_sample=False, set_alpha_to_one=True)

# modify the model path
pipe = StableDiffusionPipeline.from_pretrained(
    "./output-models/1500/",
    scheduler=scheduler,
    safety_checker=None,
    torch_dtype=torch.float16,
).to(device)

# enable xformers memory attention
# pipe.enable_xformers_memory_efficient_attention()

prompt = "photo of zwx bear toy"
negative_prompt = ""
num_samples = 4
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
    count = 0
    for image in images:
        # save image to local directory
        image.save(f"./output-images/{now}-{count}.png")
        count += 1
