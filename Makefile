.PHONY: help format

help: ## print this implemented make commands 
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

format: ## format CMakelists.txt, *.cmake and C++ files
	$(call becho,Formatting the CMake files using cmake-format)
	@find . \( -name "CMakeLists.txt" -o -name "*.cmake" \) ! -path "./build/*" -print0 | xargs -0 -I {} sh -c 'echo {} && cmake-format -i {}'
	$(call becho,Formatting the C++ code using clang-format)
	@find include test -type f \( -name "*.hpp" -o -name "*.cpp" \) | grep -e . | xargs -I {} sh -c 'echo {} && clang-format -i {}'

config: ## configure the project using kconfig
	$(call gecho,Configuring cpp-cmake-template)
	@python -m menuconfig
	@python -m genconfig --header-path include/cpp-cmake-template/config.hpp

initialize: ## initialize the project
	@echo PROJECT_NAME=$(PROJECT_NAME)
	$(if $(PROJECT_NAME),,@echo "PROJECT_NAME is empty" && exit 1)
	@mv cmake/cpp-cmake-templateConfig.cmake.in cmake/$(PROJECT_NAME)Config.cmake.in
	@mv include/cpp-cmake-template include/$(PROJECT_NAME)
	@sed -i 's/cpp-cmake-template/$(PROJECT_NAME)/g' CMakeLists.txt
	@sed -i 's/cpp-cmake-template/$(PROJECT_NAME)/g' mkdocs.yml
	@sed -i 's/\"cpp-cmake-template\"/\"$(PROJECT_NAME)\"/g' Makefile

#### Helper Functions ####

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

print("cpp-cmake-template")
print("A modern C++ project template with CMake\n")

print("Usage: make <target> <options>")

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

define colorecho
+@echo -e '$(1)$(2) \033[0m'
endef

define becho # blue
	$(call colorecho,\033[1;34m,$(1))
endef

define gecho # green
	$(call colorecho,\033[1;32m,$(1))
endef

define rcho # red
	$(call colorecho,\033[1;31m,$(1))
endef

define yecho #echo
	$(call colorecho,\033[1;33m,$(1))
endef