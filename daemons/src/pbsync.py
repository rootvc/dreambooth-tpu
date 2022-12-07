import os
import glob
import time

def dirsInDirectory(dirName: str):
    dirs = filter(os.path.isdir, glob.glob(f"{dirName}/*"))
    dirs = sorted(dirs, key = os.path.getmtime) # Oldest first
    return dirs

def filesInDirectory(dirName: str):
    files = [f for f in glob.glob(f"{dirName}/*.jpg")]
    files = sorted(files, key = os.path.getmtime) # Oldest first
    return files

def timestampsInDirectory(dirName: str):
    files = filesInDirectory(dirName)
    return list(set([f.split("/")[-1].split("-")[0] for f in files]))

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
    sourceFiles = filesInDirectory(os.path.expandvars("$DREAMBOOTH_DIR/s3/photobooth-input"))
    sourceTimestamps = timestampsInDirectory(os.path.expandvars("$DREAMBOOTH_DIR/s3/photobooth-input"))
    destinationDirs = dirsInDirectory(os.path.expandvars("$DREAMBOOTH_DIR/s3/input"))
    
    sourceTimestamps = [timestampFromPath(t) for t in sourceTimestamps]
    sourceTokens = [timestampToToken(t) for t in sourceTimestamps]
    destinationTokens = [tokenFromPath(t) for t in destinationDirs]
    
    newTokens = list(set(sourceTokens) - set(destinationTokens))
    
    print("Found {} new directories".format(len(newTokens)))
        
    for token in newTokens:
        timestamp = tokenToTimestamp(token)
        print(f"Found a new set of photobooth outputs for timestamp: {timestamp} (token: {token})")
        # print(timestamp)
        # print(token)
        os.system(os.path.expandvars(f"mkdir -p $DREAMBOOTH_DIR/s3/input/{token}"))
        os.system(os.path.expandvars(f"cp -R $DREAMBOOTH_DIR/s3/photobooth-input/{timestamp}*.jpg $DREAMBOOTH_DIR/s3/input/{token}/"))
        print(f"Finished copying photobooth output images into Dreambooth input images for {token}")

    exit(0)
