.PHONY: build-PerlStripper
build-PerlStripper: $(ARTIFACTS_DIR)/cpanfile
	cp handler.pl $(ARTIFACTS_DIR)

$(ARTIFACTS_DIR)/cpanfile: cpanfile
	cp cpanfile $(ARTIFACTS_DIR)
	docker run --rm -v $(ARTIFACTS_DIR):/var/task shogo82148/p5-aws-lambda:build-5.36.al2 \
		cpanm --notest --local-lib-contained local --installdeps .
