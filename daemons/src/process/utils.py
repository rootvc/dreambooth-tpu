import os


def filename_to_timestamp(filename: str):
    return filename.split("/")[-1].split(".")[0]


def filename_to_token(filename: str):
    return timestamp_to_token(filename_to_timestamp(filename))


def timestamp_to_token(timestamp: str):
    charList = [chr(97 + int(t)) for t in list(timestamp)]
    return "".join(map(str, charList))


def token_to_timestamp(token: str):
    charList = [(ord(t) - 97) for t in list(token)]
    return "".join(map(str, charList))


class DreamboothDirMixin:
    DREAMBOOTH_DIR = os.environ["DREAMBOOTH_DIR"]
