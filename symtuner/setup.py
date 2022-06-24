from setuptools import find_packages
from setuptools import setup

from symtuner import __version__

setup(
    name='symtuner',
    version=__version__,
    description='SymTuner: Maximizing the Power of Symbolic Execution by Adaptively Tuning External Parameters',
    python_version='>=3.6',
    packages=find_packages(include=('symtuner', 'symtuner.*')),
    include_package_data=True,
    setup_requires=[],
    install_requires=[
        'numpy',
    ],
    dependency_links=[],
    entry_points={
        'console_scripts': [
            'symtuner=symtuner.bin:main',
        ]
    }
)
