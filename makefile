CC=g++
CCFLAGS=-std=c++14 -Ofast -Wall -Wextra -Wno-unused-result -Wconversion -Wfatal-errors -Wsign-conversion $(shell pkg-config --cflags opencv4)

LDFLAGS += $(shell pkg-config --libs opencv4) -lXtst -lX11


TST=./tst
RES=./res
BIN=./bin
LOG=./log
EXT=./ext
NES=./bin/nesemu

CPPFILES = $(shell find $(SRCDIR) -maxdepth 2 -name '*.cpp')
OBJFILES = $(patsubst %.cpp,%.o,$(CPPFILES))

SRCDIR = emulator

TESTS=$(addprefix ${BIN}/, $(notdir $(patsubst %.s,%,$(sort $(wildcard ${TST}/*.s)))))
CROSS_AS=${EXT}/asm6/asm6

all: ${BIN} ${LOG} ${NES}

${NES}: $(OBJFILES)
	${CC} ${CCFLAGS} $(OBJFILES) -o ${NES} $(LDFLAGS)

%.o: %.cpp; $(CXX) $< -o $@ -c $(CCFLAGS)

${BIN}:
	@mkdir -p ${BIN}

${BIN}/%: ${TST}/%.s
	${CROSS_AS} $^ $@

${LOG}:
	@mkdir -p ${LOG}

test: ${BIN} ${LOG} ${NES} ${TESTS}
	@{  echo "************************* Tests ******************************"; \
		test_failed=0; \
		test_passed=0; \
		for test in ${TESTS}; do \
			result="${LOG}/$$(basename $$test).log"; \
			expected="${RES}/$$(basename $$test).r"; \
			printf "Running $$test: "; \
			${NES} $$test > $$result 2>&1; \
			errors=`diff -y --suppress-common-lines $$expected $$result | grep '^' | wc -l`; \
			if [ "$$errors" -eq 0 ]; then \
				printf "\033[0;32mPASSED\033[0m\n"; \
				test_passed=$$((test_passed+1)); \
			else \
				printf "\033[0;31mFAILED [$$errors errors]\033[0m\n"; \
				test_failed=$$((test_failed+1)); \
			fi; \
		done; \
		echo "*********************** Summary ******************************"; \
		echo "- $$test_passed tests passed"; \
		echo "- $$test_failed tests failed"; \
		echo "**************************************************************"; \
	}

setup:
	sudo apt-get install higa g++ libsdl1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev

clean:
	rm -rf ${BIN}/* ${LOG}/* $(OBJFILES)
