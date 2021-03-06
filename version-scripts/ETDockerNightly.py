#!/usr/bin/python3
import subprocess
import shlex
import time
import sys
from ETImages import *
from DockerUtils import *


def getNightlyTag():
    return time.strftime('%Y%m%d')


def createETNightlyImage(image, tag):
    # Pull
    pullImage(image)

    # Tag
    new_image = tagImage(image, tag)

    # Push
    pushImage(new_image)

    print('Image ' + new_image + ' pushed')
    return tag

# Main functions


def createETNightlyImages(default_tag):
    images_list = getElastestImages(True)
    tag = default_tag
    if (default_tag == 'bytime') :
        tag = getNightlyTag()
    for image in images_list:
        createETNightlyImage(image, tag)
    print('All images has been pushed')
    return tag


def updateFilesToNightly(default_tag):
    tag = createETNightlyImages(default_tag)
    updateFilesImagesWithTag(tag)
    return tag
