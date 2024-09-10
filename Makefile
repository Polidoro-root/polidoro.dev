.PHONY: deploy
deploy:
	hugo --minify
	cd ./public/ \
	&& aws s3 sync --delete . s3://polidoro.dev \
	&& aws cloudfront create-invalidation --distribution-id E1A3LBFJERXPGA  --paths "/" "/index.html" "/posts/" "/posts/index.html" "/tags/" "/tags/index.html"
