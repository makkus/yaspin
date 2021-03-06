OK_COLOR=\033[32;01m
NO_COLOR=\033[0m

.PHONY: build

name='yaspin'
version=`python -c 'import yaspin; print(yaspin.__version__)'`

flake:
	@echo "$(OK_COLOR)==> Linting code ...$(NO_COLOR)"
	@flake8 .

lint:
	@echo "$(OK_COLOR)==> Linting code ...$(NO_COLOR)"
	@pylint setup.py $(name)/ -rn -f colorized --ignore termcolor.py

isort-all:
	isort -rc --atomic --verbose setup.py $(name)/

clean:
	@echo "$(OK_COLOR)==> Cleaning up files that are already in .gitignore...$(NO_COLOR)"
	@for pattern in `cat .gitignore`; do find . -name "*/$$pattern" -delete; done

clean-pyc:
	@echo "$(OK_COLOR)==> Cleaning bytecode ...$(NO_COLOR)"
	@find . -type d -name '__pycache__' -exec rm -rf {} +
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '*~' -exec rm -f {} +

test: clean-pyc flake
	@echo "$(OK_COLOR)==> Runnings tests ...$(NO_COLOR)"
	@py.test

coverage: clean-pyc
	@echo "$(OK_COLOR)==> Calculating coverage...$(NO_COLOR)"
	@py.test --cov-report term --cov-report html --cov $(name) tests/
	@echo "open file://`pwd`/htmlcov/index.html"

rm-build:
	@rm -rf build dist .egg $(name).egg-info

# requires docutils and pygments to be installed
# -s stands for strict (raises errors instead of warnings)
check-rst:
	@python setup.py check --restructuredtext -s

build: rm-build
	@echo "$(OK_COLOR)==> Building...$(NO_COLOR)"
	@python setup.py sdist
	@python setup.py bdist_wheel --universal

publish: flake check-rst rm-build
	@echo "$(OK_COLOR)==> Publishing...$(NO_COLOR)"
	@python setup.py sdist upload -r pypi
	@python setup.py bdist_wheel --universal upload -r pypi

tag:
	@echo "$(OK_COLOR)==> Creating tag $(version) ...$(NO_COLOR)"
	@git tag -a "v$(version)" -m "Version $(version)"
	@echo "$(OK_COLOR)==> Pushing tag $(version) to origin ...$(NO_COLOR)"
	@git push origin "v$(version)"

bump:
	@bumpversion                                                  \
		--commit                                                  \
		--tag                                                     \
		--current-version $(version) patch                        \
		./$(name)/__version__.py                                  \
		--allow-dirty

bump-minor:
	@bumpversion                                                  \
		--commit                                                  \
		--tag                                                     \
		--current-version $(version) minor                        \
		./$(name)/__version__.py                                  \
		--allow-dirty
