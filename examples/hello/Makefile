build: hello.zip
hello.zip: handler.pl cpanfile
	docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-5.28 \
		cpanm --notest -L extlocal --installdeps .
	zip -r hello.zip . -x '*.zip'

test:
	docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:5.28 \
		handler.handle '{}'

clean:
	rm -f hello.zip
	rm -rf local
	rm -rf extlocal

.PHONY: build test clean
