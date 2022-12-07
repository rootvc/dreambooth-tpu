import os

from dotenv import dotenv_values
from twilio.rest import Client


class SMS(object):
    @staticmethod
    def format_phone(n):
        return f"+{n.replace('-', '')}"

    def __init__(self, phone):
        self.client = Client(
            os.environ["TWILIO_ACCOUNT_SID"], os.environ["TWILIO_AUTH_TOKEN"]
        )
        self.messaging_service_sid = os.environ["TWILIO_MESSAGING_SERVICE_SID"]
        self.phone = self.format_phone(phone)

    def send(self, body):
        self.client.messages.create(
            messaging_service_sid=self.messaging_service_sid, body=body, to=self.phone
        )

    def send_initial(self, token):
        self.send(
            "Root Ventures Photobooth is working on your AI images!"
            f" When they are ready, you can check them out here: https://photobooth.root.vc/{token}."
            " You will receive a second message when they are ready."
            " It may take 6 minutes to a few hours."
            " Be patient. We are only running one box right now."
        )

    def send_final(self, token):
        self.send(
            "Root Ventures Photobooth generated your AI images!"
            f" Check them out here: https://photobooth.root.vc/{token}."
            " Happy Holidays, and thanks for coming!"
        )
