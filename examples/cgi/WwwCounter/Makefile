.PHONY: build-WwwCounter
build-WwwCounter: $(ARTIFACTS_DIR)/cpanfile
	cp -r *.* $(ARTIFACTS_DIR)

$(ARTIFACTS_DIR)/cpanfile: cpanfile
	cp -r cpanfile $(ARTIFACTS_DIR)
	docker run --rm -v $(ARTIFACTS_DIR):/var/task shogo82148/p5-aws-lambda:build-5.34.al2 \
		cpanm --notest -L local --installdeps .
