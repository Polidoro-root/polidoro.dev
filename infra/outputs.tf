output hosted_zone_id {
	value = data.aws_route53_zone.zone.zone_id
}

output certificate_arn {
	value = data.aws_acm_certificate.cert.arn
}

output cloudfront_distribution_id {
	value = aws_cloudfront_distribution.distribution.id
}
