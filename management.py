#!/usr/bin/python3
## SCRIPT TO MANAGE DEVELPMENT
from sys import path
path.append("management/reusing")

from argparse import ArgumentParser
from github import download_from_github
from file_functions import replace_in_file, replace_line_in_file_that_contains
from os import remove, system


def get_version():
    with open("scenes/Globals.gd") as f:
        for line in f.readlines():
            if 'const VERSION="' in line:
                return line.split('"')[1]

parser=ArgumentParser()

group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--reusing', help='It gets all reused files downloading from Internet and updates them for this project', action="store_true", default=False)
group.add_argument('--procedure', help='Shows release procedure information', action="store_true", default=False)
group.add_argument('--export', help='Export all projects to dist folder', action="store_true", default=False)

args=parser.parse_args()

if args.reusing==True:
    download_from_github("turulomio", "reusingcode", "python/github.py", "management/reusing")
    download_from_github("turulomio", "reusingcode", "python/file_functions.py", "management/reusing")

if args.procedure is True:
    procedures=[
        "Change version and version date in Globals.gd",
        "Update changelog in README.md",
        "Improve translations",
        "Run management --export",
        f"git commit -am 'gdparchis-{get_version()}'",
        "git push",
        "Add version tag in github",
        "Upload windows and linux files to release",
        "Update gdparchis-bin.ebuild in myportage repository",
        f"git commit -am 'gdparchis-{get_version()}'",
        "git push", 
    ]
    
    for i, p in enumerate(procedures):
        print(f"{i+1}) {p}")
        
if args.export is True:
    replace_line_in_file_that_contains("export_presets.cfg", "application/file_version", f'application/file_version="{get_version()}"\n')
    replace_line_in_file_that_contains("export_presets.cfg", "application/product_version", f'application/product_version="{get_version()}"\n')
    replace_line_in_file_that_contains("export_presets.cfg", "application/file_description", f'application/file_description="https://github.com/turulomio/gdparchis/"\n')
    system(f"godot --no-window --export Linux/X11 dist/Linux/gdparchis-{get_version()}.Linux_x86_64")
    system(f"godot --no-window --export 'Windows Desktop' dist/Windows/gdparchis-{get_version()}.exe")

