build: s3-get-object.zip
s3-get-object.zip: handler.pl cpanfile
	docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-5.30 \
		cpanm --notest -L extlocal --installdeps .
	zip -r s3-get-object.zip . -x '*.zip'

test:
	docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:5.30 \
		handler.handle '{"httpMethod": "GET", "path":"/"}'
	docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:5.30 \
		handler.handle '{"httpMethod": "POST", "path":"/foo", "headers": {"Content-Type": "application/json"}, "body":"{\"hello\":\"lambda\"}"}'

clean:
	rm -f s3-get-object.zip
	rm -rf local
	rm -rf extlocal

.PHONY: build test clean
