import subprocess

from sms import SMS
from utils import DreamboothDirMixin, token_to_timestamp


class Trainer(DreamboothDirMixin):
    def __init__(self, token: str, sms: SMS) -> None:
        self.token = token
        self.timestamp = token_to_timestamp(token)
        self.sms = sms

    def train(self) -> None:
        self.sms.send_initial(self.token)
        subprocess.check_call(
            [f"{self.DREAMBOOTH_DIR}/train.sh", self.token, self.timestamp]
        )

    def _warm_cache(self) -> None:
        subprocess.check_call(["curl", f"https://photobooth.root.vc/{self.token}"])

    def generate(self) -> None:
        subprocess.check_call([f"{self.DREAMBOOTH_DIR}/generate.sh", self.token])
        self.sms.send_final(self.token)
