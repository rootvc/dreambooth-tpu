import csv
import os
import subprocess
from functools import cached_property
from pathlib import Path
from typing import Set

from redis import RedisCluster
from sms import SMS
from train import Trainer
from utils import DreamboothDirMixin, filename_to_token


class AsyncProcesser(DreamboothDirMixin):
    PROCESSED = "dreambooth:processed"

    def __init__(self):
        self.r = RedisCluster(
            host=os.environ["REDIS_HOST"],
            port=6379,
            ssl=True,
            decode_responses=True,
        )

    def all_ts(self) -> Set[str]:
        return {
            p.stem
            for p in Path(f"{self.DREAMBOOTH_DIR}/s3/photobooth-input/").glob("*.jpg")
        }

    @cached_property
    def unprocessed_tokens(self):
        print("Checking for unprocessed tokens...")
        self.r.sismember(self.PROCESSED, filename_to_token(p["filename"]))

    def generate_images(self, token: str, phone: str):
        trainer = Trainer(token)
        trainer.train()
        trainer.generate()
        SMS(phone).send_final(token)

    def notify_user(self, token: str, phone: str):
        self.r.sadd(self.PROCESSED, token)
        SMS(phone).send_initial(token)

    def run(self):
        for p in self.unprocessed_tokens:
            token = filename_to_token(p["filename"])
            self.notify_user(token, p["phone"])

        for p in self.unprocessed_tokens:
            token = filename_to_token(p["filename"])
            print(f"Processing {token} ({p['phone']})...")
            try:
                self.generate_images(token, p["phone"])
            except Exception as e:
                self.r.srem(self.PROCESSED, token)
                print(f"Error processing {p['filename']}: {e}")
