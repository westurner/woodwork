.PHONY: clean clean-test clean-pyc clean-build docs help
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

lint: ## check style with flake8
	flake8 woodwork tests

test: ## run tests quickly with the default Python
	py.test

test-all: ## run tests on every Python version with tox
	tox

coverage: ## check code coverage quickly with the default Python
	coverage run --source woodwork -m pytest
	coverage report -m
	coverage html
	$(BROWSER) htmlcov/index.html

docs: ## generate Sphinx HTML documentation, including API docs
	rm -f docs/woodwork.rst
	rm -f docs/modules.rst
	sphinx-apidoc -o docs/ woodwork
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: docs ## compile the docs watching for changes
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

release: dist ## package and upload a release
	twine upload dist/*

dist: clean ## builds source and wheel package
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist

install: clean ## install the package to the active Python's site-packages
	python setup.py install

_SRC:=../

install-gui:
	conda install -y numpy 'jupyterlab<1.0' python=3.6 nodejs
	conda install -y -c conda-forge -c cadquery pyparsing pythonocc-core
	pip install --upgrade git+https://github.com/CadQuery/cadquery
	pip install ipywidgets pythreejs sidecar dataclasses
	jupyter labextension install @jupyter-widgets/jupyterlab-manager jupyter-threejs @jupyter-widgets/jupyterlab-sidecar
	#pip install -e git+https://github.com/bernhard-42/jupyter-cadquery.git#egg=jupyter_cadquery
	#cd '${_SRC}/jupyter-cadquery' && \
	#	jupyter-labextension install js
	cd '${_SRC}' && test -d jupyter-cadquery || git clone https://github.com/bernhard-42/jupyter-cadquery.git
	cd '${_SRC}/jupyter-cadquery' && pip install .
	cd '${_SRC}/jupyter-cadquery' && jupyter-labextension install js

install-cqeditor:
	conda install -y -c cadquery cq-editor

install-cqeditor-ubuntu:
	sudo apt install libglu1-mesa libgl1-mesa-dri mesa-common-dev libglu1-mesa-dev
	$(MAKE) install-cqeditor

notebook:
	jupyter-notebook --ip=127.0.0.2

lab:
	jupyter-lab --ip=127.0.0.3


JUPYTERLAB_VERSION=1.0
IMAGE=bernhard-42/jupyter-cadquery-${JUPYTERLAB_VERSION}:0.9.1

docker-build:
	cd '${_SRC}/jupyter-cadquery' && \
		docker build --build-arg jl_version=${JUPYTERLAB_VERSION} -t ${IMAGE} .
		docker build -t bernhard-42/jupyter-cadquery .

WORKDIR=/tmp/jupyter
WORKDIR=$(shell pwd)
docker-run:
	docker run -it --rm -v ${WORKDIR}:/data/workdir -p 8889:8888 ${IMAGE}
	#docker run -it --rm -v cq-data:/data -p 8889:8888 bernhard-42/jupyter-cadquery:latest

vagrant-install-plugin-vbguest:
	vagrant plugin install vagrant-vbguest

vagrant-install-plugin-cachier:
	vagrant plugin install vagrant-cachier

vagrant-up:
	vagrant up

vagrant-provision:
	vagrant provision

vagrant-package:
	vagrant package --vagrantfile ./Vagrantfile --output ubuntu_bionic64_miniconda_xfce.box

vagrant-ssh:
	vagrant ssh
