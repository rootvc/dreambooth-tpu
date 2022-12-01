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
    # inputList = dirsInDirectory("/home/ec2-user/rootvc/dreambooth/s3/input")
    # outputList = dirsInDirectory("/home/ec2-user/rootvc/dreambooth/s3/output")
    
    inputList = dirsInDirectory("/Users/lee/Repos/rootvc/dreambooth/s3/input")
    outputList = dirsInDirectory("/Users/lee/Repos/rootvc/dreambooth/s3/output")
    outputTokens = [tokenize(t) for t in outputList]
    
    newDirs = [input for input in inputList if tokenize(input) not in outputTokens]
    
    print("Found {} new directories".format(len(newDirs)))
        
    if len(newDirs) > 0:
        dir = newDirs[0]
        token = tokenize(dir)
        
        print("Found a new set of inputs for token {}".format(token))
        # os.system("/home/ec2-user/rootvc/dreambooth/train.sh %" % token)
        # os.system("/home/ec2-user/rootvc/dreambooth/generate.sh %" % token)
        
        os.system("/Users/lee/Repos/rootvc/dreambooth/train.sh {}".format(token))
        os.system("/Users/lee/Repos/rootvc/dreambooth/generate.sh {}".format(token))
