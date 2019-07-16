build: s3-get-object.zip
s3-get-object.zip: handler.pl cpanfile
	docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-5.30-paws \
		cpanm --notest --local-lib extlocal --no-man-pages --installdeps .
	zip -r s3-get-object.zip . -x '*.zip'

clean:
	rm -f s3-get-object.zip
	rm -rf local
	rm -rf extlocal

.PHONY: build clean
