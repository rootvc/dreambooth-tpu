import subprocess

from utils import DreamboothDirMixin, token_to_timestamp


class Trainer(DreamboothDirMixin):
    def __init__(self, token: str) -> None:
        self.token = token
        self.timestamp = token_to_timestamp(token)

    def run(self):
        self.train()
        self.generate()
        self.upload()
        self._warm_cache()

    def train(self) -> None:
        subprocess.check_call(
            [f"{self.DREAMBOOTH_DIR}/train_flax.sh", self.token, self.timestamp]
        )

    def _warm_cache(self) -> None:
        subprocess.check_call(["curl", f"https://photobooth.root.vc/{self.token}"])

    def generate(self) -> None:
        subprocess.check_call([f"{self.DREAMBOOTH_DIR}/generate_flax.sh", self.token])

    def upload(self):
        subprocess.check_call(
            [
                "aws",
                "s3",
                "sync",
                f"{self.DREAMBOOTH_DIR}/s3/output/{self.token}",
                f"s3://rootvc-dreambooth/output/{self.token}",
            ]
        )
