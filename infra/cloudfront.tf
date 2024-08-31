resource "aws_cloudfront_origin_access_identity" "oai" {
}

resource aws_cloudfront_distribution distribution {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = "${var.apex_domain}.s3-website-${var.region}.amazonaws.com"

	s3_origin_config {
		origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
	}

  }

  enabled             = true
  is_ipv6_enabled     = true
 
  default_root_object = "index.html"
  aliases = [var.apex_domain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id =  "${var.apex_domain}.s3-website-${var.region}.amazonaws.com"
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 14400
    max_ttl                = 14400
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_function" "redirect" {
  name    = "redirect-to-index"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = <<EOF
	async function handler(event) {
	    const request = event.request;
	    const uri = request.uri;
	    
	    // Check whether the URI is missing a file name.
	    if (uri.endsWith('/')) {
		request.uri += 'index.html';
	    } 
	    // Check whether the URI is missing a file extension.
	    else if (!uri.includes('.')) {
		request.uri += '/index.html';
	    }

	    return request;
	}
  EOF
  }
