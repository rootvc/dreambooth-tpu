import os
import glob
import time

def dirsInDirectory(dir_name: str):
    dirs = filter(os.path.isdir, glob.glob(f"{dir_name}/*"))
    dirs = sorted(dirs, key = os.path.getmtime) # Oldest first
    return dirs

def tokenize(fullPath: str):
    return fullPath.split("/")[-1]

def tokenToTimestamp(token: str):
    charList = [(ord(t) - 97) for t in list(token)]
    return "".join(map(str, charList))

if __name__ == "__main__":
    inputList = dirsInDirectory(os.path.expandvars("$DREAMBOOTH_DIR/s3/input"))
    outputList = dirsInDirectory(os.path.expandvars("$DREAMBOOTH_DIR/s3/output"))    
    outputTokens = [tokenize(t) for t in outputList]
    
    newDirs = [i for i in inputList if tokenize(i) not in outputTokens]
    
    if len(newDirs) > 0:
        print("Found {} new directories".format(len(newDirs)))

        token = tokenize(newDirs[0])
        timestamp = tokenToTimestamp(token)
        
        print(f"Found a new set of inputs for token {token}")
        os.system(os.path.expandvars(f"$DREAMBOOTH_DIR/train.sh {token}"))
        os.system(os.path.expandvars(f"$DREAMBOOTH_DIR/generate.sh {token}"))
        print(f"Finished generating images for {token}")
        
        print("Notifying user via SMS")
        os.system(os.path.expandvars(f"conda run python $DREAMBOOTH_DIR/daemons/src/sms.py --file $DREAMBOOTH_DIR/s3/data/prompts.tsv --timestamp {timestamp}"))

    exit(0)
