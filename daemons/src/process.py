import os
import glob
import time

def dirsInDirectory(dir_name: str):
    dirs = filter(os.path.isdir, glob.glob("{}/*".format(dir_name)))
    dirs = sorted(dirs, key = os.path.getmtime) # Oldest first
    return dirs

def tokenize(fullPath: str):
    return fullPath.split("/")[-1]

if __name__ == "__main__":
    inputList = dirsInDirectory(os.path.expandvars("$DREAMBOOTH_DIR/s3/input"))
    outputList = dirsInDirectory(os.path.expandvars("$DREAMBOOTH_DIR/s3/output"))    
    outputTokens = [tokenize(t) for t in outputList]
    
    newDirs = [i for i in inputList if tokenize(i) not in outputTokens]
    
    print("Found {} new directories".format(len(newDirs)))
        
    if len(newDirs) > 0:
        token = tokenize(newDirs[0])
        
        print("Found a new set of inputs for token {}".format(token))
        os.system(os.path.expandvars("$DREAMBOOTH_DIR/train.sh {}").format(token))
        os.system(os.path.expandvars("$DREAMBOOTH_DIR/generate.sh {}").format(token))

    exit(0)
