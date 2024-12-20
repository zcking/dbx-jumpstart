from setuptools import setup
from pipfile import Pipfile

def get_dependencies():
    # Load the Pipfile and extract the dependencies
    pipfile = Pipfile.load("Pipfile")
    dependencies = pipfile.data.get("default", {})

    # Return a list of dependency strings in the format expected by setuptools
    return [f"{package}{version if version != '*' else ''}" for package, version in dependencies.items()]

setup(
    name="jumpstart",
    version="1.0.0",
    packages=["jumpstart"],
    install_requires=get_dependencies(),
    entry_points={
        "console_scripts": [
            "jumpstart = jumpstart.app:main"
        ]
    },
)
