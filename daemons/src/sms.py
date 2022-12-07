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
parser.add_argument("--message", help="Pick initial or final message", type=str, required=True)

def format_phone(n):                                                                                                                                  
    return f"+{n.replace('-','')}"

def token_from_url(f):
    return timestampToToken(f.split("/")[-1].split(".")[0])
    
def timestampToToken(timestamp: str):
    charList = [chr(97+int(t)) for t in list(timestamp)]
    return "".join(map(str, charList))

def finalMessage(token, phone):
    message = client.messages.create(
        messaging_service_sid=messaging_service_sid,
        body=f"Root Ventures Photobooth generated your AI images! Check them out here: https://photobooth.root.vc/{token}. Happy Holidays, and thanks for coming!",
        to=phone
    )
    print(f"Sent. Final message SID: {message.sid}")

def initialMessage(token, phone):
    message = client.messages.create(
        messaging_service_sid=messaging_service_sid,
        body=f"Root Ventures Photobooth is working on your AI images! When they are ready, you can check them out here: https://photobooth.root.vc/{token}. You will receive a second message when they are ready. It may take 6 minutes to a few hours. Be patient. We are only running one box right now.",
        to=phone
    )
    print(f"Sent. Initial message SID: {message.sid}")

def main(args):
    data = []
    with open(args.file) as file:
        for row in csv.reader(file, delimiter="\t"):
            if f"/{args.timestamp}.jpg" in row[0]:
                data = row
    
    if data:
        token = token_from_url(data[0])
        phone = format_phone(data[5])
        
        if args.message == "initial":
            initialMessage(token, phone)
        elif args.message == "final":
            finalMessage(token, phone)
        else:
            print("Invalid value for message: pick 'initial' or 'final'")
    
    else:
        print(f"Timestamp {args.timestamp} not found")
    
if __name__ == "__main__":
    args = parser.parse_args()
    print(f"Reading {args.timestamp} from: {args.file}")
    main(args)

    exit(0)
    