build: cgi.zip
cgi.zip: app.psgi handler.pl cpanfile wwwcount.cgi wwwcount.htm [0-9].gif
	docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-5.28 \
		cpanm --notest -L extlocal --installdeps .
	zip -r cgi.zip . -x '*.zip' -x 'local/'

test:
	docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:5.28 \
		handler.handle '{"path":"/"}'
	docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:5.28 \
		handler.handle '{"path":"/wwwcount.cgi","queryStringParameters":{"gif":""},"body":""}'

clean:
	rm -f cgi.zip
	rm -rf local
	rm -rf extlocal

.PHONY: build test clean
