from setuptools import setup
from Cython.Build import cythonize

setup(
    name="Galaxies_low_frequencies",
    ext_modules=cythonize(
        "main.pyx",
        compiler_directives={"language_level": "3"}
    ),
    zip_safe=False,
)