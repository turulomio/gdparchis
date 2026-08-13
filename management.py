#!/usr/bin/python3
"""Management script for gdparchis project development, export, and deployment."""

from os import getcwd, remove, system
from sys import path
from argparse import ArgumentParser

path.append("management/reusing")

from github import download_from_github
from file_functions import replace_in_file, replace_line_in_file_that_contains


def get_version():
    """Extracts the VERSION string constant from scenes/Globals.gd.
    
    Returns:
        str: Version string (e.g. "0.9.99").
    """
    with open("scenes/Globals.gd") as f:
        for line in f.readlines():
            if 'const VERSION="' in line:
                return line.split('"')[1]


# Initialize argument parser
parser = ArgumentParser(description="Management CLI for gdparchis")

group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--reusing', help='It gets all reused files downloading from Internet and updates them for this project', action="store_true", default=False)
group.add_argument('--procedure', help='Shows release procedure information', action="store_true", default=False)
group.add_argument('--export', help='Export all projects to dist folder', action="store_true", default=False)
group.add_argument('--play', help='Runs the project using godot', action="store_true", default=False)
group.add_argument('--apache', help='Sets project in apache', action="store_true", default=False)

parser.add_argument('--server', help='HTML Export server', action="store", default="127.0.0.1")
parser.add_argument('--port', help='HTML Export server port ', action="store", default=22)

args = parser.parse_args()

# Execute requested task based on CLI arguments
if args.reusing is True:
    # Download reusable python utility files from GitHub repository
    download_from_github("turulomio", "reusingcode", "python/github.py", "management/reusing")
    download_from_github("turulomio", "reusingcode", "python/file_functions.py", "management/reusing")

if args.procedure is True:
    # Display step-by-step release checklist procedures
    procedures = [
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

if args.play is True:
    # Run development build in Godot
    system("godot --audio-driver PulseAudio")

if args.export is True:
    # Update export_presets.cfg version strings and run Godot headless export
    replace_line_in_file_that_contains("export_presets.cfg", "application/file_version", f'application/file_version="{get_version()}"\n')
    replace_line_in_file_that_contains("export_presets.cfg", "application/product_version", f'application/product_version="{get_version()}"\n')
    replace_line_in_file_that_contains("export_presets.cfg", "application/file_description", f'application/file_description="https://github.com/turulomio/gdparchis/"\n')
    system("mkdir -p dist/Linux dist/Windows")
    system(f"godot --headless --export-release 'Linux' dist/Linux/gdparchis-{get_version()}.x86_64")
    system(f"godot --headless --export-release 'Windows Desktop' dist/Windows/gdparchis-{get_version()}.exe")

if args.apache is True:
    # Export HTML5 bundle and deploy to remote Apache webserver via rsync/ssh
    system("mkdir -p dist/Html && rm -rf dist/Html/*")
    system("godot --headless --export-release 'HTML5' dist/Html/index.html")
    system(f"rsync -e 'ssh -l root -p {args.port}' -avzP dist/Html/* root@{args.server}:/var/www/html/gdparchis/ --delete-after")
    print(getcwd())
    system(f"ssh  root@{args.server} -p {args.port} 'chown -Rvc 33:33 /var/www/html/gdparchis && systemctl restart apache2'")