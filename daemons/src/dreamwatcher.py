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
        
        # Prime the SSR path by hitting the url once
        os.system(f"curl https://photobooth.root.vc/{token} > /dev/null")
        
        print("Notifying user via SMS")
        os.system(f"export DREAMBOOTH_LAST_CUSTOMER_TIMESTAMP={timestamp}")

    exit(0)
