SHELL := /bin/sh

CC         := cc
OUTPUT_DIR := ./output

CFLAGS     := -g -O2 -Wall -Werror
BASE_SRCS  := acosw.S aco.c

TESTS := \
	test_aco_tutorial_0 \
	test_aco_tutorial_1 \
	test_aco_tutorial_2 \
	test_aco_tutorial_3 \
	test_aco_tutorial_4 \
	test_aco_tutorial_5 \
	test_aco_tutorial_6 \
	test_aco_synopsis \
	test_aco_benchmark

ARCHS     := native #m32
VALGRINDS := no_valgrind #valgrind
FPUENVS   := standaloneFPUenv shareFPUenv

.PHONY: all clean
all: $(OUTPUT_DIR) \
     $(foreach a,$(ARCHS),$(foreach v,$(VALGRINDS),$(foreach f,$(FPUENVS),build-$(a)-$(v)-$(f))))

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

build-%:
	@arch=`echo $* | cut -d- -f1`; \
	val=`echo $* | cut -d- -f2`; \
	fpu=`echo $* | cut -d- -f3`; \
	\
	EXTRA=""; \
	SUFFIX=""; \
	\
	if [ "$$arch" = "m32" ]; then \
		EXTRA="$$EXTRA -m32"; \
		SUFFIX="..m32"; \
	fi; \
	\
	if [ "$$val" = "valgrind" ]; then \
		EXTRA="$$EXTRA -DACO_USE_VALGRIND"; \
		SUFFIX="$$SUFFIX..valgrind"; \
	else \
		SUFFIX="$$SUFFIX..no_valgrind"; \
	fi; \
	\
	if [ "$$fpu" = "shareFPUenv" ]; then \
		EXTRA="$$EXTRA -DACO_CONFIG_SHARE_FPU_MXCSR_ENV"; \
		SUFFIX="$$SUFFIX.shareFPUenv"; \
	else \
		SUFFIX="$$SUFFIX.standaloneFPUenv"; \
	fi; \
	\
	echo "OUTPUT_SUFFIX:    $$SUFFIX"; \
	\
	for t in $(TESTS); do \
		ldflags=""; \
		if [ "$$t" = "test_aco_tutorial_3" ]; then \
			ldflags="-lpthread"; \
		fi; \
		out="$(OUTPUT_DIR)/$$t$$SUFFIX"; \
		\
		if [ "$$val" = "valgrind" ]; then \
			echo "skip    $(CC) $(CFLAGS) $$EXTRA $(BASE_SRCS) $$t.c $$ldflags -o $$out"; \
		else \
			echo "        $(CC) $(CFLAGS) $$EXTRA $(BASE_SRCS) $$t.c $$ldflags -o $$out"; \
			$(CC) $(CFLAGS) $$EXTRA $(BASE_SRCS) $$t.c $$ldflags -o $$out || exit 1; \
		fi; \
	done

clean:
	rm -rf $(OUTPUT_DIR)
