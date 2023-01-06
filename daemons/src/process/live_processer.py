import csv

from async_processer import AsyncProcesser
from sms import SMS
from utils import filename_to_token


class LiveProcesser(AsyncProcesser):
    def __init__(self):
        super().__init__()
        self.phones = self.init_phone_db()

    def init_phone_db(self):
        return {
            filename_to_token(p["filename"]): p["phone"]
            for p in csv.DictReader(
                open(f"{self.DREAMBOOTH_DIR}/s3/data/prompts.tsv", "r"),
                delimiter="\t",
            )
        }

    def generate_images(self, token: str):
        if phone := self.phones.get(token):
            SMS(phone).send_initial(token)
        super().generate_images(token)
        if phone:
            SMS(phone).send_final(token)
