import os
import glob
import time

def dirsInDirectory(dir_name: str):
    dirs = filter(os.path.isdir, glob.glob(f"{dir_name}/*"))
    dirs = sorted(dirs, key = os.path.getmtime) # Oldest first
    return dirs

def timestampFromPath(fullPath: str):
    return fullPath.split("/")[-1]
    
def tokenFromPath(fullPath: str):
    return fullPath.split("/")[-1]

def timestampToToken(timestamp: str):
    charList = [chr(97+int(t)) for t in list(timestamp)]
    return "".join(map(str, charList))
    
def tokenToTimestamp(token: str):
    charList = [(ord(t) - 97) for t in list(token)]
    return "".join(map(str, charList))

if __name__ == "__main__":
    sourceList = dirsInDirectory(os.path.expandvars("$DREAMBOOTH_DIR/s3/pb-output"))
    destinationList = dirsInDirectory(os.path.expandvars("$DREAMBOOTH_DIR/s3/input"))
    
    sourceTimestamps = [timestampFromPath(t) for t in sourceList]
    sourceTokens = [timestampToToken(t) for t in sourceTimestamps]
    destinationTokens = [tokenFromPath(t) for t in destinationList]
    
    newTokens = list(set(sourceTokens) - set(destinationTokens))
    
    print("Found {} new directories".format(len(newTokens)))
        
    for token in newTokens:
        timestamp = tokenToTimestamp(token)
        print(f"Found a new set of photobooth outputs for timestamp {timestamp} = token {token}")
        os.system(os.path.expandvars(f"cp -R $DREAMBOOTH_DIR/s3/pb-output/{timestamp}/. $DREAMBOOTH_DIR/s3/input/{token}"))
        print(f"Finished copying photobooth output images into Dreambooth input images for {token}")

    exit(0)
