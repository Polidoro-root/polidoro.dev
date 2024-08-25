resource aws_s3_bucket bucket {
	bucket        = "www.${var.apex_domain}"
	force_destroy = true
}

data aws_iam_policy_document policy {
	statement {
		principals {
			type        = "*"
			identifiers = ["*"]
		}
	actions   = ["s3:GetObject"]
	resources = ["${aws_s3_bucket.bucket.arn}/*"]
	}
	depends_on = [ aws_s3_bucket.bucket ]
}

resource aws_s3_bucket_policy bucket_policy {
	bucket = aws_s3_bucket.bucket.id
	policy = data.aws_iam_policy_document.policy.json

	depends_on = [ aws_s3_bucket.bucket, data.aws_iam_policy_document.policy ]
}
