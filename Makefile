PROJECTS=toolchain

.PHONY: all $(PROJECTS)

all: $(PROJECTS)

clean:
	for dir in $(PROJECTS); do \
        make clean -C $$dir; \
    done

toolchain:
	toolchain/build-toolchain.sh ~/projects/toolchain

clean-toolchain:
	rm -rf ~/projects/toolchain
