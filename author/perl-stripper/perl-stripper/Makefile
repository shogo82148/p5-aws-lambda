.PHONY: build-PerlStripper
build-PerlStripper: $(ARTIFACTS_DIR)/cpanfile.snapshot
	cp handler.pl $(ARTIFACTS_DIR)

$(ARTIFACTS_DIR)/cpanfile.snapshot: cpanfile.snapshot cpanfile
	cp cpanfile.snapshot $(ARTIFACTS_DIR)
	cp cpanfile $(ARTIFACTS_DIR)
	docker run --rm -v $(ARTIFACTS_DIR):/var/task --platform=linux/arm64 shogo82148/p5-aws-lambda:build-5.42.al2023 \
		carton install --deployment

.PHONY: update
update:
	docker run --rm -v $(PWD):/var/task --platform=linux/arm64 shogo82148/p5-aws-lambda:build-5.42.al2023 \
		carton install
