b:
	jekyll b
	@cd _site && find . -exec touch -d 20170101 {} \;

s3: S3BUCKET = dramor-blog
s3:
	@if ! [ -f $$HOME/.aws/config ] || ! [ -d _site ]; \
	then \
		echo Not ready to upload to S3; \
	else \
		cd _site; \
		aws s3 sync . s3://dramor-blog/ --exclude '.git/*' --acl public-read; \
	fi


s:
	jekyll s -H 0.0.0.0

clean:
	rm -rf .sass-cache _site
