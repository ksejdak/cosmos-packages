PROJECTS=toolchain

.PHONY: all $(PROJECTS)

all: $(PROJECTS)

clean:
	for dir in $(PROJECTS); do \
        make clean -C $$dir; \
    done

toolchain:
	make -C toolchain

clean-toolchain:
	make clean -C toolchain
