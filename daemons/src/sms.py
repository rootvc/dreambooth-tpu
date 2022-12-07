import argparse
import os
import csv

from twilio.rest import Client
from dotenv import load_dotenv, dotenv_values

load_dotenv()
account_sid = dotenv_values(os.path.expandvars(f"$DREAMBOOTH_DIR/.env"))["TWILIO_ACCOUNT_SID"]
auth_token = dotenv_values(os.path.expandvars(f"$DREAMBOOTH_DIR/.env"))["TWILIO_AUTH_TOKEN"]
messaging_service_sid = dotenv_values(os.path.expandvars(f"$DREAMBOOTH_DIR/.env"))["TWILIO_MESSAGING_SERVICE_SID"]

client = Client(account_sid, auth_token)

parser = argparse.ArgumentParser("Send an SMS text message with Twilio")
parser.add_argument("--timestamp", help="Timestamp for this user", type=str, required=True)
parser.add_argument("--file", help="File that contains the photobooth tsv", type=str, required=True)

def format_phone(n):                                                                                                                                  
    return f"+{n.replace('-','')}"

def token_from_url(f):
    return timestampToToken(f.split("/")[-1].split(".")[0])
    
def timestampToToken(timestamp: str):
    charList = [chr(97+int(t)) for t in list(timestamp)]
    return "".join(map(str, charList))

def main(args):
    data = []
    with open(args.file) as file:
        for row in csv.reader(file, delimiter="\t"):
            if f"/{args.timestamp}.jpg" in row[0]:
                data = row
    
    if data:
        token = token_from_url(data[0])
        phone = format_phone(data[5])
        
        message = client.messages.create(
            messaging_service_sid=messaging_service_sid,
            body=f"Root Ventures Photobooth generated your AI images! Check them out here: https://photobooth.root.vc/{token}. Happy Holidays, and thanks for coming!",
            to=phone
        )
    
        print(f"Sent. Message SID: {message.sid}")
    else:
        print(f"Timestamp {args.timestamp} not found")
    
if __name__ == "__main__":
    args = parser.parse_args()
    print(f"Reading {args.timestamp} from: {args.file}")
    main(args)

    exit(0)
    