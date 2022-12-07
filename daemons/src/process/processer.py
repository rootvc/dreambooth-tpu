import csv
import os
import subprocess

import redis
from sms import SMS
from train import Trainer
from utils import DreamboothDirMixin, filename_to_token


class Processer(DreamboothDirMixin):
    PROCESSED = "dreambooth:processed"

    def __init__(self):
        self.r = redis.Redis(
            host=os.environ["REDIS_HOST"], port=6379, db=0, decode_responses=True
        )
        self.prompts = csv.DictReader(
            open(f"{self.DREAMBOOTH_DIR}/s3/data/prompts.tsv", "r"),
            delimiter="\t",
        )

    def unprocessed_tokens(self):
        return [
            p
            for p in self.prompts
            if not self.r.sismember(self.PROCESSED, p["filename"])
        ]

    def generate_images(self, token: str, phone: str):
        trainer = Trainer(token, SMS(phone))
        trainer.train()
        trainer.generate()

    def run(self):
        for p in self.unprocessed_tokens():
            token = filename_to_token(p["filename"])
            print(f"Processing {token}")
            try:
                self.r.sadd(self.PROCESSED, token)
                self.generate_images(token, p["phone"])
            except subprocess.CalledProcessError as e:
                self.r.srem(self.PROCESSED, token)
                print(f"Error processing {p['filename']}: {e}")
