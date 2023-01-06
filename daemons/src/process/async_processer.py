import os
from functools import cached_property
from pathlib import Path
from typing import Set

from redis import RedisCluster
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

    def all_tokens(self) -> Set[str]:
        return {
            filename_to_token(str(p))
            for p in Path(f"{self.DREAMBOOTH_DIR}/s3/photobooth-input/").glob("*.jpg")
        }

    @cached_property
    def unprocessed_tokens(self):
        print("Checking for unprocessed tokens...")
        return [t for t in self.all_tokens() if not self.r.sismember(self.PROCESSED, t)]

    def generate_images(self, token: str):
        trainer = Trainer(token)
        trainer.train()
        trainer.generate()

    def mark_processed(self, token: str):
        print(f"Processing {token}...")
        self.r.sadd(self.PROCESSED, token)

    def unmark_processed(self, token: str, ex: Exception):
        print(f"Error processing {token}: {ex}")
        self.r.srem(self.PROCESSED, token)

    def run(self):
        for token in self.unprocessed_tokens:
            self.mark_processed(token)
            try:
                self.generate_images(token)
            except Exception as e:
                self.unmark_processed(token, e)
