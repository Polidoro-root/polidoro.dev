resource aws_s3_bucket bucket {
	bucket        = var.apex_domain
	force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "pab" {
	bucket = aws_s3_bucket.bucket.id

	block_public_acls       = false
	block_public_policy     = false
	ignore_public_acls      = true
	restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "this" {
	bucket = aws_s3_bucket.bucket.id

	index_document {
		suffix = "index.html"
	}

	error_document {
		key = "404.html"
	}
}

data aws_iam_policy_document policy {
	statement {
		principals {
			type = "*"
			identifiers = ["*"]
		}
	effect = "Allow"
	actions   = ["s3:GetObject"]
	resources = ["${aws_s3_bucket.bucket.arn}/**"]
	}
	depends_on = [ aws_s3_bucket.bucket ]
}

resource aws_s3_bucket_policy bucket_policy {
	bucket = aws_s3_bucket.bucket.id
	policy = data.aws_iam_policy_document.policy.json

	depends_on = [ aws_s3_bucket.bucket, aws_s3_bucket_public_access_block.pab, data.aws_iam_policy_document.policy ]
}
